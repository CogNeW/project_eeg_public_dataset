% This script will run the ETPTestEpoch algorithm and use the estimated
% interpeak interval from the training set to estimate future peaks in the
% task data.

% Quick note that the interpeak interval computed from the training portion
% is in terms of samples. To convert it to frequency, the sampling rate
% must be divided by that number


% Loop through each rest dataset
%   Find the appropriate one in test
%   Run test epoch, and get the predicted angles


datasetName = 'PVT';

restIPIFolder = strcat(pwd, '/../FinalDatasets/', datasetName, '/outputs/ETPTrain/pseudorest/500/');
taskFolder = strcat(pwd, '/../FinalDatasets/', datasetName, '/not_chan_reduced/task/mat/');

files = dir(restIPIFolder);

targetChannel = "Oz";
neighbors = ["O1", "O2", "Pz"];

for i = 1:length(files)
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
    
    electrodes = ExtractElectrodes(EEG.chanlocs, targetChannel, neighbors);
    cycleEstimate = restIPIData.cycleEstimate;
    cellData = ConvertToCellArray(taskEEG.data, 0);
    [accuracies, allPhases, allPowers] = computeEpochAccuracy(cellData, 250, targetFreq, cycleEstimate, electrodes);

end