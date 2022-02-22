function main_cbct_scatter_project
addpath('C:\EGSnrc-master\postdr')

% The scatter simulation program for clinical data
% Yutong Zhao 
% CancerCare Manitoba
%% The standard results has following: 

% Make the check of the required pre-processed data
% 1a. The CBCT Projection data from Varian TrueBeam measurement
% 1b. CBCT reconstruction from Varian Reconstructor
% 1c. CBCT reconstruction from TIGRE toolkit
%
% Compare the difference between 1b and 1c to evaluate the performance of
% TIGRE

% 2. Get the Paitent Phantom from planning CT scan.
% 2a. The CBCT Projection data from EGSnrc Simulation Results (Total, Primary, Scatter)
% 2b. CBCT reconstruction (Total) from TIGRE toolkit
% 2c. CBCT reconstruction (Primary, scatter removed total) from TIGRE toolkit

% 3. Generate the images for deeplearning traning/validation/test set
% 3a. Train the Unet DL model for a relatively long time (batch size/epoches)
% 3b. Test with Varian measured projection data and then reconstruct

% 4. If the results are fine, then publish our work. 

%% Generate the Task List

%% Visulize the result of a selected paient
paient_show = '305655';                             % Anonymized paient number

Fpath.VarianCBCT_path = ['D:\Clinical_Data\CBCT\',paient_show];  
Fpath.TigreCBCT_path =  ['D:\Clinical_Data\CBCT_projection_data\305655\2021-07-05_113806\e207bb80-bc4a-40dd-b904-046acb33e76a']; 
Fpath.ProjectionCBCT_path = ['D:\Clinical_Data\CBCT_projection_data\305655\2021-07-05_113806\e207bb80-bc4a-40dd-b904-046acb33e76a\Acquisitions\807804500']; 
Fpath.PlanningCT_path = ['D:\Clinical_Data\PlanningCT\',paient_show];

% There are three Phantoms was generated before the simulation
% first Phantom = Raw Phantom from planning CT (clean but not accurate)
% Resolution = 512*512*88
% second Phantom = Raw Phantom from CBCT (scatter photon contaminated phantom, used in RT)
% Resolution = 512*512*88
% Third Phantom = Regenerated Phantom from planning CT (ready to use in EGS_cbct but low resolution)
% Resolution = 137*137*137


% generate phantom from planning CT data by using CTcreate 
Phantom.VarianCBCT = load([Fpath.VarianCBCT_path,'\Varian_CBCT_Recon.mat']);   % 
Phantom.VarianPlanningCT = load([Fpath.PlanningCT_path,'\Varian_PlanningCT_305655_Recon.mat']);
Phantom.TigreCBCT = load([Fpath.TigreCBCT_path,'\Varian_TIGRE_Recon.mat']);
Phantom.CBCTprojection = load([Fpath.ProjectionCBCT_path,'\processed_projection_data.mat']);

%myReconShow(Phantom.VarianCBCT.ReconData)
%% load the simulation geometry for the paient 
% the geometry is very important since the                                    
MCgeo = Phantom.TigreCBCT.geo;
MCangle = Phantom.TigreCBCT.angles;
MCgeo.downsamplingfactor = 4; % this factor must be greater than 1
% simulation phantom from planning CT 


egscbct_parallel(MCgeo,MCangle-pi) % simulation


Size_Scoring = MCgeo.nDetector/4;

egscbct_data_process(flip(Size_Scoring'),egsmap_path)

egsmdata_synchronization(egsmap_path)

end
