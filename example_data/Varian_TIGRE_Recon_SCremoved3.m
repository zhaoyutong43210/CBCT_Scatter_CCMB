function Varian_TIGRE_Recon_SCremoved3 

fns1 = struct2table(dir('Tran*.mat'));

fns2 = struct2table(dir('Clinical*.mat'));
fn1  = sortbyindex(string(fns1{:,1}));
fn2  = (sortbyindex(string(fns2{:,1})));

load('EGScbct_wholedata.mat')

proj_path = 'D:\Clinical_Data\CBCT_projection_data\305655\2021-07-05_113806\e207bb80-bc4a-40dd-b904-046acb33e76a'; 
data_proj = load([proj_path,'\Varian_proj_info.mat']);

if_video = false;

if if_video
 v = VideoWriter('myVideo2.avi');
 %v.FrameRate = 1;
 open(v)
 fig = figure(1);
end

for n = 1:length(fn1)
    
    data_cal = load(fn1(n));
    data_egs = load(fn2(n));
    
    Is = data_cal.traning_output./max(data_cal.traning_input(:));
    
    egs_total = data_synT(:,:,n);
    
    Is_raw = Is.*max(egs_total(:));
    %Is_raw = imgaussfilt(Is_raw);
    data_scatter(:,:,n) = Is_raw;
    %Is./max()
   
    subplot(2,3,1);imagesc(data_egs.Ktotal);colorbar
    title('egs total')
    subplot(2,3,2);imagesc(data_egs.Kscatt);colorbar
    title('egs scatter')
    subplot(2,3,3);imagesc(data_egs.Kscatt./data_egs.Ktotal);colorbar
    title('egs scatter ratio')
    
    subplot(2,3,4);imagesc(data_proj.Iproj(:,:,n));colorbar
    title('Varian total (measurment)')
    subplot(2,3,5);imagesc(data_cal.traning_output);colorbar
    title('Varian scatter (estimation)')
    subplot(2,3,6);imagesc(data_cal.traning_output./data_proj.Iproj(:,:,n));colorbar
    title('Varian scatter ratio(estimation)')
    drawnow
    
    if if_video
     writeVideo(v,getframe(fig))
    end
end

if if_video
 close(v)
end
% encode with the average of simulation
data_scatter2 = data_scatter./mean(maxk(data_synT(:),1e3).*0.76);
% decode with the average of real measurement
data_scatter2 = data_scatter2.*mean(maxk(data_proj.Iproj(:),1e4));

%
% subplot(1,2,1);imagesc(data_proj.Iproj(:,:,1))
% subplot(1,2,2);imagesc(Iproj(:,:,1))
% 
% subplot(1,2,1);plot(data_proj.Iproj(:,512,1))
% subplot(1,2,2);plot(Iproj(:,512,1))


n = 0;
for correct_factor = 0:0.02:1.0
Iproj_clean = data_proj.Iproj(:,:,1:end-1) - data_scatter2.*correct_factor;
% 
    for ii = 1:size(Iproj_clean,3)
        Iproj_clean(:,:,ii) = ordfilt2(Iproj_clean(:,:,ii), 5, ones(1,9));
    end
%
disp(['scatter_max = ',num2str(max(data_scatter2(:))*correct_factor)])

Iproj_clean(Iproj_clean<0) = 0;
Iproj_clean(isnan(Iproj_clean)) = 0;
Iproj_clean(isinf(Iproj_clean)) = 0;

proj_clean = log(repmat(data_proj.blk, [1 1 size(Iproj_clean,3)])./Iproj_clean);

proj_clean(proj_clean<0) = 0;
proj_clean(isnan(proj_clean)) = 0;
proj_clean(isinf(proj_clean)) = 0;


proj2 = single(proj_clean);
proj = data_proj.proj;

subplot(2,2,1);imagesc(data_proj.Iproj(:,:,1));colorbar;
subplot(2,2,2);imagesc(data_scatter2(:,:,1));colorbar;
subplot(2,2,3);imagesc(Iproj_clean(:,:,1));colorbar;
subplot(2,2,4);imagesc(proj_clean(:,:,1));colorbar;

pause(1)

img1 = FDK(proj,data_proj.geo,data_proj.angles);
img2 = FDK(proj2,data_proj.geo,data_proj.angles(1:end-1));

dif = (img1-img2)./img2; % in percentage

makeVideo(([img1,img2]),['Varian_cleanCBCT_Recon',num2str(n),'.avi'])
n = n+1;
end 

end


% ======================================================================= %
function strnew = Common_Strings_in_Char(str)
       
    for n = 1:size(str,1)-1
        str1 = str(n,:);
        str2 = str(n+1,:);
        
       ind =  str1 == str2;
       if n==1
           inde = ind;
       else
           inde = inde & ind;
       end
       
    end
strnew = str(1,inde);
end
% ======================================================================= %
function fnsnew = sortbyindex(fns)
strcom = Common_Strings_in_Char(char(fns(:)));    % Find the Commen strings in File names array
[~,~,ext] = fileparts(fns(1,1));                  % Get the file extension
str_left = (erase(fns(:,1),[strcom,ext]));        % erase the common str & extension, 
fns(:,2) = regexp(str_left,'\d*','Match','once');                                                 % now the left should be the number index.                   
[~,ind] = sort(double(fns(:,2)));                 % sort by num(double value) instead of string

fnsnew = fns(ind,1);                              % now everything is in a neat way; enjoy :)
end
% ======================================================================= %
function output_img = low_pass_filter(img,cut_freq)
FT_img = fft2(double(img));
[M, N] = size(img);
% Assign Cut-off Frequency  
D0 = cut_freq; % one can change this value accordingly
  
% Designing filter
u = 0:(M-1);
idx = find(u>M/2);
u(idx) = u(idx)-M;
v = 0:(N-1);
idy = find(v>N/2);
v(idy) = v(idy)-N;
  
% MATLAB library function meshgrid(v, u) returns
% 2D grid which contains the coordinates of vectors
% v and u. Matrix V with each row is a copy 
% of v, and matrix U with each column is a copy of u
[V, U] = meshgrid(v, u);
  
% Calculating Euclidean Distance
D = sqrt(U.^2+V.^2);
  
% Comparing with the cut-off frequency and 
% determining the filtering mask
H = double(D <= D0);
  
% Convolution between the Fourier Transformed
% image and the mask
G = H.*FT_img;
  
% Getting the resultant image by Inverse Fourier Transform
% of the convoluted image using MATLAB library function 
% ifft2 (2D inverse fast fourier transform)  
output_img = real(ifft2(double(G)));
end