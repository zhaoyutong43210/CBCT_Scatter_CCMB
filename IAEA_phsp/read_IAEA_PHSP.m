function read_IAEA_PHSP

%%
myfile = uigetfile('*.IAEAphsp');

myfile_header = [erase(myfile,'IAEAphsp'),'IAEAheader'];

 header_content = fileread(myfile_header);
 
 
 CheckSumind = strfind(header_content,'CHECKSUM');
 
 CheckSum =  str2double(regexp(header_content(CheckSumind+10:end),'\d*','Match','once'));
 
 RECORD_LENGTHind = strfind(header_content,'RECORD_LENGTH');
 
 RECORD_LENGTH = str2double(regexp(header_content(RECORD_LENGTHind+15:end),'\d*','Match','once'));
 
 PARTICLESind = strfind(header_content,'PARTICLES');
 
 PARTICLES = str2double(regexp(header_content(PARTICLESind+11:end),'\d*','Match','once'));
 
 Record_constind = strfind(header_content,'RECORD_CONSTANT:');
 
 str = header_content(Record_constind+strlength('RECORD_CONSTANT:')+1:RECORD_LENGTHind-3);
 constind= strfind(str,'Constant');
 Record_const = cell2mat(regexpi(str(constind + strlength('Constant'):end),'\w','match'));
 Record_const_val = str2double(cell2mat(regexpi(str(1:constind),'\d+.?\d*','match')));
 %%
fileID = fopen(myfile);

prec = 'uint8=>single';
sizeA = (CheckSum)+1e3;
machinefmt = 'b'; % Big Eidan ordering %% 's' Big-endian ordering, 64-bit long data type

A = fread(fileID,sizeA,prec,machinefmt);

if (size(A,1) - (CheckSum))~=0
   disp('CheckSum number does not agree with the IAEAphsp file, please double check the file')
else
    disp('CheckSum passed! The file length is legal. ')
    particlesum = CheckSum/RECORD_LENGTH;
end

if RECORD_LENGTH*PARTICLES == CheckSum
    disp('(partical number) * (record length) passed! The file length is legal. ')
else
   disp('(partical number) * (record length) does not agree with the IAEAphsp file, please double check  the file')
end

if particlesum == PARTICLES 
    disp('(particlesum) = (PARTICLES in header) passed! The file length is legal. ')
else
    disp(['recorded PARTICLES = ',char(num2str(particlesum)),'. The PARTICLES in header = ',char(num2str(PARTICLES))])
    PARTICLES = particlesum;
end
B = reshape(A,[RECORD_LENGTH, PARTICLES]);

data_ascii = zeros(size(B,2),9);
progress = 0;
tic
L = (RECORD_LENGTH-1)/4;

id = 1;
ind.type = id;
id = id+1;

ind = set_ind(Record_const,ind,id);

for n1 = 1:size(B,2)
% please see reference (https://en.wikipedia.org/wiki/Bit_numbering#Unsigned_integer_example)
data = uint8(B(:,n1));

if n1 > size(B,2)* progress
    disp([num2str(progress*100),'%'])
    progress = progress+0.01;
end

data_particle = getparticle_data(ind,data, Record_const, Record_const_val);
data_ascii(n1,:) = data_particle;

end

save([char(erase(myfile,'IAEAphsp')),'mat'],'-v7.3')

toc
%%   plot the result to show E, X-Y and U-V
     subplot(1,3,1)
     histogram(data_ascii(:,2));
     xlabel('Energy(MeV)')
     ylabel('Cont#')
     title('Energy spectrum')
     
     subplot(1,3,2)     
     [N,c] = hist3((data_ascii(:,[3,4])),'Nbins',[100,100]);
     imagesc(c{1},c{2},log(N))
     xlabel('x(cm)')
     ylabel('y(cm)')
     daspect([1 1 1])
     caxis([0 13])
     colorbar
     title('X-Y distribution')
     
     subplot(1,3,3)
     [N2,c2] = hist3(data_ascii(:,[6,7]),'Nbins',[100,100]);
     imagesc(c2{1},c2{2},log(N2))
     colorbar
     daspect([1 1 1])
     xlabel('u(cos_x)')
     ylabel('v(cos_y)')
     title('Direction cosine')

end
% =========================================================================
% =========================================================================
function ind = set_ind(Record_const,ind,id)
[ind,id] = setid('E',Record_const,ind,id);
[ind,id] = setid('X',Record_const,ind,id);
[ind,id] = setid('Y',Record_const,ind,id);
[ind,id] = setid('Z',Record_const,ind,id);
[ind,id] = setid('U',Record_const,ind,id);
[ind,id] = setid('V',Record_const,ind,id);
[ind,~] = setid('Weight',Record_const,ind,id);

% if id < RECORD_LENGTH
%     
% elseif id == RECORD_LENGTH
%     
% else 
%     error;
% end
end
% =========================================================================
% =========================================================================
function [ind,id] = setid(Cor,Record_const,ind,id)

if Record_const ~= Cor
    ind.(Cor) = id:id+3;
    id = id+4;
else 
    ind.(Cor) = NaN;
end 

end
% =========================================================================
% =========================================================================
function D = getdata(Cor,ind,data, Record_const, Record_const_val)
if Record_const ~= Cor
    D  =  typecast(data(ind.(Cor)),'single');
else
    D  = Record_const_val;
end
end 
% =========================================================================
% =========================================================================
function data_particle = getparticle_data(ind,data, Record_const, Record_const_val)

type = double(data(ind.type));
E   = abs(getdata('E',ind,data, Record_const, Record_const_val));
X   = getdata('X',ind,data, Record_const, Record_const_val);
Y   = getdata('Y',ind,data, Record_const, Record_const_val);
Z   = getdata('Z',ind,data, Record_const, Record_const_val);
U   = getdata('U',ind,data, Record_const, Record_const_val);
V   = getdata('V',ind,data, Record_const, Record_const_val);
Wt  = getdata('Weight',ind,data, Record_const, Record_const_val);
%Latch = logical(sign(E)-1);

W = (sqrt(1-(U.^2)-(V.^2)));
if ~isreal(W)
    warning('the directional cosines over 1, cause complex values! Check your ind variable')
    W = abs(W);
end
data_particle = [type, E, X, Y, Z, U, V, W, Wt];
end
% =========================================================================
% =========================================================================