function create_egs_phantom(PlanningCT_file)

if nargin<1
PlanningCT_path = ['D:\Clinical_Data\PlanningCT\305655'];
PlanningCT_file = [PlanningCT_path,'\Varian_PlanningCT_305655_Recon.mat'];

CBCT_file = 'D:\Clinical_Data\CBCT\305655\Varian_CBCT_Recon.mat';
else 
    PlanningCT_file = uigetfile(PlanningCT_file);
    
end

geopath = 'D:\Clinical_Data\CBCT_projection_data\305655\2021-07-05_113806\e207bb80-bc4a-40dd-b904-046acb33e76a\'; 

%
data  = load(PlanningCT_file);
data2 = load(CBCT_file); 

geoinfo = load([geopath,'\Varian_TIGRE_Recon.mat']);
geo = geoinfo.geo;

PlanningCTdata = data.ReconData;
CBCTdata =  flip(data2.ReconData,3);

% index in Planning CT data
index_increase = 15;
index_start = 96-index_increase;  % this is for the index in z direction (slices)
index_end = 182+index_increase;
%
data1 = PlanningCTdata(:,:,index_start:index_end);    % 1 - 235 slices in planning CT
%data2 = load(CBCT_file);                              % 1 - 235 slices in CBCT

% index in Planning CT data
yind = [100:100+400]-25;
xind = [90:90+400]+3;

x2 = [20:300];
y2 = [50:360];
data3 = PlanningCTdata(xind,yind,index_start:index_end);

data_phantom = permute(data3(x2,y2,:),[2,3,1]);

%permute(data3(x2,y2,:),[2 3 1]);
data_phantom = flip(data_phantom,2);

data_phantom = flip(data_phantom,3);

% for planning CT data 
pixel_spacing = [1.171875 1.171875]/10; % I believe the unit is in mm, divide by 10 convert to cm
slice_thickness = 2/10;
% for CBCT data
pixel_spacing_cbct = [9.0802036e-1,9.0802036e-1];
slice_thickness_cbct = 1.98849013696227;

xpt = ([1:size(data1,1)]*pixel_spacing(1) - mean([1:512]*pixel_spacing(1)))*10-45;
ypt = ([1:size(data1,2)]*pixel_spacing(2) - mean([1:512]*pixel_spacing(2)))*10-20;

% xc = [-geo.sVoxel(1)/2,-geo.sVoxel(1)/2];
% yc = [-geo.sVoxel(1)/2,-geo.sVoxel(1)/2];

xc = ([1:size(CBCTdata,1)]*pixel_spacing_cbct(1) - mean([1:512]*pixel_spacing_cbct(1)));
yc = ([1:size(CBCTdata,2)]*pixel_spacing_cbct(2) - mean([1:512]*pixel_spacing_cbct(2)));

