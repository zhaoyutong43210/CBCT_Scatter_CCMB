function generate_cbct_rotation_file(rotation,step,FileName1,FileName2,mode)
%% Aim: Updating the rotation angle in the input file for egs_cbct
% rep_str = the string need to be replaced 
% rotation = the rotation angle need to be added

if nargin ==0
    rotation = 0; % rotation angle
    step = 45;    % increment of ratation angle
    rep_Rot_str = 'y-rotation = 0'; 
    rep_Step_str = 'step  = 45';
    mode = 1; 
    
    %% loading the input file for egs_cbct:
    fpath = fileparts(which(mfilename));
    PathName = [back2above(fpath,1), '\egs_home\egs_cbct\'];
    FileName = uigetfile([PathName,'*.egsinp']);
    fprintf(['Current Working *.egsinp File is  ---  ', FileName,'\n']);
end

%% read in the current input file;
FileID = fopen([FileName1],'r');
f = fread(FileID,'*char')';
fclose(FileID);

rep_Rot_str = 'y-rotation = 0'; 
rep_Step_str = 'step  = 2';

if mode == 1 % the real CT phantom
    
    %% update the rotation and overwrite the current input file
    str_step = ['step = ',num2str(1)];
    str_rotation = ['y-rotation = ',num2str(rotation)];
    f = strrep(f,rep_Rot_str,str_rotation);
    f = strrep(f,rep_Step_str,str_step);
    
    % save the updated input files
    FileID = fopen(erase(join([FileName2]),' '),'w');
    fprintf(FileID,'%s',f);
    fclose(FileID);
    
elseif mode == 0 %  Change the simulation geometry from Blank phantom to CT Volume
    % change the selection from CT phantom to 
    f = strrep(f,'#simulation geometry = phantom','simulation geometry = phantom');
    f = strrep(f,'simulation geometry = blank_phantom','#simulation geometry = blank_phantom');
    
    %% save the updated input files
    FileID = fopen(erase(join([FileName2]),' '),'w');
    fprintf(FileID,'%s',f);
    fclose(FileID);
    
    
elseif strcmp(mode,'reset')
    f = strrep(f,'simulation geometry = phantom','#simulation geometry = phantom');
    f = strrep(f,'#simulation geometry = blank_phantom','simulation geometry = blank_phantom');
    str_step = ['step = ',num2str(step)];
    str_rotation = ['y-rotation = ',num2str(rotation)];
    f = strrep(f,rep_Rot_str,str_rotation);
    f = strrep(f,rep_Step_str,str_step);
    
    %% save the updated input files
    FileID = fopen(erase(join([FileName2]),' '),'w');
    fprintf(FileID,'%s',f);
    fclose(FileID);
    
end


