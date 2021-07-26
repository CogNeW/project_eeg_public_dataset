% This script will run the ETPTestEpoch algorithm and use the estimated
% interpeak interval from the training set to estimate future peaks in the
% task data.

% Quick note that the interpeak interval computed from the training portion
% is in terms of samples. To convert it to frequency, the sampling rate
% must be divided by that number


% Loop through each rest dataset
%   Find the appropriate one in test
%   Run test epoch, and get the predicted angles

addpath(strcat(pwd, '/../ETPAlgorithm/utilities'));
addpath(strcat(pwd, '/../ETPAlgorithm'));

datasetName = 'PVT_preprocessed';

restIPIFolder = strcat(pwd, '/../datasets/open_source_c_epoched/', datasetName, '/outputs/ETPTrain/pseudorest/500/');
taskFolder = strcat(pwd, '/../datasets/open_source_c_epoched/', datasetName, '/not_chan_reduced/task/mat/');
outputFolder = strcat(pwd, '/../datasets/open_source_c_epoched/', datasetName, '/outputs/ETPTest/task/500/');

files = dir(restIPIFolder);

targetChannel = "Oz";
neighbors = ["O1", "O2", "Pz"];
targetFreq = [8 13];

for i = 1:length(files)
    i
	fileName = files(i).name;
 
    if(~ endsWith(fileName, '.mat'))
       continue; 
    end
    
%     Check if the matching file exists in the task set
%     Ex: PVT_S2_D4_REST_500ms_PHASES should correspond to PVT_S2_D4_TASK_DATA
    taskFileName = strrep(fileName, 'REST_500ms_PHASES', 'TASK_DATA');
    taskFilePath = strcat(taskFolder, taskFileName);
    
    if(~ isfile(taskFilePath))
        fprintf("%s has no matching task data\n", fileName);
        continue;
    end
    
    restFilePath = strcat(restIPIFolder, fileName);
    restIPIData = load(restFilePath).output;
    taskEEG = load(taskFilePath);
    
    electrodes = ExtractElectrodes(taskEEG.chanlocs, targetChannel, neighbors);
    cycleEstimate = restIPIData.cycleEstimate;
    cellData = ConvertToCellArray(taskEEG.data, 0);
    [accuracies, allPhases, allPowers] = computeEpochAccuracy(cellData, 250, targetFreq, cycleEstimate, electrodes);

    output = struct('accuracies', accuracies, 'allPhases', allPhases, 'allPowers', allPowers);
      
    outputFileName = strrep(taskFileName, 'DATA', 'OUTPUT');
    outputFilePath = strcat(outputFolder, outputFileName);

    save(outputFilePath, 'output');

end