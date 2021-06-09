% This script will take random samples from Rest Data (500ms and 1000ms) to test
% if window lengths are issues are due to a lack of samples.
% This script attempts to fix the issue from a previous run by
% sampling 500ms blocks for training purposes and storing them in a
% cell array, and then sampling 500ms block for validation that are not
% necessarily adjacent to the train blocks.

% Import utilities to convert to cell array
% Should be run from EEGCognitionPrediction root folder with access to
% ETPAlgorithm in the parent folder
addpath(strcat(pwd, '/../ETPAlgorithm/'));
addpath(strcat(pwd, '/../ETPAlgorithm/dependencies/fieldtrip-20201214'));
addpath(strcat(pwd, '/../ETPAlgorithm/utilities'));

datasetName = 'PVT';
inputFolder = strcat(pwd, '/../Datasets/', datasetName, '/Rest/TrueRestDataInMatFormat/');

% Configs
targetFreq = [8 13];
targetChannel = "Oz";
neighbors = ["O1", "O2", "POz", "PO3", "PO4"];

numEpochs = 200; % Number of epochs for rest and validation
cellData = cell(numEpochs, 1);

files = dir(inputFolder);
% For each subject
for i = 1:length(files)
	fileName = files(i).name;
	if(endsWith(fileName, 'REST_DATA.mat'))
		filePath = strcat(inputFolder, fileName);
		EEG = load(filePath);
        electrodes = ExtractElectrodes(EEG.chanlocs, targetChannel, neighbors);
        
        allPhases = [];
        len = size(EEG.data, 2);
        halfSecond = fix(EEG.srate / 2);
        fullSecond = EEG.srate;
        range = 1:(len - halfSecond);
        % Pull random samples
        for j = 1:numEpochs
            % Extract a random 500ms sample for a total of 1000 times
            randomStart = randsample(range, 1);
            randomWindow = EEG.data(:, randomStart:(randomStart + halfSecond - 1));
            cellData{j} = randomWindow;
        end
        
        % Run ETP on epoched data
        [cycleEstimate, actualPhases, actualPowers] = ETPTrainEpoch(cellData, 'TargetFreq', targetFreq, 'Electrodes', electrodes, 'SamplingRate', EEG.srate, ...
            'Graph', false);
        figure;
        polarhistogram(wrapTo2Pi(actualPhases),36);
	end
end