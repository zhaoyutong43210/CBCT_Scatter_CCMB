function write_IAEA_PHSP(data_ascii,file_name)

if nargin < 1
file_name = 'Varian_cbct_120kv'; 
load('CBCT_source_IAEA_PHSP.mat')
end

T = uint8(data_ascii(:,1));
E = ascii2binary(data_ascii(:,2))';
X = ascii2binary(data_ascii(:,3))';
Y = ascii2binary(data_ascii(:,4))';
U = ascii2binary(data_ascii(:,6))';
V = ascii2binary(data_ascii(:,7))';
Wt = ascii2binary(data_ascii(:,9))';

data_binary = [T,E,X,Y,U,V,Wt];
data_write = reshape(data_binary',[1,numel(data_binary)]);

headerinfo.RECORD_LENGTH = size(data_binary,2);
headerinfo.PARTICLES = size(data_ascii,1);
headerinfo.PHOTONS = headerinfo.PARTICLES;
headerinfo.ELECTRONS = 0;
headerinfo.POSITRONS = 0;
headerinfo.BYTE_ORDER = 1234;
headerinfo.CHECKSUM = numel(data_binary);
headerinfo.FILE_TYPE =0;
headerinfo.constantZ = unique(data_ascii(:,5));
headerinfo.ORIG_HISTORIES = 3e7;
headerinfo.TITLE = 'Varian TrueBeam Cone-Beam CT 120kV Throax measurement';
headerinfo.IAEA_INDEX = '001';

% GLOBAL_PHOTON_ENERGY_CUTOFF
% GLOBAL_PARTICLE_ENERGY_CUTOFF

%% write binary file
fileID = fopen([file_name,'.IAEAphsp'],'w');
fwrite(fileID,data_write);
fclose(fileID);
%% write header file
fileID = fopen([file_name,'.IAEAheader'],'w');
write_phspheader(fileID,headerinfo)
fclose(fileID);

end
% =========================================================================
% =========================================================================
function data_binary = ascii2binary(data_ascii)

    data_bi = typecast(single(data_ascii),'uint8');
    data_binary = reshape(data_bi,[4,size(data_ascii,1)]);

    a = typecast(single(data_ascii(1)),'uint8');
    b = data_binary(:,1)';
    if a ~= b
       warning('the typecast is different!') 
    end
end
% =========================================================================
% =========================================================================
function write_phspheader(fileID,info)

fprintf(fileID,'$IAEA_INDEX:\n');
fprintf(fileID,[info.IAEA_INDEX,' \n']);
fprintf(fileID,'\n');

fprintf(fileID,'$TITLE:\n');
fprintf(fileID,[info.TITLE,' \n']);
fprintf(fileID,'\n');

fprintf(fileID,'$FILE_TYPE:\n');
fprintf(fileID,[num2str(info.FILE_TYPE),' \n']);
fprintf(fileID,'\n');

fprintf(fileID,'$CHECKSUM:\n');
fprintf(fileID,[num2str(info.CHECKSUM),' \n']);
fprintf(fileID,'\n');

fprintf(fileID,'$RECORD_CONTENTS:\n');
fprintf(fileID,['\t',num2str(1),'\t // X is stored ? \n']);
fprintf(fileID,['\t',num2str(1),'\t // Y is stored ? \n']);
fprintf(fileID,['\t',num2str(0),'\t // Z is stored ? \n']);
fprintf(fileID,['\t',num2str(1),'\t // U is stored ? \n']);
fprintf(fileID,['\t',num2str(1),'\t // V is stored ? \n']);
fprintf(fileID,['\t',num2str(1),'\t // W is stored ? \n']);
fprintf(fileID,['\t',num2str(1),'\t // Weight is stored ? \n']);
fprintf(fileID,['\t',num2str(0),'\t // Extra floats is stored ? \n']);
fprintf(fileID,['\t',num2str(0),'\t // Extra longs is stored ? \n']);
fprintf(fileID,'\n');

fprintf(fileID,'$RECORD_CONSTANT:\n');
fprintf(fileID,['\t ',num2str(info.constantZ),' // Constant Z\n']);
fprintf(fileID,'\n');

fprintf(fileID,'$RECORD_LENGTH:\n');
fprintf(fileID,[num2str(info.RECORD_LENGTH),' \n']);
fprintf(fileID,'\n');

fprintf(fileID,'$BYTE_ORDER:\n');
fprintf(fileID,[num2str(info.BYTE_ORDER),' \n']);
fprintf(fileID,'\n');

fprintf(fileID,'$ORIG_HISTORIES:\n');
fprintf(fileID,[num2str(info.ORIG_HISTORIES),' \n']);
fprintf(fileID,'\n');

fprintf(fileID,'$PARTICLES:\n');
fprintf(fileID,[num2str(info.PARTICLES),' \n']);
fprintf(fileID,'\n');

fprintf(fileID,'$PHOTONS:\n');
fprintf(fileID,[num2str(info.PHOTONS),' \n']);
fprintf(fileID,'\n');

fprintf(fileID,'$ELECTRONS:\n');
fprintf(fileID,[num2str(info.ELECTRONS),' \n']);
fprintf(fileID,'\n');

fprintf(fileID,'$POSITRONS:\n');
fprintf(fileID,[num2str(info.POSITRONS),' \n']);
fprintf(fileID,'\n');

fprintf(fileID,'$TRANSPORT_PARAMETERS:\n');
fprintf(fileID,'X-ray non-isotropic source generated according to measured images\n');
fprintf(fileID,'\n');

fprintf(fileID,'$MONTE_CARLO_CODE_VERSION:\n');
fprintf(fileID,'Varian TrueBeam Cone-Beam CT Throax measurement from X-ray images \n');
fprintf(fileID,'\n');

fprintf(fileID,'$MACHINE_TYPE:\n');
fprintf(fileID,'Varian TrueBeam 2.0 with 360 degrees (895 projections) \n');
fprintf(fileID,'\n');

fprintf(fileID,'$GLOBAL_PHOTON_ENERGY_CUTOFF:\n');
fprintf(fileID,['  ',char(num2str(0.00001))]);
fprintf(fileID,'\n');

fprintf(fileID,'$GLOBAL_PARTICLE_ENERGY_CUTOFF:\n');
fprintf(fileID,['  ',char(num2str(0.00001))]);
fprintf(fileID,'\n\n');

fprintf(fileID,'$COORDINATE_SYSTEM_DESCRIPTION:\n');
fprintf(fileID,'Cartesian, right-handed:\n');
fprintf(fileID,'\n');
%%
fprintf(fileID,'//  OPTIONAL INFORMATION\n');
fprintf(fileID,'\n');
fprintf(fileID,'$BEAM_NAME:\n');
fprintf(fileID,'\n');

fprintf(fileID,'\n');
fprintf(fileID,'$FIELD_SIZE:\n');
fprintf(fileID,'5 mm IRIS collimator\n');
fprintf(fileID,'\n');

fprintf(fileID,'\n');
fprintf(fileID,'$NOMINAL_SSD:\n');
fprintf(fileID,'\n');

fprintf(fileID,'\n');
fprintf(fileID,'$MC_INPUT_FILENAME:\n');
fprintf(fileID,'\n');

fprintf(fileID,'\n');
fprintf(fileID,'$VARIANCE_REDUCTION_TECHNIQUES:\n');
fprintf(fileID,'\n');

fprintf(fileID,'\n');
fprintf(fileID,'$INITIAL_SOURCE_DESCRIPTION:\n');
fprintf(fileID,'\n');

fprintf(fileID,'\n');
fprintf(fileID,'$PUBLISHED_REFERENCE:\n');
fprintf(fileID,'\n');

fprintf(fileID,'\n');
fprintf(fileID,'$AUTHORS:\n');
fprintf(fileID,'\n');

fprintf(fileID,'\n');
fprintf(fileID,'$AUTHORS:\n');
fprintf(fileID,'Yutong Zhao\n');
fprintf(fileID,'\n');

fprintf(fileID,'\n');
fprintf(fileID,'$INSTITUTION:\n');
fprintf(fileID,'Medical Physics, CancerCare Manitoba, Winnipeg, Manitoba, Canada\n');
fprintf(fileID,'\n');

fprintf(fileID,'\n');
fprintf(fileID,'$LINK_VALIDATION:\n');
fprintf(fileID,'\n');

fprintf(fileID,'\n');
fprintf(fileID,'$ADDITIONAL_NOTES:\n');
fprintf(fileID,'\n');

fprintf(fileID,'\n');
fprintf(fileID,'$STATISTICAL_INFORMATION_PARTICLES:\n');
fprintf(fileID,'//\t\tWeight\t\tWmin\t\tWmax\t\t<E>\t\tEmin\t\tEmax\t\tParticle\n');
fprintf(fileID,'  \t\t100\t\tWmin\t\tWmax\t\t<E>\t\tEmin\t\tEmax\t\tParticle\n');

fprintf(fileID,'\n');

fprintf(fileID,'\n');
fprintf(fileID,'$STATISTICAL_INFORMATION_GEOMETRY:\n');
fprintf(fileID,'\n');
end