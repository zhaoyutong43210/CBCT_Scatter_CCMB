function [Ktotal,Katt,Kscatt,svPath] = read_egsmap_parallel(egsmap_path,egsmap_name,Size_Scoring,mode)
%read_egsmap2 Import numeric data from a egsmap file as a matrix.
%   EXAMPLEHEAD = IMPORTFILE(FILENAME) Reads data from text file FILENAME
%   for the default selection.
%
%   EXAMPLEHEAD = IMPORTFILE(FILENAME, STARTROW, ENDROW) Reads data from
%   rows STARTROW through ENDROW of text file FILENAME.
%
% Example:
%   examplehead = importfile('example_head.egsmap', 1, 65538);
%
%    See also TEXTSCAN.




%% read the egs phantom 
if nargin == 0 
egsmap_path = 'C:\EGSnrc-master\egs_home\egs_cbct\';
% egsmap_name = 'example_head.egsmap';
% egsmap_name = 'example_thorax.egsmap';
egsmap_name = uigetfile('*.egsmap');
Size_Scoring = [768, 1024]/4; % size of socring plane
mode = 2;
end 



%% Slow code start from Here
%% Read all the rows
startRow = 1;
endRow = inf;


%% Read columns of data as text:
% For more information, see the TEXTSCAN documentation.
formatSpec = '%*7s%13s%*4*s%*6*s%*3s%13s%*4*s%*6*s%*3s%13s%[^\n\r]';

%% Open the text file.
fileID = fopen(erase(join([egsmap_path,'\',egsmap_name]),' '),'r');

%% Read columns of data according to the format.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
textscan(fileID, '%[^\n\r]', startRow(1)-1, 'WhiteSpace', '', 'ReturnOnError', false);

dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', '', 'WhiteSpace', '', 'TextType', 'string', 'ReturnOnError', false, 'EndOfLine', '\r\n');
for block=2:length(startRow)
    frewind(fileID);
    textscan(fileID, '%[^\n\r]', startRow(block)-1, 'WhiteSpace', '', 'ReturnOnError', false);
    dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', '', 'WhiteSpace', '', 'TextType', 'string', 'ReturnOnError', false, 'EndOfLine', '\r\n');
    for col=1:length(dataArray)
        dataArray{col} = [dataArray{col};dataArrayBlock{col}];
    end
end

%% Close the text file.
fclose(fileID);

%% Convert the contents of columns containing numeric text to numbers.
% Replace non-numeric text with NaN.
raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
for col=1:length(dataArray)-1
    raw(1:length(dataArray{col}),col) = mat2cell(dataArray{col}, ones(length(dataArray{col}), 1));
end
numericData = NaN(size(dataArray{1},1),size(dataArray,2));

for col=[1,2,3]
    % Converts text in the input cell array to numbers. Replaced non-numeric
    % text with NaN.
    rawData = dataArray{col};
    for row=1:size(rawData, 1)
        % Create a regular expression to detect and remove non-numeric prefixes and
        % suffixes.
        regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
        try
            result = regexp(rawData(row), regexstr, 'names');
            numbers = result.numbers;
            
            % Detected commas in non-thousand locations.
            invalidThousandsSeparator = false;
            if numbers.contains(',')
                thousandsRegExp = '^\d+?(\,\d{3})*\.{0,1}\d*$';
                if isempty(regexp(numbers, thousandsRegExp, 'once'))
                    numbers = NaN;
                    invalidThousandsSeparator = true;
                end
            end
            % Convert numeric text to numbers.
            if ~invalidThousandsSeparator
                numbers = textscan(char(strrep(numbers, ',', '')), '%f');
                numericData(row, col) = numbers{1};
                raw{row, col} = numbers{1};
            end
        catch
            raw{row, col} = rawData{row};
        end
    end
end


%% Replace non-numeric cells with NaN
R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),raw); % Find non-numeric cells
raw(R) = {NaN}; % Replace non-numeric cells


%% Slow code End from Here
%% Create all Kerma Component 
% ref   (https://www.reddit.com/r/EGSnrc/comments/ikens3/egs_cbct_question_scatonlyscan/)

Ktotal = flip(reshape(cell2mat(raw(3:end, 1)),Size_Scoring)); 
Katt = flip(reshape(cell2mat(raw(3:end, 2)),Size_Scoring));
Kscatt = flip(reshape(cell2mat(raw(3:end, 3)),Size_Scoring));


if mode ==0
    svPath = erase(join([egsmap_path,'\Blank\']),' '); % define the save path for the Results
elseif mode == 1
    svPath = erase(join([egsmap_path,'\RawScan\']),' '); % define the save path for the Results
else
    svPath = erase(join([egsmap_path,'\']), ' '); % define the save path for the Results
end

if exist(svPath)~= 7  
    mkdir( svPath);
end



save(erase(join([svPath,erase(egsmap_name,'.egsmap')]),' '), 'Ktotal','Katt','Kscatt');

%% quick test 
fig = figure('Position',  [100, 100, 1600, 400]);
subplot(1,3,1);imfig(Ktotal);title('Ktotal');
subplot(1,3,2);imfig(Katt);title('Katt');
subplot(1,3,3);imfig(Kscatt);title('Kscatt');
print(fig,erase(join([svPath,erase(egsmap_name,'.egsmap'),'.png']),' '),'-dpng')
%close(fig)
% diff (Ktotal to Katt) & Kscatt
%figure
imfig(Ktotal-Katt,Kscatt); title('diff (Ktotal to Katt) & Kscatt');
%close(fig)



