% This script will run the ETPTestEpoch algorithm and use the estimated
% interpeak interval from the training set to estimate future peaks in the
% task data.

% Quick note that the interpeak interval computed from the training portion
% is in terms of samples. To convert it to frequency, the sampling rate
% must be divided by that number


% Loop through each rest dataset
%   Find the appropriate one in test
%   Run test epoch, and get the predicted angles

% addpath(strcat(pwd, '/../../ETPAlgorithm/dependencies/fieldtrip-20201214'));
addpath(strcat(pwd, '/../../ETPAlgorithm/utilities'));
addpath(strcat(pwd, '/../../ETPAlgorithm'));

taskDatasets = ["ALPH" "AB" "B3" "COV" "ENS"];
pseudoRestDatasets = ["PVT"];
restDatasets = ["ABS" "JAZZ" "PVTRest" "SENS" "TMS" "MICRO"];
allDatasets = [taskDatasets pseudoRestDatasets restDatasets];
allDatasets= ["PVTRest"];

testThresholds = load('../SummaryStatistics/testIndividualTableAll.mat');
testThresholds = testThresholds.subjectTable;

completelyRejected = strings(0);

for datasetIndex = 1:length(allDatasets)
    
    datasetName = allDatasets(datasetIndex);

    % Determine the right suffix depending on the dataset type
    inputSuffix = "";
    if(any(ismember(restDatasets, datasetName)))
        inputSuffix = "/rest/test/";
    else
        inputSuffix = "/task/";
    end
    
    taskFolder = strcat(pwd, '/../../datasets/open_source_c_epoched/', datasetName, '/not_chan_reduced', inputSuffix, 'mat/');
    restIPIFolder = strcat(pwd, '/../../datasets/open_source_d_etp/', datasetName, '/all_epochs/train/');
    outputFolder = strcat(pwd, '/../../datasets/open_source_d_etp/', datasetName, '/all_epochs/test/');
    
    if ~exist(outputFolder, 'dir')
        mkdir(outputFolder);
    end
    
    files = dir(restIPIFolder);

    targetChannel = "Oz";
    neighbors = ["O1", "O2", "Pz"];
    targetFreq = [8 13];
    
    taskLengths = [];

    for i = 1:length(files)
        fileName = files(i).name;

        if(~ endsWith(fileName, '.mat'))
           continue; 
        end

    %     Check if the matching file exists in the task set
    %     Ex: PVT_S2_D4_REST_1000ms_PHASES should correspond to PVT_S2_D4_TASK_DATA
    
        if(datasetName == "PVT")
            taskFileName = strrep(fileName, 'REST_1000ms_PHASES', 'TASK_DATA');
        else
            taskFileName = strrep(fileName, 'REST_PHASES', 'TASK_DATA');
        end
        
        taskFilePath = strcat(taskFolder, taskFileName);

        if(~ isfile(taskFilePath))
            fprintf("%s has no matching task data\n", fileName);
            continue;
        end

        restFilePath = strcat(restIPIFolder, fileName);
        restIPIData = load(restFilePath).output;
        taskEEG = load(taskFilePath);

        if(isfield(taskEEG, 'EEG'))
           taskEEG = taskEEG.EEG; 
        end
        
        electrodes = ExtractElectrodes(taskEEG.chanlocs, targetChannel, neighbors);
        cycleEstimate = restIPIData.cycleEstimate;
        if(~ any(ismember(restDatasets, datasetName)))
            taskEEG.data = ConvertToCellArray(taskEEG.data, 0);
        end
        
%       Find statistics about file from thresholds table and then remove
%       epochs with amplitudes that are too high
        row = testThresholds(strcmp(testThresholds.SubjectId, taskFileName), :);
        if(height(row) ~= 1)
           fprintf("Could not find power information for %s, not removing epochs ...\n", taskFileName);
        else
            badIndexes = [];
            for j = 1:length(taskEEG.data)
                if(any(abs(taskEEG.data{j}(electrodes, :) - row.MeanOzTest) > 3 * row.SDOzTest, 'all'))
                   badIndexes = [badIndexes j]; 
                end
            end
            if(~isempty(badIndexes))
                taskEEG.data(badIndexes) = [];
            end
        end
        
        if(isempty(taskEEG.data)) % can become empty if all channels were bad
           completelyRejected(end + 1) = taskFileName;
           continue; 
        end
        
        [accuracies, allPhases, allPowers] = computeEpochAccuracy(taskEEG.data, taskEEG.srate, targetFreq, cycleEstimate, electrodes);

        output = struct('accuracies', accuracies, 'allPhases', allPhases, 'allPowers', allPowers);

        outputFileName = strrep(taskFileName, 'DATA', 'OUTPUT');
        outputFilePath = strcat(outputFolder, outputFileName);

        save(outputFilePath, 'output');
        taskLengths = [size(taskEEG.data{1}, 2), taskLengths];
    end
    
    datasetName
    unique(taskLengths)
    taskEEG.srate
    
end
