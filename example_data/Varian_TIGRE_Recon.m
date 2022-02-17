function Varian_TIGRE_Recon
%% Using Varian Meansured projection images (data stored in XIM & Scan info in XML file)
% This code is written by Yutong Zhao
% CancerCare Manitoba
% Aug 6th 2021

% Based on the TIGRE Demo 21: Loading scanner data to TIGRE. 

%% Varan onboard CBCT.

% If you have a Varian scanner that saves data in XIM format, the following
% code will be able to load your dataset. 
%
% If you have a recosntructed image, it will take the geometry from there,
% but if you don't, it will estimate appropiate geometry. You can always
% change the image parameters, but the detector parameters should stay the
% same unless you change the projections. 

motion_lag = true;
datafolder='D:\Clinical_Data\CBCT_projection_data\305655\2021-07-05_113806\e207bb80-bc4a-40dd-b904-046acb33e76a';
cd(datafolder)

% use load
if ~motion_lag
[proj,geo, angles ] = VarianDataLoader(datafolder);
else
[proj,geo, angles ] = VarianDataLoader(datafolder, false); %remove motion lag correction.
end 

% [ang,inds] = sort(angles);
% porjs = proj(:,:,inds);
% You can directly call reconstruction code now:

%img1 = OS_SART(proj,geo,angles,20);
img2 = FDK(proj,geo,angles);

save('Varian_TIGRE_Recon.mat','img1','img2','proj','geo','angles','-v7.3')

