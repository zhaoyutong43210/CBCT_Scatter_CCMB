function batfilename = generate_batch_file(filename,egsinp,pegsfile,path)


if nargin < 1
Script= 'egs_cbct -i example_head.egsinp -p fax06';
end

Script = join(['egs_cbct -i ', egsinp, ' -p ', pegsfile]);

fid = fopen([path,'myBatchFile_rotation_',filename,'.bat'],'w');
fprintf(fid,'%s\n','set path=%path:C:\Program Files\MATLAB\R2018a\bin\win64;=%');
fprintf(fid,'%s\n', Script);
fclose(fid);

batfilename = [path,'myBatchFile_rotation_',filename,'.bat'];
end 