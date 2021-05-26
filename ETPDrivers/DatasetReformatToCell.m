% This script will take in a folder and convert all of its MAT files that contains EEGLab epoched data into a cell-array version
% Run this file from EEGCognitionPrediction/

% Import utilities to convert to cell array
addpath(strcat(pwd, '/../ETPAlgorithm/utilities'));

% TODO: Place all dataset and task names into a list and iterate through them
datasetName = 'PVT';
inputFolder = strcat(pwd, '/../Datasets/', datasetName, '/Rest/EpochedData/');
outputFolder = strcat(pwd, '/../Datasets/', datasetName, '/Rest/CellData/');

files = dir(inputFolder);
for i = 1:length(files)
	fileName = files(i).name;
	if(endsWith(fileName, 'DATA.mat'))
		filePath = strcat(inputFolder, fileName);
		EEG = load(filePath);
		cellData = ConvertToCellArray(EEG.data, 0); % 0 represents we're not removing any points
		cellFileName = strrep(fileName, 'DATA.mat', 'CELLDATA.mat');
		cellFilePath = strcat(outputFolder, cellFileName);
		save(cellFilePath, 'cellData');
	end
end