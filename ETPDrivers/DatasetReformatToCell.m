% This script will take in a folder and convert all of its MAT files that contains EEGLab epoched data into a cell-array version
% Run this file from EEGCognitionPrediction/

% Import utilities to convert to cell array
addpath(strcat(pwd, '/../ETPAglorithm/utilities'));

datasetName = 'PVT';
inputFolder = strcat(pwd, '/../Datasets/', datasetName, '/Rest');

files = dir(inputFolder)
for i = 1:length(files)
	fileName = files(i).name
	if(endsWith(fileName, 'DATA.mat'))
		filePath = strcat(inputFolder, fileName);
		EEG = load(filePath);
		cellData = convertToCellArray(EEG.data);
		cellFileName = strrep(filePath, 'DATA.mat', 'DATA_CELL.mat');
		save(cellFileName, 'cellData');
	end
end