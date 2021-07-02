
% This script will take random samples from Rest Data (500ms and 1000ms) to test
% if window lengths are issues are due to a lack of samples.
% This script attempts to fix the issue from a previous run by
% sampling 500ms blocks for training purposes and storing them in a
% cell array, and then sampling 500ms block for validation that are not
% necessarily adjacent to the train blocks.

% Import utilities to convert to cell array
% Should be run from EEGCognitionPrediction root folder with access to
% ETPAlgorithm in the parent folder
addpath(strcat(pwd, '/dependencies/CircStat2012a'));
addpath(strcat(pwd, '/../ETPAlgorithm/'));
addpath(strcat(pwd, '/../ETPAlgorithm/dependencies/fieldtrip-20201214'));
addpath(strcat(pwd, '/../ETPAlgorithm/utilities'));

datasetName = 'PVT';
inputFolder = strcat(pwd, '/../Datasets/', datasetName, '/Rest/TrueRestDataInMatFormat/');

% Configs
targetFreq = [8 13];
targetChannel = "Oz";
neighbors = ["O1", "O2", "POz", "PO3", "PO4"];

numEpochs = 100; % Number of epochs for rest (which includes training and validation)
epochList = [100, 200, 400, 800, 1600];

files = dir(inputFolder);

cellAngles = cell(length(epochList), 1);

means = zeros(1, length(epochList));
sds = zeros(1, length(epochList));
% For each subject

for i = 1:length(files)
    i
    fileName = files(i).name;
    if(endsWith(fileName, 'REST_DATA.mat'))
        filePath = strcat(inputFolder, fileName);
        EEG = load(filePath);
        halfSecond = fix(EEG.srate / 2);
        for ei = 1:length(epochList)
            ei
            numEpochs = epochList(ei);
            actualPhases = computeAngles(numEpochs, halfSecond, EEG, targetChannel, neighbors, targetFreq);
            cellAngles{ei} = actualPhases;
            means(ei) = circ_mean(actualPhases');
            sds(ei) = circ_std(actualPhases');
        end
       
        disp('test');
        
    end
end


disp('test');

function actualPhases = computeAngles(numEpochs, sampleLength, EEG, targetChannel, neighbors, targetFreq)
    electrodes = ExtractElectrodes(EEG.chanlocs, targetChannel, neighbors);
    len = size(EEG.data, 2);
    
    cellData = cell(numEpochs, 1);

    range = 1:(len - sampleLength);
    % Pull random samples
    for j = 1:numEpochs
        % Extract a random 500ms sample for a total of 1000 times
        randomStart = randsample(range, 1);
        randomWindow = EEG.data(:, randomStart:(randomStart + sampleLength - 1));
        cellData{j} = randomWindow;
    end
    
    % Run ETP on epoched data
    [cycleEstimate, actualPhases, actualPowers] = ETPTrainEpoch(cellData, 'TargetFreq', targetFreq, 'Electrodes', electrodes, 'SamplingRate', EEG.srate, ...
        'Graph', false);
end