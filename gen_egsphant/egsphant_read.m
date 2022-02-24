function egsphant_read


%path = 'C:\EGSnrc-master\egs_home\egs_cbct\CT_cCTthorax.egsphant';


path ='C:\Users\MedPhys\Dropbox\CCMB_DeepLearning_CBCT_project\CT_CTProstate.egsphant';
mode = 'HU values';% 'material catergory' or 'HU values'


C = extractFileText(path);
newStr = splitlines(C);

%%
switch mode
%%    
    case 'material catergory'
    
Phantom = [];
nn=1;
strarray=[];
for n = 1:length(newStr)
    
    str = newStr(n);
    
    if strlength(str) == 80
        
        strlines = (mystrsplit((str)));
        strarray = [strarray;strlines];
    elseif strlength(str) ==0
        
        try
        Phantom(:,:,nn)=strarray;
        nn = nn+1;
        imagesc(str2double(strarray));axis xy;caxis([1 5]);drawnow
        strarray=[];
        catch
        end
    end
end

%%
    case 'HU values' 
%%      
Phantom = [];
nn=1;
strarray=[];
trigger = false;
for n = 1:length(newStr)
    
    str = newStr(n);
    
    if strlength(str) == 680
        
        strlines = str2double(strsplit(str,' '));
        strlines(isnan(strlines))=[];
        
        strarray = [strarray;strlines];
        trigger = true;
    elseif strlength(str) ==0 && trigger
        
        try
        Phantom(:,:,nn)=strarray;
        nn = nn+1;
        imagesc((strarray));axis xy;drawnow
        strarray=[];
        catch
        end
    end
end
%%
end 

save('EGSphantom.mat','Phantom');

% now visulize through Z-axis
cmax = max(Phantom(:));
cmin = min(Phantom(:));
v = VideoWriter('MyCTPhantom_Zslices.avi');
open(v)
    for n1 = size(Phantom,1):-1:1
        imagesc(squeeze(Phantom(n1,:,:))');caxis([cmin cmax]);axis xy;colormap(gray);
        axis off
        drawnow
        
        writeVideo(v,getframe(gcf))
    end 
end
% =========================================================================
function str = mystrsplit(strinp)
% =========================================================================
% This function split every digit in a series of large string numbers when
% it does not have any deliminators. This is super usefull for category
% probelms.
% =========================================================================
str = strings(1,strlength(strinp));
z = char(strinp);
    for n = 1:strlength(strinp)
    str(1,n) = z(n);
    end
end