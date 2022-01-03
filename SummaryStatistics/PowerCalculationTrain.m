% This script will compute the average amplitude and standard deviation
% for Oz, O1, O2, Pz to facilitate comparison and the creation of an
% artifact rejection strategy

addpath(strcat(pwd, '/../../ETPAlgorithm/utilities'));
addpath(strcat(pwd, '/../../ETPAlgorithm'));

taskDatasets = ["ALPH" "AB" "B3" "COV" "ENS"];
pseudoRestDatasets = ["PVT"];
restDatasets = ["ABS" "JAZZ" "PVTRest" "SENS" "TMS" "TRAN"];
allDatasets = [taskDatasets pseudoRestDatasets restDatasets];
% allDatasets = [restDatasets];
varTypes = ["string", "string", "double", "double"];
varNames = ["Name", "SubjectId", "MeanOzTrain", "SDOzTrain"];

subjectTable = table('Size', [0, 4], ...
 'VariableTypes',varTypes,'VariableNames',varNames);

targetChannel = "Oz";			
neighbors = ["O1", "O2", "Pz"];

for datasetIndex = 1:length(allDatasets)
    
    datasetName = allDatasets(datasetIndex);
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
    files = dir(inputFolder);

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
        
        tokens = split(fileName, "_");
        subjectId = tokens{4};

        if(iscell(EEG.data))
            channelData = [];
            for j = 1:length(EEG.data)
               channelData = [channelData EEG.data{j}(electrodes, :)];
            end
        else
            channelData = EEG.data(:, :, electrodes);
        end
        
        
%       "Name", "SubjectId", "MeanOzTrain", "SDOzTrain", "MeanOzTest", "SDOzTest"
        subjectTable(end + 1, :) = {datasetName, fileName, mean(channelData(:)), std(channelData(:))};
    end

end

% Take the average of each group
trainMeanTable = varfun(@mean, subjectTable, 'InputVariables', 'MeanOzTrain', 'GroupingVariables', 'Name');
trainSDTable = varfun(@mean, subjectTable, 'InputVariables', 'SDOzTrain', 'GroupingVariables', 'Name');

trainTables.mean = trainMeanTable;
trainTables.SD = trainSDTable;

save('trainTablesAll.mat', 'trainTables');
save('trainIndividualTableAll.mat', 'subjectTable');