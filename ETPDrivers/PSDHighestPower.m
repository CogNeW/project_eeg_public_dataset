% This script will run analyses on the PSD files between rest and task
% conditions and determine if the highest power within a frequency range
% differs.

datasetName = 'PVT';

restFolder = strcat(pwd, '/../datasets/open_source_c_epoched/', datasetName, '/outputs/PSD/pseudorest/500/');
taskFolder = strcat(pwd, '/../datasets/open_source_c_epoched/', datasetName, '/outputs/PSD/task/');

files = dir(restFolder);

taskMax = [];
restMax = [];

for i = 1:length(files)
    fileName = files(i).name;
 
    if(~ endsWith(fileName, '.mat'))
       continue; 
    end
    
%     Check if the matching file exists in the task set
    taskFileName = strrep(fileName, 'REST_500ms', 'TASK');
    taskFilePath = strcat(taskFolder, taskFileName);

    if(~ isfile(taskFilePath))
        fprintf("%s has no matching task data\n", fileName);
        continue;
    end
    
    restFilePath = strcat(restFolder, fileName);
    restPsdArray = load(restFilePath);
    restPsdArray = restPsdArray.psdArray;
    taskPsdArray = load(taskFilePath);
    taskPsdArray = taskPsdArray.psdArray;
    
    numRestBlocks = size(restPsdArray, 2);
    numTaskBlocks = size(taskPsdArray, 2);
    
    if(numTaskBlocks ~= numRestBlocks)
        disp("Number of rest and task epochs do not match");
%         Set number of blocks to be the minimum
        minBlocks = min(numRestBlocks, numTaskBlocks);
        numRestBlocks = minBlocks;
        numTaskBlocks = minBlocks;
    end
    
    for j = 1:numRestBlocks
        restPSD = restPsdArray(j);
        restMax = [highestPower(restPSD.spectra, restPSD.freqs, 8, 13) restMax];
    end
    
    for j = 1:numTaskBlocks
        taskPSD = taskPsdArray(j);
        taskMax = [highestPower(taskPSD.spectra, taskPSD.freqs, 8, 13) taskMax];
    end

end

% Run the wilcoxon signed rank test
% returns the p-value of a paired, two-sided test for the null hypothesis 
% that x – y comes from a distribution with zero median.
signrank(restMax, taskMax)
histogram(restMax, 100, 'FaceColor', 'blue', 'FaceAlpha', .5);
hold on;
histogram(taskMax, 100, 'FaceColor', 'red', 'FaceAlpha', .5);

function maxFreq = highestPower(psd, freqs, lowFreq, highFreq)
%     This function computes the frequency with the highest power within
%     lowFreq to highFreq
    maxPower = -1000; % initialization value for power (must be negative)
    maxFreq = 0;
    
    for i = 1:size(freqs, 1)
        if(lowFreq <= freqs(i) && freqs(i) <= highFreq)
            if(maxPower < psd(i))
               maxPower = psd(i);
               maxFreq = freqs(i);
            end
        end
    end

end