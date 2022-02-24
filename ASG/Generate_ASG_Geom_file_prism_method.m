function Generate_ASG_Geom_file_prism_method

%% One dimensional Anti-Scatter Grid
%%

path = 'C:\EGSnrc-master\egs_home\egs_cbct';
Tfilename = 'ASG_template.geom';

G_filename = 'Generated_ASG_prism2.geom';

envlope = 1;%true;
plot_geo = 1;
%% Factory setting/ Manufacture parameters of Varian Anti-Scatter Grid (1D)
%%
Grid_Ratio = 0.1;
Grid_Height = -0.13;  % in unit of cm
Grid_thick = 0.0036; % in unit of cm
Line_rate = 60;      % in unit of cm - number of grid lines per unit distance

h = Grid_Height; 
D = h*Grid_Ratio; 

Lattice_size = [30 40];% in unit of cm (1)- strip length (2) strip distribution length

F = floor(Lattice_size(2)*Line_rate);

Detector_displacement = [16];     % in unit of mm, displacement in lateral(X) direction
Detector_SDD = -150;                % in unit of mm, source-detector distance

Grid_Array = linspace(-Lattice_size(2)/2,Lattice_size(2)/2,F) + Detector_displacement;
                                    % in unit of mm, the X coordinates for
                                    % each grid strips
Detector_SDD = Detector_SDD + Grid_Array*0;

Grid_angles = atan(Grid_Array./Detector_SDD);

% fileID = fopen([path,'\',Tfilename]);
% Templatetxt = textscan(fileID, '%s');
% fclose(fileID);

%cellstr(Templatetxt)

% 
Grid_D = [-Lattice_size(1)/2 Lattice_size(1)/2];
Grid_H = [0 h];

if plot_geo 
subplot(1,2,1)
plot([Grid_Array; Grid_Array]',Grid_D,'b')
subplot(1,2,2)
plot([Grid_Array; Grid_Array]',Grid_H,'b--'); hold on
plot([Grid_Array; Grid_Array+h.*tan(-Grid_angles)]',Grid_H,'b')
end

Grid_cor = [Grid_Array; Grid_Array+h.*tan(-Grid_angles)]';

Grid_position = generate_points(Grid_cor,Grid_H,Grid_thick);


[~,indx_sort] = sort(abs(Grid_Array));
Grid_position = Grid_position(indx_sort);


NewfileID = fopen([path,'\',G_filename],'w');

Array_N = length(Grid_Array);
fprintf(NewfileID,':start geometry definition:');
fprintf(NewfileID,newline);

geonamearray=strings(1,Array_N);
%%

Prism_Limits = '-15 15';
%%
% Grid_position = Grid_position(1:length(Grid_position)/10:end);

for i = 1: length(Grid_position) % % length(Grid_position)
    geoname = ['prism_',num2str(i)];
%     X= 0;
%     Y= (i-1)*5;
%     Z= 0;
    
    points = char(Grid_position(i));
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf(NewfileID,'\t:start geometry:');    fprintf(NewfileID,newline);
    
    fprintf(NewfileID,['\t\t name = ',geoname]);fprintf(NewfileID,newline);
    fprintf(NewfileID,['\t\t library = egs_prism']);fprintf(NewfileID,newline);
    fprintf(NewfileID,['\t\t type = EGS_PrismY']);fprintf(NewfileID,newline);
    fprintf(NewfileID,['\t\t points = ',points]);fprintf(NewfileID,newline);
    fprintf(NewfileID,['\t\t closed = ',Prism_Limits]);fprintf(NewfileID,newline);

    fprintf(NewfileID,'\t\t :start media input:');fprintf(NewfileID,newline);
    fprintf(NewfileID,'\t\t\t media = PB521ICRU');fprintf(NewfileID,newline);
    fprintf(NewfileID,'\t\t :stop media input:');fprintf(NewfileID,newline);

    fprintf(NewfileID,'\t:stop geometry:');    fprintf(NewfileID,newline);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    geonamearray(i) = geoname;
end
%%
if envlope 
    size = '0.0036 0.0036 0.0036'; 
    %size = '10 10 0.01'; 
    geoname1 = 'reference_box';
    box_write(NewfileID,size,geoname1)
    geonamearray(i+1) = geoname1;
end 


simugeoname = 'mygrid';

fprintf(NewfileID,newline);
fprintf(NewfileID,newline);

    fprintf(NewfileID,'\t:start geometry:');    fprintf(NewfileID,newline);
    
    fprintf(NewfileID,['\t\t name = ',simugeoname]);fprintf(NewfileID,newline);
    fprintf(NewfileID,'\t\t library = egs_gunion');fprintf(NewfileID,newline);


    fprintf(NewfileID,strjoin(['\t\t geometries = ',strjoin(geonamearray,' ')]));
    fprintf(NewfileID,newline);

    
    fprintf(NewfileID,'\t:stop geometry:');    fprintf(NewfileID,newline);
%%


fprintf(NewfileID,['\tsimulation geometry = ',simugeoname]);
fprintf(NewfileID,newline);
%
fprintf(NewfileID,':stop geometry definition:');
fprintf(NewfileID,newline);

fprintf(NewfileID,newline);
fclose(NewfileID);

end

function Grid_position = generate_points(Grid_position,Grid_H,t)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input  :   (x1,x2)  ==> a line of the Anti-scatter Grid
% Output :  [(x1,0),(x1+t,0),(x2+t,h),(x2,h)] ==> Prism points with
% thinkness
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pts = strings(size(Grid_position,1),11);

pts(:,1)=num2str(Grid_position(:,1),'%.10f');
pts(:,2)=num2str(Grid_H(1));

pts(:,3)='\t';

pts(:,4)=num2str(Grid_position(:,1)+t,'%.10f');
pts(:,5)=num2str(Grid_H(1));

pts(:,6)='\t';

pts(:,7)=num2str(Grid_position(:,2)+t,'%.10f');
pts(:,8)=num2str(Grid_H(2));

pts(:,9)='\t';

pts(:,10)=num2str(Grid_position(:,1),'%.10f');
pts(:,11)=num2str(Grid_H(2));

Grid_position = join(pts);
end

function box_write(fileID,size,geoname)

%%
    fprintf(fileID,'\t:start geometry:');       fprintf(fileID,newline);
    fprintf(fileID,['\t\t name = ',geoname]);   fprintf(fileID,newline);
    fprintf(fileID,['\t\t library = egs_box']); fprintf(fileID,newline);
    fprintf(fileID,['\t\t box size = ',size]);  fprintf(fileID,newline);
%%
    fprintf(fileID,'\t\t :start media input:'); fprintf(fileID,newline);
    fprintf(fileID,'\t\t\t media = AIR521ICRU'); fprintf(fileID,newline);
    fprintf(fileID,'\t\t :stop media input:');  fprintf(fileID,newline);
    fprintf(fileID,'\t:stop geometry:');        fprintf(fileID,newline);
end

