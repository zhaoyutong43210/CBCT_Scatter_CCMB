function compare_planning_CBCT

data_planning = load('D:\Clinical_Data\PlanningCT\305655\Varian_PlanningCT_305655_Recon.mat');
data_CBCT = load('D:\Clinical_Data\CBCT\305655\Varian_CBCT_Recon.mat');

index_start = 96;
index_end = 182;
data1 = data_planning.ReconData(:,:,index_start:index_end);    % 1 - 235 slices in planning CT
data2 = flip(data_CBCT.ReconData,3);                    % 88 slices

[X,Y,Z] = meshgrid(1:512,1:512,linspace(1,size(data2,3),index_end-index_start+1));
[X1,Y1,Z1] = meshgrid(1:512,1:512,1:size(data2,3));

data1_int = interp3(X,Y,Z,data1,X1,Y1,Z1,'spline'); % interplotation is necessary

climax1 = max(data1_int(:));
climin1 = min(data1_int(:));

climax2 = max(data2(:));
climin2 = min(data2(:));

v = VideoWriter('Compare_planning_CBCT.avi');
open(v)

for n = 1:size(data2,3)
    A = mat2gray(data1_int(:,:,n),[climin1 climax1]);
    B = mat2gray(data2(:,:,n),[climin2 climax2]);
    imshow([A,B]);
    writeVideo(v,[A,B])
end 
close(v)
end