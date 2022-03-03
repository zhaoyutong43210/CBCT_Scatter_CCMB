function Varian_TIGRE_Recon_SCremoved


%% run this code to initalize the TIGRE 
% run this only once 
% 
% cd('D:\CBCT_reconstruction\TIGRE-master\TIGRE-master\MATLAB')
% InitTIGRE

motion_lag = true;
datafolder='D:\Clinical_Data\CBCT_projection_data\305655\2021-07-05_113806\e207bb80-bc4a-40dd-b904-046acb33e76a';
cd(datafolder)


data_scatter_folder = 'D:\Clinical_Data\305655_02Feb20221014\';


if isfile('Simu_dataset.mat')
    load('Simu_dataset.mat')
% load scattering intensity 
else
    [scatt_int,simuproj] = ScatterDataLoader(data_scatter_folder);
    save('Simu_dataset.mat','scatt_int','simuproj','-v7.3')
end

% use load
if isfile('Varian_TIGRE_Recon.mat')
    load('Varian_TIGRE_Recon.mat');
else
    if ~motion_lag
    [proj,geo, angles ] = VarianDataLoader(datafolder);
    else
    [proj,geo, angles ] = VarianDataLoader(datafolder, false); %remove motion lag correction.
    end 
end

angles(end) = []; 
proj(:,:,end) =[];

%makeVideo([scatt_int],'Varian_scatterCBCT_projections.avi')
%makeVideo([proj],'Varian_cleanCBCT_projections.avi')
% [ang,inds] = sort(angles);
% porjs = proj(:,:,inds);
% You can directly call reconstruction code now:

proj2 = clean_data_calculator(proj,scatt_int,simuproj);

proj2 = single(proj2);
img1 = FDK(proj,geo,angles);
img2 = FDK(proj2,geo,angles);

dif = (img1-img2)./img2; % in percentage

makeVideo(([img1,img2]),'Varian_cleanCBCT_Recon1.avi')
makeVideo(([dif]),'Varian_cleanCBCT_compare.avi')
end

function [scatter,att] = ScatterDataLoader(datafolder)

fn = struct2table(dir([datafolder,'\TraningClinical*.mat']));

fn = fn{:,1};

fns = sortbyindex(string(fn));

for n = 1:height(fns) 
    filename = fns(n);
    
    data = load([datafolder,'\',char(filename)]);
    scatter(:,:,n) = data.traning_output;
    
    datar = load([datafolder,'\',char(erase(filename,'Traning'))]);
    att(:,:,n)  = datar.Katt;
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


function proj2 = clean_data_calculator(proj,scatt_int,simuproj)
proj = double(proj);

Iproj = exp(-proj);

d = Iproj-scatt_int.*0.9;
d(d<0) = 0;

data_corrected = -log(d);

simudata = -log(simuproj./max(simuproj(:)));

% if false
% for n = 1:size(proj,3)
%     
%     
%     
%     subplot(3,3,1)
%     imagesc(simudata(:,:,n));colorbar
%     title('simulated projections (attenuation)')
%     
%     subplot(3,3,2)
%     imagesc(simuproj(:,:,n));colorbar
%     title('simulated projections (intensity)')
%     
%     subplot(3,3,4)
%     imagesc(proj(:,:,n));colorbar
%     title('Varian projections (attenuation)')
%     
%     subplot(3,3,5)
%     imagesc(Iproj(:,:,n));colorbar
%     title('Varian projections (intensity)')
%     
%     subplot(3,3,7)
%     imagesc(data_corrected(:,:,n));colorbar
%     title('corrected projections (attenuation)')
%     
%     subplot(3,3,8)
%     imagesc(exp(-data_corrected(:,:,n)));colorbar
%     title('corrected projections (intensity)')
%     
% %%
%     subplot(3,3,3)
%     imagesc(scatt_int(:,:,n));colorbar
%     title('scatter projections (intensity)')
%     
%     subplot(3,3,6)
%     imagesc(Iproj(:,:,n) - (d(:,:,n)));colorbar
%     title('difference (I)')
%     
%     subplot(3,3,9)
%     imagesc((proj(:,:,n) - (data_corrected(:,:,n))));colorbar
%     title('difference (att)')
%     
% %%
% 
%     drawnow
%     %pause(0.1)
%     
%     
% end
% end

proj2 = data_corrected;
end