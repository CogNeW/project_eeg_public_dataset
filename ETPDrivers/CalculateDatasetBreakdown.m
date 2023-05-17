% This script will compute the average epoch length for each dataset. The
% purpose of this script is to deal with reviewer comments that the
% unbalanced nature of our datasets can contribute to our results.


taskDatasets = ["AB" "ALPH" "B3" "COV" "ENS"];
% taskDatasets = ["ALPH" "B3" "COV" "ENS"];
pseudoRestDatasets = ["PVT"];
restDatasets = ["JAZZ" "PVTRest" "SENS" "TMS" "MICRO" "ABS"];
allDatasets = [taskDatasets pseudoRestDatasets restDatasets];
% allDatasets = [restDatasets];

% Block numbers for PVTRest
BEO = ["B1", "B3", "B6", "B10"];
EODatasets = ["ABS"];
ECDatasets = ["SENS"];

epochLengths = struct;

for datasetIndex = 1:length(allDatasets)
    currentDomain = "";
    datasetName = allDatasets(datasetIndex)

    % Determine the right suffix depending on the dataset type
    inputSuffix = "";
    if(any(ismember(taskDatasets, datasetName)))
        inputSuffix = "/rest/";
    elseif(any(ismember(restDatasets, datasetName)))
        inputSuffix = "/rest/train/";
        currentDomain = "rest";
    else 
        % pseudorest
        inputSuffix = "/pseudorest/1000/";
    end
    
    inputFolder = strcat(pwd, '/../../datasets/open_source_c_epoched/', datasetName, '/not_chan_reduced', inputSuffix, 'mat/');
    files = dir(inputFolder);

    fullDatasetName = datasetName;
    
    for i = 1:length(files)
        fileName = files(i).name;

        if(~ endsWith(fileName, '.mat'))
           continue; 
        end
        
%         Compute eyes open or eyes closed
        tokens = split(fileName, "_");
        experimentNumber = tokens{2};
        blockNumber = tokens{3};
        subjectId = tokens{4};
        dayNumber = tokens{5};

        if(strcmp(currentDomain, "rest"))
            % for eyes open and closed, only PVT is the odd one out
            if(strcmp(datasetName, 'PVTRest'))
                % condition is based on block number
                if(ismember(blockNumber, BEO))
                    currentStatus = "EO";
                else
                    currentStatus = "EC";
                end
            elseif(ismember(datasetName, EODatasets))
                currentStatus = "EO";
            elseif(ismember(datasetName, ECDatasets))
                currentStatus = "EC";
            else
                currentStatus = experimentNumber;
            end
            fullDatasetName = strcat(datasetName, currentStatus);
%             COMMENT THIS LATER
%             currentStatus = "rest";
        end
        
        if(~isfield(epochLengths,fullDatasetName))
            epochLengths.(fullDatasetName) = struct;
            epochLengths.(fullDatasetName).rest = [];
            epochLengths.(fullDatasetName).task = [];
        end
        
    
        filePath = strcat(inputFolder, fileName);
        EEG = load(filePath);
        % Sometimes the struct is saved instead of the fields
        if(isfield(EEG, 'EEG'))
           EEG = EEG.EEG; 
        end
        if(any(ismember(restDatasets, datasetName)))
            epochLengths.(fullDatasetName).rest = [epochLengths.(fullDatasetName).rest, [size(EEG.data{1}, 2), size(EEG.data, 1)]];
        else
            epochLengths.(fullDatasetName).rest = [epochLengths.(fullDatasetName).rest, [size(EEG.data, 2), size(EEG.data, 3)]];
        end
        
    end
    
    % Do task length calculations
    
    inputFolder = strcat(pwd, '/../../datasets/open_source_c_epoched/', datasetName, '/not_chan_reduced/task/mat/');
    if(any(ismember(restDatasets, datasetName)))
        inputFolder = strcat(pwd, '/../../datasets/open_source_c_epoched/', datasetName, '/not_chan_reduced/rest/test/mat/');
    end
    files = dir(inputFolder);
    fullDatasetName = datasetName;

    for i = 1:length(files)
        fileName = files(i).name;

        if(~ endsWith(fileName, '.mat'))
           continue; 
        end
        filePath = strcat(inputFolder, fileName);
        
        tokens = split(fileName, "_");
        experimentNumber = tokens{2};
        blockNumber = tokens{3};
        subjectId = tokens{4};
        dayNumber = tokens{5};
        
        if(strcmp(currentDomain, "rest"))
            % for eyes open and closed, only PVT is the odd one out
            if(strcmp(datasetName, 'PVTRest'))
                % condition is based on block number
                if(ismember(blockNumber, BEO))
                    currentStatus = "EO";
                else
                    currentStatus = "EC";
                end
            elseif(ismember(datasetName, EODatasets))
                currentStatus = "EO";
            elseif(ismember(datasetName, ECDatasets))
                currentStatus = "EC";
            else
                currentStatus = experimentNumber;
            end
            fullDatasetName = strcat(datasetName, currentStatus);
%             COMMENT THIS LATER
%             currentStatus = "rest";
        end
        
        if(~isfield(epochLengths, fullDatasetName))
            epochLengths.(fullDatasetName) = struct;
            epochLengths.(fullDatasetName).rest = [];
            epochLengths.(fullDatasetName).task = [];
        end
        
        EEG = load(filePath);
        if(isfield(EEG, 'EEG'))
           EEG = EEG.EEG; 
        end
        if(any(ismember(restDatasets, datasetName)))
            epochLengths.(fullDatasetName).task = [epochLengths.(fullDatasetName).task, [size(EEG.data{1}, 2), size(EEG.data, 1)]];
        else
            epochLengths.(fullDatasetName).task = [epochLengths.(fullDatasetName).task, [size(EEG.data, 2), size(EEG.data, 3)]];
        end
    end
end

% Compute Statistics

datasetBreakdown = struct;

datasetNames = fieldnames(epochLengths);
for j = 1:length(datasetNames)
   datasetName = datasetNames{j};
   restDataset = epochLengths.(datasetName).rest;
   taskDataset = epochLengths.(datasetName).task;
   restLengths = restDataset(1:2:length(restDataset));
   restCount = restDataset(2:2:length(restDataset));
   taskLengths = taskDataset(1:2:length(taskDataset));
   taskCount = taskDataset(2:2:length(taskDataset));
   datasetBreakdown.(datasetName) = struct;
   datasetBreakdown.(datasetName).rest = struct;
   datasetBreakdown.(datasetName).task = struct;
   
%    The factor of four is because of the 250Hz sampling rate we imposed on
%    everything
   datasetBreakdown.(datasetName).rest.numEpochs = sum(restCount);
   datasetBreakdown.(datasetName).rest.totalTime = sum(4 * restCount .* restLengths);
   datasetBreakdown.(datasetName).rest.minTime = min(restLengths)*4;
   datasetBreakdown.(datasetName).rest.maxTime = max(restLengths)*4;
   datasetBreakdown.(datasetName).rest.meanTime = mean(restLengths)*4;
   
   datasetBreakdown.(datasetName).task.numEpochs = sum(taskCount);
   datasetBreakdown.(datasetName).task.totalTime = sum(4 * taskCount .* taskLengths);
   datasetBreakdown.(datasetName).task.minTime = min(taskLengths)*4;
   datasetBreakdown.(datasetName).task.maxTime = max(taskLengths)*4;
   datasetBreakdown.(datasetName).task.meanTime = mean(taskLengths)*4;
end