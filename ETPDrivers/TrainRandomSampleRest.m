% This script will take random samples from Rest Data (500ms and 1000ms) to test
% if window lengths are issues are due to a lack of samples.
% The issue with this script is that the 500ms used for training is
% directly adjacent to those used for validation, which leads to higher
% correlation and likely accuracy.

% Import utilities to convert to cell array
addpath(strcat(pwd, '/../ETPAlgorithm/'));
addpath(strcat(pwd, '/../ETPAlgorithm/dependencies/fieldtrip-20201214'));
addpath(strcat(pwd, '/../ETPAlgorithm/utilities'));

datasetName = 'PVT';
inputFolder = strcat(pwd, '/../Datasets/', datasetName, '/Rest/TrueRestDataInMatFormat/');

% Configs
targetFreq = [8 13];
targetChannel = "Oz";
neighbors = ["O1", "O2", "POz", "PO3", "PO4"];

files = dir(inputFolder);
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
        range = 1:(len - fullSecond);
        for j = 1:10
            % Extract a random 500ms sample for a total of 1000 times
            randomStart = randsample(range, 1);
            randomWindow = EEG.data(:, randomStart:(randomStart + fullSecond - 1));
            [cycleEstimate, actualPhases] = ETPTrain(randomWindow, 'TargetFreq', targetFreq, 'Electrodes', electrodes, 'SamplingRate', EEG.srate, ...
            'Graph', false, 'RestLength', 1, 'TrainLength', .5);
            allPhases = [allPhases actualPhases];
            j
        end
        
        figure;
        polarhistogram(wrapTo2Pi(allPhases),36);
		disp('test');
	end
end