for n = 1:size(CBCTdata,3)-1
    
    subplot(2,2,1)
    imagesc(xc,yc,CBCTdata(:,:,n))
    daspect([1 1 1])
    title('CBCT data');
    
  subplot(2,2,2)
  
  datai = interp2(data1(xind,yind,n+index_increase),linspace(1,range(xind),512),linspace(1,range(yind),512)');
  imagesc(xpt,ypt,datai)
  daspect([1 1 1])
  title('Planning CT data');
  
%   data_c = 
     subplot(2,2,3)
     imagesc(xc,yc,CBCTdata(:,:,n))
     hold on
     red = cat(3,ones(size(datai)),zeros(size(datai)),zeros(size(datai))); 
     h = image(xpt(xind),ypt(yind),red);
     set(h, 'AlphaData', edge(datai));
     
     hold off     
     title('CBCT background + Planning CT data (red outlines)');
     daspect([1 1 1])
     %axis xy

     subplot(2,2,4)
     
     imagesc(xc,yc,zeros(512))
     hold on 
     
     xp = ypt(yind(y2)); % range + offset
     yp = xpt(xind(x2));
     imagesc(xp,yp,flipud(squeeze(data_phantom(:,size(data_phantom,2)-(n+index_increase),:))'))
     daspect([1 1 1])
     title('patient phantom');
     hold off
     %axis xy
     
     drawnow
end 
ramp = [0.44 0.302 1.101 3.188]; % 1bot 1top 1top 2top 4top

Rescale_intercepet = -1024;
Rescale_slope = 1; 

zp = [1:size(data_phantom,3)]*slice_thickness*10 - mean(1:size(data_phantom,3)*slice_thickness*10);

HU = (flip(data_phantom,3) * Rescale_slope + Rescale_intercepet); % HU rescale from saved data 
% please refer to https://blog.kitware.com/dicom-rescale-intercept-rescale-slope-and-itk/

CT_density = (HU/1000+1); % linear attenuation relative to water
% in this code, I don't know if the linear attenuation coefficient = CT density, but I
% assume this since it is very close.

index_phantom = indexrize_data(CT_density,ramp);

xptn = ([1:size(data1,1)+1]*pixel_spacing(1) - mean([1:size(data1,1)+1]*pixel_spacing(1)))*10-45;
yptn = ([1:size(data1,2)+1]*pixel_spacing(2) - mean([1:size(data1,2)+1]*pixel_spacing(2)))*10-20;
phantomx = xptn(xind([x2,max(x2)+1]));
phantomy = yptn(yind([y2,max(y2)+1]));
phantomz = (1:size(data_phantom,2)+1).*slice_thickness*10-mean((1:size(data_phantom,2)+1).*slice_thickness*10);

phantsize = [{phantomy};{(phantomz)};{(phantomx)}];

write_egs_phantom_from_CT_raw_data('throax_305655',index_phantom,CT_density,phantsize)

%%
sz = size(index_phantom);



phantom_size = pixel_spacing.*sz([1,3]); % convert from volexs to 
phantom_size(3) = slice_thickness*sz(2);

cx = mean(xind(x2)); % center of x
cy = mean(yind(y2)); % center of x

phantom_offset = [cx-size(PlanningCTdata,1)/2,cy-size(PlanningCTdata,2)/2].*pixel_spacing;
save('Phantom_throax_305655.mat','CT_density','phantom_size','phantom_offset');
end 

function write_egs_phantom_from_CT_raw_data(fn,index_phantom,CT_density,phantsize)

if size(CT_density) == size(index_phantom)
    

myfile = fopen([fn,'.egsphant'],'w');

fprintf(myfile,'4 \r\n');
fprintf(myfile,'AIR521ICRU         \r\n');
fprintf(myfile,'LUNG521ICRU        \r\n');
fprintf(myfile,'ICRUTISSUE521ICRU  \r\n');
fprintf(myfile,'ICRPBONE521ICRU    \r\n');
fprintf(myfile,'1.00000000       1.00000000       1.00000000       1.00000000       \r\n');
%
fprintf(myfile,'%d %d %d    \r\n',size(index_phantom));
% 
% write the size of the phantom
sz = size(index_phantom);
pixel_spacing = [1.171875 1.171875]/10; % I believe the unit is in mm, divide by 10 convert to cm
slice_thickness = 2/10;


mysize0 = pixel_spacing.*sz([1,3]); % convert from volexs to 
mysize0(3) = slice_thickness*sz(2);

mysize = phantsize{1};
for n = 1:3
fprintf(myfile,'%.8f\t',phantsize{n}/10);
fprintf(myfile,'\r\n');
%
end

% write phantom index
% please refer to Charpter 16 CT Based Phantoms/ctcreate
% https://nrc-cnrc.github.io/EGSnrc/doc/pirs794-dosxyznrc.pdf
for n1 = 1:size(index_phantom,3)
    
    for n2 = 1:size(index_phantom,2)
fprintf(myfile,'%d',index_phantom(:,n2,n1));
fprintf(myfile,'\r\n');
    end
    fprintf(myfile,'\r\n');
end 

% write phantom CT density
% please refer to Charpter 16 CT Based Phantoms/ctcreate
% https://nrc-cnrc.github.io/EGSnrc/doc/pirs794-dosxyznrc.pdf
for i1 = 1:size(CT_density,3)
    for i2 = 1:size(CT_density,2)
fprintf(myfile,'%.8E\t',CT_density(:,i2,i1));
fprintf(myfile,'\r\n') ;
    end 
    fprintf(myfile,'\r\n');
end



fprintf(myfile,'\r\n');
fprintf(myfile,'\r\n');

fclose(myfile);


else 
    warning('the size of the input data size does not match each other!');
end
end

function index_phantom = indexrize_data(data,ramp)

index_phantom = zeros(size(data));
rbot = 0;
for n = 1:length(ramp)
    rtop = ramp(n);
    idn = data(:)<rtop & data(:)>=rbot;
index_phantom(idn) = n; 
rbot = rtop;
end


if min(index_phantom(:))==0
warning('There are one or more volex(s) in phantom cannot be classified into index!\n Check your ramp data!')
disp(['min_index = ',num2str(max(index_phantom(:)))])
disp(['max_index = ',num2str(min(index_phantom(:)))])
else 
    disp('All volexs has been classified successfully!');
end 
end