% This script will run the ETP algorithm for each subject and block within
% a dataset and create .mat files that store the estimated phase angles and
% power at that point.

% The directory structure is different for task and rest datasets
% Example for task datasets: 
%   datasets\open_source_c_epoched\AB\not_chan_reduced\task
%   datasets\open_source_c_epoched\AB\not_chan_reduced\rest
% Of course, PVT is a little different as it is has both, so the ITIs are
% stored in 'pseudorest'

% Example for rest datasets: 
%   datasets\open_source_c_epoched\AB\not_chan_reduced\rest\test
%   datasets\open_source_c_epoched\AB\not_chan_reduced\rest\train

addpath(strcat(pwd, '/../../ETPAlgorithm/dependencies/fieldtrip-20201214'));
addpath(strcat(pwd, '/../../ETPAlgorithm/utilities'));
addpath(strcat(pwd, '/../../ETPAlgorithm'));

% datasetNames = ["PVT" "ALPH" "B3" "COV" "AB"];
% AB ABS ALPH B3 COV ENS JAZZ PVT SENS TMS TRAN
taskDatasets = ["ALPH" "AB" "B3" "COV" "ENS"];
pseudoRestDatasets = ["PVT"];
restDatasets = ["ABS" "JAZZ" "PVTRest" "SENS" "TMS" "TRAN"];
allDatasets = [taskDatasets pseudoRestDatasets restDatasets];

for datasetIndex = 1:length(allDatasets)
    datasetName = allDatasets(datasetIndex);
    
    % Determine the right suffix depending on the dataset type
    inputSuffix = "";
    if(any(ismember(taskDatasets, datasetName)))
        inputSuffix = "/rest/";
    elseif(any(ismember(restDatasets, datasetName)))
        inputSuffix = "/rest/train/";
    else 
        % pseudorest
        inputSuffix = "/pseudorest/500/";
    end
    
    inputFolder = strcat(pwd, '/../../datasets/open_source_c_epoched/', datasetName, '/not_chan_reduced', inputSuffix, 'mat/');
    outputFolder = strcat(pwd, '/../../datasets/open_source_d_etp/', datasetName, '/all_epochs/train/');
    if ~exist(outputFolder, 'dir')
        mkdir(outputFolder);
    end
    
    files = dir(inputFolder);

    targetFreq = [8 13];
    targetChannel = "Oz";
    neighbors = ["O1", "O2", "Pz"];
    
    restLengths = [];

    for i = 1:length(files)
        fileName = files(i).name;

        if(~ endsWith(fileName, '.mat'))
           continue; 
        end
        filePath = strcat(inputFolder, fileName);

        EEG = load(filePath);
        % Sometimes the struct is saved instead of the fields
        if(isfield(EEG, 'EEG'))
           EEG = EEG.EEG; 
        end
        
        electrodes = ExtractElectrodes(EEG.chanlocs, targetChannel, neighbors);
        % check if missing electrodes and skip
        if(electrodes(1) == -1 || size(electrodes, 2) ~= size(neighbors, 2) + 1)
            disp(sprintf("%s missing electrodes", fileName));
            continue;
        end
        
        % only non-rest datasets need to be converted to cell array, as rest
        % datasets are already converted (check ETPSplitRest)
        originalData = EEG.data;
        if(~ any(ismember(restDatasets, datasetName)))
            EEG.data = ConvertToCellArray(EEG.data, 0);
        end
    
        [cycleEstimate, actualPhases, actualPowers] = ETPTrainEpoch(EEG.data, 'TargetFreq', targetFreq, 'Electrodes', electrodes, 'SamplingRate', EEG.srate, ...
                'Graph', false);

        output = struct('cycleEstimate', cycleEstimate, 'actualPhases', actualPhases, 'actualPowers', actualPowers);

        outputFileName = strrep(fileName, 'DATA', 'PHASES');
        outputFilePath = strcat(outputFolder, outputFileName);
        save(outputFilePath, 'output');
        
        restLengths = [size(EEG.data{1}, 2), restLengths];

    end
    
    datasetName
    unique(restLengths)
    EEG.srate
    
end


