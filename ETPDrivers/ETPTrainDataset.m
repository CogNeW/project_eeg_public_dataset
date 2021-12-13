% This script will run the ETP algorithm for each subject and block within
% a dataset and create .mat files that store the estimated phase angles and
% power at that point.

addpath(strcat(pwd, '/../ETPAlgorithm/dependencies/fieldtrip-20201214'));
addpath(strcat(pwd, '/../ETPAlgorithm/utilities'));
addpath(strcat(pwd, '/../ETPAlgorithm'));

% datasetNames = ["PVT" "ALPH" "B3" "COV" "AB"];
% AB ABS ALPH B3 COV ENS JAZZ PVT SENS TMS TRAN
taskDatasets = ["AB" "ALPH" "B3" "COV" "ENS" "TRAN"];
pseudoRestDatasets = ["PVT"];
restDatasets = ["ABS" "JAZZ" "PVT" "SENS" "TMS"];

restFolders = ["pseudorest" "rest" "rest" "rest" "rest"];
timeIntervals = ["500/" "" "" "" ""];

for datasetIndex = 1:length(datasetNames)
    datasetName = datasetNames(datasetIndex);
    datasetRest = restFolders(datasetIndex);
    timeInterval = timeIntervals(datasetIndex);
    inputFolder = strcat(pwd, '/../datasets/open_source_c_epoched/', datasetName, '/not_chan_reduced/', datasetRest, '/', timeInterval, 'mat/');
    outputFolder = strcat(pwd, '/../datasets/open_source_d_etp/', datasetName, '/all_epochs/train/');

    files = dir(inputFolder);

    targetFreq = [8 13];
    targetChannel = "Oz";
    neighbors = ["O1", "O2", "Pz"];

    for i = 1:length(files)
        fileName = files(i).name;

        if(~ endsWith(fileName, '.mat'))
           continue; 
        end
        filePath = strcat(inputFolder, fileName);

        EEG = load(filePath);

        electrodes = ExtractElectrodes(EEG.chanlocs, targetChannel, neighbors);
        % check if missing electrodes and skip
        if(size(electrodes, 2) ~= size(neighbors, 2) + 1)
            print(sprintf("%s missing electrodes", fileName));
            continue;
        end

        originalData = EEG.data;
        cellData = ConvertToCellArray(originalData, 0); % ETPTrainEpoch assumes data is in cell array (so that later we can have variable length epochs)

        [cycleEstimate, actualPhases, actualPowers] = ETPTrainEpoch(cellData, 'TargetFreq', targetFreq, 'Electrodes', electrodes, 'SamplingRate', EEG.srate, ...
                'Graph', false);

        output = struct('cycleEstimate', cycleEstimate, 'actualPhases', actualPhases, 'actualPowers', actualPowers);

        outputFileName = strrep(fileName, 'DATA', 'PHASES');
        outputFilePath = strcat(outputFolder, outputFileName);
        save(outputFilePath, 'output');

    end
end


