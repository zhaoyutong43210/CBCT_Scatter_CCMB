function generate_dicom_list


folder = struct2table(dir('*.dcm'));

folder = sortrows(folder,1);

namelist = string(folder{:,1});

fileID = fopen('throax','w');

fprintf(fileID,'%s\r\n',namelist);
fclose(fileID);

end