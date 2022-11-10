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
allDatasets = ["PVT"];

testThresholds = load('../SummaryStatistics/testIndividualTableAll.mat');
testThresholds = testThresholds.subjectTable;
mappingReport = load('../SummaryStatistics/SNRTableCombined.mat');
mappingReport = mappingReport.mappingReport;

completelyRejected = strings(0);

condition = "ECPre";

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
    restIPIFolder = strcat(pwd, '/../../datasets/open_source_d_etp/PVTRest/all_epochs/train/');
    outputFolder = strcat(pwd, '/../../datasets/open_source_d_etp/PVT', condition, '/all_epochs/test/');
    
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
    
        components = split(fileName, "_");
        taskFileName = fileName;
        
        if(strcmp(condition, "EOPre"))
            if(strcmp(components{3}, "B1"))
                taskFileName = strrep(taskFileName, 'B1', 'B4');
            elseif(strcmp(components{3}, "B6"))
                taskFileName = strrep(taskFileName, 'B6', 'B9');
            else
               continue; 
            end
        end
        
        if(strcmp(condition, "ECPre"))
            if(strcmp(components{3}, "B2"))
                taskFileName = strrep(taskFileName, 'B2', 'B4');
            elseif(strcmp(components{3}, "B7"))
                taskFileName = strrep(taskFileName, 'B7', 'B9');
            else
               continue; 
            end
        end
        
        if(strcmp(condition, "EOPost"))
            if(strcmp(components{3}, "B5"))
                taskFileName = strrep(taskFileName, 'B5', 'B4');
            elseif(strcmp(components{3}, "B10"))
                taskFileName = strrep(taskFileName, 'B10', 'B9');
            else
               continue; 
            end
        end
        
        if(datasetName == "PVT")
            taskFileName = strrep(taskFileName, 'REST_PHASES', 'TASK_DATA');
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
        
        % For MICRO, the SNR name has EO/EC replaced with 
        snrName = taskFileName;
        if(strcmp(datasetName, "MICRO"))
            snrName = replace(snrName, "EO", "E1");
            snrName = replace(snrName, "EC", "E1");
        elseif(any(ismember(restDatasets, datasetName)))
            snrName = replace(snrName, "TASK_DATA", "REST_DATA");
        end
                
        %         Find SNR value
        snr = -1;
        iaf = -1;
        for j = 1:size(mappingReport, 1)
            if(strcmp(mappingReport{j, 4}.open_source_c, snrName))
                snr = mappingReport{j, 4}.SNR;
                iaf = mappingReport{j, 4}.IAF;
            end
        end   
       
        if(isempty(iaf))
           fprintf("%s: Missing Peak\n", snrName);
           continue;
        end
        
        if(snr < 0)
           fprintf("%s: Negative SNR\n", snrName);
           continue;
        end
        
        if(iaf == -1)
            fprintf("%s missing IAF value\n", snrName);
            continue;
        end
        targetFreq = [iaf-2.5 iaf+2.5];
        
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

        output = struct('accuracies', accuracies, 'allPhases', allPhases, 'allPowers', allPowers, 'SNR', snr, 'IAF', iaf);

        outputFileName = strrep(taskFileName, 'DATA', 'OUTPUT');
        outputFilePath = strcat(outputFolder, outputFileName);

        save(outputFilePath, 'output');
        taskLengths = [size(taskEEG.data{1}, 2), taskLengths];
    end
    
    datasetName
    unique(taskLengths)
    taskEEG.srate
    
end
