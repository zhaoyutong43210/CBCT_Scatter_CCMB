function compare_Recon 

Reco_data_Varian = load('D:\Clinical_Data\CBCT\305655\Varian_CBCT_Recon.mat');
Reco_data_TIGRE = load('D:\Clinical_Data\CBCT_projection_data\305655\2021-07-05_113806\e207bb80-bc4a-40dd-b904-046acb33e76a\Varian_TIGRE_Recon.mat');

v = VideoWriter('Compare_Recon.avi');
open(v)
cmax1 =  max(Reco_data_TIGRE.img2(:))*0.7;
cmin1 =  0;%min(Reco_data_TIGRE.img2(:));

cmax2 = max(Reco_data_Varian.ReconData(:));
cmin2 = 0;%min(Reco_data_Varian.ReconData(:));

data1 = flip(double(Reco_data_TIGRE.img2),3);
data2 = Reco_data_Varian.ReconData;

for n = 1:size(Reco_data_TIGRE.img2,3)
    
    A = mat2gray(data1(:,:,n),double([cmin1 cmax1]));
    B = mat2gray(data2(:,:,n),double([cmin2 cmax2]));
    imshow([flipud(A),B]);drawnow
    writeVideo(v,[flipud(A),B])
    
end
close(v)

end

