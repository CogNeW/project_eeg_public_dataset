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

% addpath(strcat(pwd, '/../../ETPAlgorithm/dependencies/fieldtrip-20201229'));
addpath(strcat(pwd, '/../../ETPAlgorithm/utilities'));
addpath(strcat(pwd, '/../../ETPAlgorithm'));

% datasetNames = ["PVT" "ALPH" "B3" "COV" "AB"];
% AB ABS ALPH B3 COV ENS JAZZ PVT SENS TMS TRAN
taskDatasets = ["AB" "ALPH" "B3" "COV" "ENS"];
pseudoRestDatasets = ["PVT"];
restDatasets = ["JAZZ" "PVTRest" "SENS" "TMS" "MICRO" "ABS"];
allDatasets = [taskDatasets pseudoRestDatasets restDatasets];
% allDatasets = [taskDatasets pseudoRestDatasets];
% allDatasets = ["ENS"];

trainThresholds = load('../SummaryStatistics/trainIndividualTableAll.mat');
trainThresholds = trainThresholds.subjectTable;
mappingReport = load('../SummaryStatistics/MinPeakMEMOIZEDeBOSCSNRTableCombined.mat');
mappingReport = mappingReport.mappingReport;

completelyRejected = strings(0);

for datasetIndex = 1:length(allDatasets)
    datasetName = allDatasets(datasetIndex);
    
    % Determine the right suffix depending on the dataset type
    inputSuffix = "";
    datasetType = "";
    if(any(ismember(taskDatasets, datasetName)))
        inputSuffix = "/rest/";
        datasetType = "task";
    elseif(any(ismember(restDatasets, datasetName)))
        inputSuffix = "/rest/train/";
        datasetType = "rest";
    else 
        % pseudorest
        inputSuffix = "/pseudorest/1000/";
        datasetType = "task";
    end
    
    inputFolder = strcat(pwd, '/../../datasets/open_source_c_epoched/', datasetName, '/not_chan_reduced', inputSuffix, 'mat/');
    outputFolder = strcat(pwd, '/../../datasets/open_source_d_etp/', datasetName, '/all_epochs/train/');
    if ~exist(outputFolder, 'dir')
        mkdir(outputFolder);
    end
    
    files = dir(inputFolder);

    targetFreq = [8 13];
    targetChannel = "Pz";           
    neighbors = ["Oz", "Cz", "P4", "P3"];
    
    restLengths = [];

    % This is to get the average number of epoch lengths and counts across
    % comparisons. We need to retain 39% of the task datasets since we have
    % so many more than the rest datasets. When using 39%, only run this on
    % the task dataset.
   
    if(strcmp(datasetType, "rest"))
        ratioLength = length(files);
    else
        ratioLength = fix(0.25 * length(files)); 
    end
    
%     ratioLength = length(files);
    
    count = 0;
        
    
    
    for i = 1:length(files)
        fileName = files(i).name;
        
        if(count == ratioLength)
            break;
        end

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
        
        % For MICRO, the SNR name has EO/EC replaced with 
        % Also, replace REST_DATA wit TASK_DATA (they both come from the
        % same file anyways)
        snrName = fileName;
        if(strcmp(datasetName, "MICRO"))
            snrName = replace(snrName, "EO", "E1");
            snrName = replace(snrName, "EC", "E1");
            snrName = replace(snrName, "REST_DATA", "TASK_DATA");
        end
        
        %         Find SNR value
        snr = -1;
        iaf = -1;
        for j = 1:size(mappingReport, 1)
            if(strcmp(mappingReport{j, 4}.open_source_c, snrName))
                snr = mappingReport{j, 4}.SNR;
                iaf = mappingReport{j, 4}.IAF;
%                   snr = mappingReport{j, 5}.eBOSCSNR;
%                   iaf = mappingReport{j, 5}.IAF;
            end
        end   
       
        if(isempty(iaf) || isnan(iaf))
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
        % only non-rest datasets need to be converted to cell array, as rest
        % datasets are already converted (check ETPSplitRest)
        originalData = EEG.data;
        if(~ any(ismember(restDatasets, datasetName)))
            EEG.data = ConvertToCellArray(EEG.data, 0);
        end
    
        count = count + 1;
        
%       Find statistics about file from thresholds table and then remove
%       epochs with amplitudes that are too high
        row = trainThresholds(strcmp(trainThresholds.SubjectId, fileName), :);
        if(height(row) ~= 1)
           fprintf("Could not find power information for %s, not removing epochs ...\n", fileName);
        else
            badIndexes = [];
            for j = 1:length(EEG.data)
                if(any(abs(EEG.data{j}(electrodes, :) - row.MeanOzTrain) > 3 * row.SDOzTrain, 'all'))
                   badIndexes = [badIndexes j]; 
                end
            end
            if(~isempty(badIndexes))
                EEG.data(badIndexes) = [];
            end
        end
        
        if(isempty(EEG.data)) % can become empty if all channels were bad
           completelyRejected(end + 1) = fileName;
           continue; 
        end
        
        if(length(EEG.data) == 1) % if only one element left, can't split training set
           completelyRejected(end + 1) = fileName;
           continue; 
        end
        
        [cycleEstimate, actualPhases, actualPowers] = ETPTrainEpoch(EEG.data, 'TargetFreq', targetFreq, 'Electrodes', electrodes, 'SamplingRate', EEG.srate, ...
                'Graph', false);

        output = struct('cycleEstimate', cycleEstimate, 'actualPhases', actualPhases, 'actualPowers', actualPowers, 'SNR', snr, 'IAF', iaf);

        outputFileName = strrep(fileName, 'DATA', 'PHASES');
        outputFilePath = strcat(outputFolder, outputFileName);
        save(outputFilePath, 'output');
        
        restLengths = [size(EEG.data{1}, 2), restLengths];
 
    end
    
    datasetName
    unique(restLengths)
    EEG.srate
    
end


