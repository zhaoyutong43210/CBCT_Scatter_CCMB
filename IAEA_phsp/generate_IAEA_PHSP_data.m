function data_ascii = generate_IAEA_PHSP_data(geo,blk,spectrum)

% cd('D:\CBCT_reconstruction\TIGRE-master\TIGRE-master\MATLAB')
% InitTIGRE

% Large txt file open with emeditor
%

%% 
if nargin <1
    
% non isotropic projection image on the X-ray imager
image_name = 'D:\Clinical_Data\CBCT_projection_data\305655\2021-07-05_113806\e207bb80-bc4a-40dd-b904-046acb33e76a\Calibrations\AIR-Half-Bowtie-125KV\Current\FilterBowtie.xim';
blk = mexReadXim(image_name);
blk = (double(blk'));

% geomotry of the cbct scan
paient_show = '305655';                    % Anonymized paient number
Fpath.VarianCBCT_path = ['D:\Clinical_Data\CBCT\',paient_show];  
Fpath.TigreCBCT_path =  ['D:\Clinical_Data\CBCT_projection_data\305655\2021-07-05_113806\e207bb80-bc4a-40dd-b904-046acb33e76a']; 
Phantom.TigreCBCT = load([Fpath.TigreCBCT_path,'\Varian_TIGRE_Recon.mat']);
geo = Phantom.TigreCBCT.geo;

% energy spectrum
energy_spectrum_file = 'C:\EGSnrc-master\egs_home\egs_cbct\120kVp_cbct.ensrc';
energy_data = importdata(energy_spectrum_file,' ',1);

spectrum.probability = str2num(cell2mat(energy_data.textdata(3:end,2)));
spectrum.energy = str2num(cell2mat(erase(energy_data.textdata(3:end,1),',')));

ifsave = 0;
else
    
end

photon_histories = 1e8;

%%

% K = (1/9)*ones(3);
% Zsmooth2 = conv2(blk,K,'same');

% subplot(2,2,3)
% imagesc(Zsmooth2)
% 
% subplot(2,2,4)
% plot(Zsmooth2')

T = sum(blk(:));

n_per_int = photon_histories/T;

xedge = [-geo.sDetector(1)/2:geo.dDetector(1):geo.sDetector(1)/2]-geo.offDetector(1);
yedge = [-geo.sDetector(2)/2:geo.dDetector(2):geo.sDetector(2)/2]-geo.offDetector(2);

x = xedge(1:end-1) + geo.dDetector(1)/2;
y = yedge(1:end-1) + geo.dDetector(2)/2;

source = [0,0,-geo.DSO]; % source x, y, z in egsinp file
pz = geo.DSD-geo.DSO;

photons = round(n_per_int.*blk);
weight = photons./(n_per_int.*blk);

nn = sum(photons(:));

data_ascii = zeros(nn,9);
px = zeros(nn,1);
py = zeros(nn,1);

erng = randpdf(spectrum.probability,spectrum.energy,[nn,1]);

n = 1;

figure(1);
subplot(1,2,1)
plot(spectrum.energy,spectrum.probability)
subplot(1,2,2)
histogram(erng,1000)

figure(2);
subplot(2,2,1)
imagesc(blk);colorbar

     subplot(2,2,2)
     plot(blk')
     xlabel('x(pixels)')
     ylabel('photons per pixel')

for ny = 1:size(blk,1)
    yp = y(ny);
    ny
    for nx = 1:size(blk,2) 
        xp = x(nx);
        for np = 1:photons(ny,nx)
            
            px(n) = xp + (rand-0.5)*geo.dDetector(1);
            py(n) = yp + (rand-0.5)*geo.dDetector(2);
            ray_vector = ([px(n),py(n),pz]-source)/10;
            
            UVW = ray_vector./norm(ray_vector);
%            Test = sqrt(U.^2+V.^2+W.^2)-1;
%             if abs(Test) > 1e-6
%                 warning('direction cosine sum over 1, please check the code!')
%             end            
            data_ascii(n,:) =[1, erng(n), (source(1)+rand-0.5)/10, ...
                              (source(2)+rand-0.5)/10, source(3)/10, UVW, weight(ny,nx)];
            n=n+1;
        end
    end
end
     
     subplot(2,2,3)
     [N,c] = hist3([py,px],'Nbins',[768,1024]);
     imagesc(c{2},c{1},(N))
     xlabel('x(cm)')
     ylabel('y(cm)')
     %daspect([1 1 1])
     %caxis([0 13])
     colorbar
     title('X-Y distribution')
     
     subplot(2,2,4)
     plot(N'.*(weight'));
     xlabel('x(pixels)')
     ylabel('photons per pixel(weighted)')
     
     data_ascii = data_ascii(randperm(size(data_ascii,1)),:);
     data_ascii = data_ascii(randperm(size(data_ascii,1)),:);
     
   if ifsave
      save('CBCT_source_IAEA_PHSP.mat','data_ascii','-v7.3');
   end
end