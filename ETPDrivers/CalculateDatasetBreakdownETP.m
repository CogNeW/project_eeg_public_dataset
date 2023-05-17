% This script will compute the average epoch length for each dataset.
% However, this is different than CalculateDatasetBreakdown.m because it
% will work off of the finalized ETP version. The previous script looked at
% epoched data and it was not clear whether the finalized version would
% maintain the same ratio of file lengths that we wanted.

% After computing the total task dataset lengths, I can compute the ratio
% of the times fΩrom which I can compute how the resting dataset data should
% be partitioned.


taskDatasets = ["AB" "ALPH" "B3" "COV" "ENS"];
% taskDatasets = ["ALPH" "B3" "COV" "ENS"];
pseudoRestDatasets = ["PVT"];
restDatasets = ["JAZZ" "PVTRest" "SENS" "TMS" "MICRO" "ABS"];
allDatasets = [taskDatasets pseudoRestDatasets restDatasets];
% allDatasets = [taskDatasets pseudoRestDatasets];

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
    
    ETPInputFolder = strcat(pwd, '/../../datasets/open_source_d_etp/', datasetName, '/all_epochs/train/');
    
%     fileLength = fix(0.6 * length(files));
    
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
%         PVT_E1_B1_S4_D1_REST_DATA
%         PVT_E1_B1_S1_D1_REST_PHASES
        ETPPath = strcat(ETPInputFolder, tokens{1}, "_", tokens{2}, "_", tokens{3}, "_", tokens{4}, "_", tokens{5}, "_", tokens{6}, "_", 'PHASES.mat');
         if(strcmp(datasetName, 'PVT'))
             ETPPath = strcat(ETPInputFolder, tokens{1}, "_", tokens{2}, "_", tokens{3}, "_", tokens{4}, "_", tokens{5}, "_", tokens{6}, "_", '1000ms_PHASES.mat');
         end
        
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
        
%         Check if the file exists in ETP
        if(~ isfile(ETPPath))
           continue; 
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
    
    ETPInputFolder = strcat(pwd, '/../../datasets/open_source_d_etp/', datasetName, '/all_epochs/test/');

%     fileLength = fix(0.6 * length(files));
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
        
         ETPPath = strcat(ETPInputFolder, tokens{1}, "_", tokens{2}, "_", tokens{3}, "_", tokens{4}, "_", tokens{5}, "_", tokens{6}, "_", 'OUTPUT.mat');
        
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
        
        %         Check if the file exists in ETP
        if(~ isfile(ETPPath))
           continue; 
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
datasetNames = fieldnames(epochLengths);

datasetBreakdown = table;
datasetBreakdown.name = string(datasetNames);
datasetBreakdown.type = ["Task","Task","Task","Task","Task","Task","EC", "EO", "EO", "EC", "EC", "EC", "EO", "EC", "EO", "EO"]';
% datasetBreakdown.type = ["Task","Task","Task","Task","Task","Task"]';
epochsTrain = [];
epochsTest = [];
trainLength = [];
testLength = [];

rejectedEpochs = [];


for j = 1:length(datasetNames)
   datasetName = datasetNames{j};
   restDataset = epochLengths.(datasetName).rest;
   taskDataset = epochLengths.(datasetName).task;
   
   restLengths = restDataset(1:2:length(restDataset));
   restCount = restDataset(2:2:length(restDataset));
   taskLengths = taskDataset(1:2:length(taskDataset));
   taskCount = taskDataset(2:2:length(taskDataset));
  
   epochsTrain = [epochsTrain, sum(restCount)];
   epochsTest = [epochsTest, sum(taskCount)];
   
  
   trainLength = [trainLength, min(restLengths)*4];
   testLength = [testLength, min(taskLengths)*4];
   
   % Attach rejected epochs
   if(strcmp(datasetBreakdown.type(j), "Task"))
      rejectedEpochs = [rejectedEpochs, removedEpochs.(datasetName)];
   elseif(strcmp(datasetName, 'SENSEC') || strcmp(datasetName, 'ABSEO'))
      datasetName = datasetName(1:(end-2));
      rejectedEpochs = [rejectedEpochs, removedEpochs.(datasetName)];
   else
      datasetName = datasetName(1:(end-2));
      rejectedEpochs = [rejectedEpochs, removedEpochs.(datasetName) / 2];
   end
       
end

datasetBreakdown.epochsTrain = epochsTrain';
datasetBreakdown.epochsTest = epochsTest';
datasetBreakdown.trainLength = trainLength';
datasetBreakdown.testLength = testLength';
datasetBreakdown.rejectedEpochs = rejectedEpochs';