function Varian_DCM_read
fn = (sortrows(struct2table(dir('*.dcm')),6));

fns = string(fn{:,1});
fns = sortbyindex(fns);

ReconData = [];

inds = (strfind(pwd,'\'));
path = pwd;
foldername= path(inds(end)+1:end);

v = VideoWriter(['PlannngCT_',foldername,'.avi']);

open(v)

for n = 1:length(fns)
file_name =string(fns{n,1});

info = dicominfo(file_name);
% dicomdisp(file_name);
X = dicomread(info);
imshow(X,[]);
%colorbar
drawnow

ReconData(:,:,n) = double(X);

 writeVideo(v,mat2gray(X))
 
end
close(v)
save(['Varian_PlanningCT_',foldername,'_Recon.mat'],'ReconData'); % save this for later use.
end 
% ======================================================================= %
function strnew = Common_Strings_in_Char(str)
       
    for n = 1:size(str,1)-1
        str1 = str(n,:);
        str2 = str(n+1,:);
        
       ind =  str1 == str2;
       if n==1
           inde = ind;
       else
           inde = inde & ind;
       end
       
    end
strnew = str(1,inde);
end
% ======================================================================= %
function fnsnew = sortbyindex(fns)
strcom = Common_Strings_in_Char(char(fns(:)));    % Find the Commen strings in File names array
[~,~,ext] = fileparts(fns(1,1));                  % Get the file extension
fns(:,2) = (erase(fns(:,1),[strcom,ext]));        % erase the common str & extension, 
                                                  % now the left should be the number index.                   
[~,ind] = sort(double(fns(:,2)));                 % sort by num(double value) instead of string

fnsnew = fns(ind,1);                              % now everything is in a neat way; enjoy :)
end
% ======================================================================= %
