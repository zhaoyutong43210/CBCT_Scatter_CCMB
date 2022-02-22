function egscbct_parallel(geo,angles)

 fpath = fileparts(which(mfilename));
 
 continue_a_existing_simulation = true;
 
 if continue_a_existing_simulation
     file_name = 'EGScbct_Simulation_02Feb2022153541.mat';
     load(file_name)
 else

%% Some introduction of this code
%
% This is base on the code of Kaiming Guo of simulating the CBCT, this code
% is intend to make the code capable of doing parallel computing
%
% Yutong Zhao
%
% MUST START with the blank_phantom (KEY)
%
%
% In Form of:
%            %     #simulation geometry = phantom        # use this one for real scans
%            %     simulation geometry = blank_phantom # use this one first to create blank scan
%        %
%
% 
% since the scan will be done in the same manner, therefore we need to
% manually adjust the most geometry scan in the egs_cbct input files
% "*.egsinp", and make sure include rotation and set it to "0"; 
%    
%    % A.1 define the roation and its step (the following three varible should add in the input files)
% % %   
    % % % % % % % % % % % % % % % % % % % 
    % Please Refer to the initial seet value on *.egsinp
    %   :start cbct setup:
    %       orbit = 360.0 
    %       step  = 45     <--
    %       y-rotation = 0 <--
    %   :stop cbct setup:  
    % % % % % % % % % % % % % % % % % % %
    
    % Initial_setting on the step or y-rotations
    
%% Step # 1 Parameter defination

    Size_Scoring = geo.nDetector/geo.downsamplingfactor;
    pegsfile = '521icru.pegs4dat';    
    %pegsfile = 'fax06.pegs4dat';
    
    angled = wrapTo360(unique(angles/pi*180)); % in degree not radians
%     [Ri, Si]= deal(0, 45);
%     rep_Rot_str = ['y-rotation = ', num2str(Ri)];
%     rep_Step_str = ['step  = ',num2str(Si)];

    orbit = 360; 
    step = 1; % increment of ratation angle
    rotation = angled; % rotation angle
    
    % selection the egsinp file for egs_cbct
    PathName = ['C:\EGSnrc-master\egs_home\egs_cbct\'];
    FileName = uigetfile([PathName,'*.egsinp']);
    %egsmap_name = strrep(FileName,'egsinp','egsmap');
    fprintf(['Current Working *.egsinp File is  ---  ', FileName,'\n']);

%% Step # 2 Generate all egsnrc *.egsinp and .*bat files ready for simulation
%  including the Blank Phantom :)

egsfilenames = strings(length(rotation)+1,1); % one more for blank phantom
egsinppathout= strings(length(rotation)+1,1);
batfilename = strings(length(rotation)+1,1);


ret = erase(string(datetime(now,'ConvertFrom','datenum')),["-"," ",":"]); % run end time (ret) as a record of folder name


[~,fn,fnext] = fileparts(FileName); 
egsinppathin = [PathName,FileName];

generatedfile_path = PathName;
batchfile_path = [generatedfile_path,'\',char(ret),'\egsbatchs'];
logfile_path = [generatedfile_path,'\',char(ret),'\logfiles'];
egsinp_path = [generatedfile_path,'\',char(ret),'\egsinp'];
egsmap_path = [generatedfile_path,'\',char(ret),'\egsmap'];
egsdat_path = [generatedfile_path,'\',char(ret),'\egsdat'];

mkdir(logfile_path);
mkdir(batchfile_path);
mkdir(egsinp_path);
mkdir(egsmap_path);
mkdir(egsdat_path);

batchpath = [generatedfile_path,'',char(ret),'\egsbatchs\'];

    for i = 0: length(rotation)
        if i == 0  % generate blank phatom <<<Generate Blank Scan>>>
            egsfilenames(end) = [fn,'_BlankPhan',fnext];
            egsinppathout(end) = [generatedfile_path,char(egsfilenames(end))];
            %batchname = 
            generate_cbct_rotation_file(0,step,egsinppathin,egsinppathout(end),'reset');
            batfilename(end) = generate_batch_file('_BlankPhan',egsfilenames(end),pegsfile,batchpath);
        else
        %rot = rotation(i);
        egsfilenames(i) = [fn,'_rotation_', num2str(i),fnext];
        egsinppathout(i) = [generatedfile_path,char(egsfilenames(i))];
        
        generate_cbct_rotation_file(rotation(i),step,egsinppathin,egsinppathout(i),1);
        batfilename(i) = generate_batch_file(num2str(i),egsfilenames(i),pegsfile,batchpath);
        end
    end
    
save(['EGScbct_Simulation_',char(ret),'.mat'])
 end

%% Step # 3 Parallel computing for the egs simulations


 
 
parpool(30)

parfor  nn = 1:length(batfilename)
    
    bati = char(batfilename(nn));
    if ~isfile([generatedfile_path,char(erase(egsfilenames(nn),'.egsinp')),'.egsmap'])
     
     disp(['simu_file = ',bati])
     [status,cmdout] = dos(bati);
     pause(0.01)
     %% save log info to a txt file
     ind = strfind(bati,'\');
     log_name = [erase(bati(ind(end)+1:end),'.bat'),'_log.txt'];
        
        fid = fopen([logfile_path,'\',char(log_name)],'w');
        fprintf(fid, ['status = ',num2str(status),'\nlog_info = ',strrep(cmdout,'\','|')]);
        fclose(fid);
        if status ~= 0
             warning(['Simulation on ',bati,' has been detected a unnormal status with output = ',num2str(status)])
        end
%      else 
%       disp(['Simulation result on ',bati,' has already exist! Skip this simulation.'])
     end
 end

%% Step # 4 reset and move generated files into a folder, to keep a neat environment

for n = 1:length(batfilename)
    try
egsinp_pathold = [generatedfile_path,char(egsfilenames(n))];
egsmap_pathold = [generatedfile_path,char(erase(egsfilenames(n),'.egsinp')),'.egsmap'];
egsdat_pathold = [generatedfile_path,char(erase(egsfilenames(n),'.egsinp')),'.egsdat'];

%source5 = erase(join([erase(source2,'egsinp'),'txt']),' ');
%destination = erase(join([fpath,'\',archive_name]),' ');

movefile(egsinp_pathold,egsinp_path,'f');
movefile(egsmap_pathold,egsmap_path,'f');

if isfile(egsdat_pathold) 
movefile(egsdat_pathold,egsdat_path,'f');
end 

    catch 
    end
end 


save(['EGScbct_Simulation_',char(ret),'.mat'])
%% Step # 5 Analysis the results and save the figures in image files 
% This may be complish in another code.

egscbct_data_process(flip(Size_Scoring'),egsmap_path)

end

