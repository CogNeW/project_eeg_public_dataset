% This script will compare epoched predictions of rest data to unepoched versions of the same rest data
% The script will create contiguous 500ms epochs of rest data, and pass that through the ETP algorithm.
% The script will pass the unepoched dataset into the ETP algorithm.
% The script will then compare the predicted phase angles between the two conditions.

addpath(strcat(pwd, '/../ETPAlgorithm/dependencies/fieldtrip-20201214'));
addpath(strcat(pwd, '/../ETPAlgorithm/utilities'));
addpath(strcat(pwd, '/../ETPAlgorithm'));

noEpochAngles = [];
epochAngles = [];
noEpochCycleLength = [];
epochCycleLength = [];
targetFreq = [8 13];
targetChannel = "Oz";
neighbors = ["O1", "O2", "Pz"];

datasetName = "PVT";

rootFolder = strcat(pwd, '/../datasets/open_source_c_epoched/', datasetName, '/not_chan_reduced/rest/mat/');

files = dir(rootFolder);

pb = waitbar(0, 'Status bar...');

for i = 1:length(files)
    fileName = files(i).name;

    if(~ endsWith(fileName, '.mat'))
       continue; 
    end
    filePath = strcat(rootFolder, fileName);

    EEG = load(filePath);

    electrodes = ExtractElectrodes(EEG.chanlocs, targetChannel, neighbors);
    % check if missing electrodes and skip
    if(size(electrodes, 2) ~= size(neighbors, 2) + 1)
        print(sprintf("%s missing electrodes", fileName));
        continue;
    end

    data = EEG.data;
    [trainData, testData] = SplitRestData(data, "unepoched");

    % Use raw data for normal ETPTrain
    totalRestLength = fix(size(trainData, 2) / EEG.srate);
    cycleLength = ETPTrain(EEG.data, 'RestLength', totalRestLength, 'TrainLength', fix(totalRestLength / 2), 'TargetFreq', targetFreq, ...
        'Electrodes', electrodes, 'SamplingRate', EEG.srate);
    noEpochCycleLength = [noEpochCycleLength cycleLength];
    [~, targetTimes] = ETPTest(testData, cycleLength, 'SamplingRate', EEG.srate, 'TargetFreq', targetFreq, 'Electrodes', electrodes);
    targetTimes(targetTimes > length(testData)) = [];
    [~, noEpochPhases, noEpochPowers] = computeAccuracy(testData, 0, targetTimes, 'SamplingRate', EEG.srate, 'TargetFreq', targetFreq, ...
        'Electrodes', electrodes, 'Graph', false);

    noEpochAngles = [noEpochAngles noEpochPhases];

    % Convert data to epoched version and use appropriate functions
    epochedData = PartitionToCellArray(data, EEG.srate, 2000);
    [trainEpochedData, testEpochedData] = SplitRestData(epochedData, "epoched");
    [cycleEstimate, actualPhases, actualPowers] = ETPTrainEpoch(trainEpochedData, 'TargetFreq', targetFreq, 'Electrodes', electrodes, 'SamplingRate', EEG.srate, ...
                'Graph', false);
    epochCycleLength = [epochCycleLength cycleEstimate];
    [~, epochPhases, epochPowers] = computeEpochAccuracy(testEpochedData,  EEG.srate, targetFreq, cycleEstimate, electrodes);
    epochAngles = [epochAngles epochPhases];
    
    waitbar(i / length(files), pb);
end

disp('here');