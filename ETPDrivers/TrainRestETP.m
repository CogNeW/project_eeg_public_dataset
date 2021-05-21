% This script will run ETPTrainEpoch on a dataset for all subjects, 
% then return the aggregated rose plots across all subjects

% Run the folder from the root of EEGCognitionPrediction

% Import utilities to convert to cell array
addpath(strcat(pwd, '/../ETPAlgorithm/'));
addpath(strcat(pwd, '/../ETPAlgorithm/dependencies/fieldtrip-20201214'));
addpath(strcat(pwd, '/../ETPAlgorithm/utilities'));

% TODO: Place all dataset and task names into a list and iterate through them
datasetName = 'PVT';
inputFolder = strcat(pwd, '/../Datasets/', datasetName, '/Rest/CellData/');

% Configs

% Change Sampling Rate and electrodes
samplingRate = 250;
targetFreq = [8 13];
targetChannel = "Oz";
neighbors = ["O1", "O2", "POz", "PO3", "PO4"];

% Look at the channel locations for PVT_S11_D9_REST_CELLDATA.mat
% Get the results for the later 500 ms

files = dir(inputFolder);
allPhases = [];
for i = 1:length(files)
	fileName = files(i).name;
	if(endsWith(fileName, 'CELLDATA500.mat'))
		filePath = strcat(inputFolder, fileName);
		EEG = load(filePath);
        electrodes = ExtractElectrodes(EEG.chanlocs, targetChannel, neighbors);
		[cycleEstimate, actualPhases, actualPowers] = ETPTrainEpoch(EEG.data, 'TargetFreq', targetFreq, 'Electrodes', electrodes, 'SamplingRate', samplingRate, ...
            'Graph', false);
		allPhases = [allPhases actualPhases];
	end
end

figure;
polarhistogram(wrapTo2Pi(allPhases),36);