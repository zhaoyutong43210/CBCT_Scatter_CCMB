function egscbct_data_process(Scoring,egsmap_path)

if nargin == 1
    egsmap_path  = uigetdir;
elseif nargin<1
    egsmap_path  = uigetdir;
    Scoring = [768 1024]/4;
end
data_files = struct2table(dir([egsmap_path,'\*.egsmap']));
%scoring = MCgeo

for n = 1:height(data_files)
    
    egsmap_name = string(data_files{n,1});
    fig_name = [char(erase(egsmap_name,'.egsmap')),'.png'];
    
    if ~isfile(fig_name)
    close all
    disp(['processing: ',char(egsmap_name)])
    read_egsmap_parallel(egsmap_path,egsmap_name,Scoring,2);
    disp(['Finished : ',char(egsmap_name)])
    end
end

close all
end
