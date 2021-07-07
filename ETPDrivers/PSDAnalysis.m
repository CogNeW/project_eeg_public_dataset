% This script will run analyses on the PSD files between rest and task
% conditions and determine if the signal to noise ratio (SNR) are different
% between the two conditions. This will be done using a Wilcoxon
% sign-ranked test.

datasetName = 'PVT';

restFolder = strcat(pwd, '/../FinalDatasets/', datasetName, '/outputs/PSD/pseudorest/500/');
taskFolder = strcat(pwd, '/../FinalDatasets/', datasetName, '/outputs/PSD/task/');

files = dir(restFolder);

taskSNR = [];
restSNR = [];

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
        PSD = restPsdArray(j);
        restSNR = [computeSNR(PSD.spectra, PSD.freqs, 8, 13) restSNR];
    end
    
    for j = 1:numTaskBlocks
        PSD = taskPsdArray(j);
        taskSNR = [computeSNR(PSD.spectra, PSD.freqs, 8, 13) taskSNR];
    end

end

% Run the wilcoxon signed rank test
% returns the p-value of a paired, two-sided test for the null hypothesis 
% that x – y comes from a distribution with zero median.
signrank(restSNR, taskSNR)
histogram(restSNR, 100, 'FaceColor', 'blue', 'FaceAlpha', .5);
hold on;
histogram(taskSNR, 100, 'FaceColor', 'red', 'FaceAlpha', .5);

function snr = computeSNR(psd, freqs, lowFreq, highFreq)
%     This function computes the signal to noise ratio for the frequency
%     band from lowFreq to highFreq, based on the powerspectral densities,
%     and given frequencies list.

    totalPower = 0;
    bandPower = 0;
    
    for i = 1:size(freqs, 1)
        if(lowFreq <= freqs(i) && freqs(i) <= highFreq)
            bandPower = bandPower + abs(psd(i));
        end
        totalPower = totalPower + abs(psd(i));
    end

    snr = bandPower / totalPower;
end