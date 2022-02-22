function egsmdata_synchronization(path)

if nargin <1 
    
    path = uigetdir;
end 


data_files = struct2table(dir([path,'\Clinical*.mat']));

fns = string(table2array(data_files(:,1)));

fnsnew = sortbyindex(fns);

data_synT = [];
data_synA = [];
data_synS = [];

for n = 1:length(fnsnew)
    
    data = load([path,'/',char(fns(n))]);
    
    data_synT(:,:,n) = data.Ktotal;
    data_synA(:,:,n) = data.Katt;
    data_synS(:,:,n) = data.Kscatt;
end

save([path,'\EGScbct_wholedata.mat'],'data_synT','data_synA','data_synS','fnsnew','-v7.3')
end

function fnsnew = sortbyindex(fns)
strcom = Common_Strings_in_Char(char(fns(:)));    % Find the Commen strings in File names array
[~,~,ext] = fileparts(fns(1,1));                  % Get the file extension
fns(:,2) = (erase(fns(:,1),[strcom,ext]));        % erase the common str & extension, 
                                                  % now the left should be the number index. 
num_val = (regexp(fns(:,2),'\d*','match','once'));
num_val(ismissing(num_val))='';

numind = str2double(num_val);
[~,ind] = sort(numind);                 % sort by num(double value) instead of string

fnsnew = fns(ind,1);                              % now everything is in a neat way; enjoy :)
end
% ======================================================================= %
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