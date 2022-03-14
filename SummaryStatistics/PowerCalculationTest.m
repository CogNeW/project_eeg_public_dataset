% This script will compute the average amplitude and standard deviation
% for Oz, O1, O2, Pz to facilitate comparison and the creation of an
% artifact rejection strategy

addpath(strcat(pwd, '/../../ETPAlgorithm/utilities'));
addpath(strcat(pwd, '/../../ETPAlgorithm'));

taskDatasets = ["ALPH" "B3" "AB" "COV" sky"ENS"];
pseudoRestDatasets = ["PVT"];
restDatasets = ["ABS" "JAZZ" "PVTRest" "SENS" "TMS" "TRAN" "MICRO"];
allDatasets = [taskDatasets pseudoRestDatasets restDatasets];
allDatasets = ["ALPH"];
varTypes = ["string", "string", "double", "double"];
varNames = ["Name", "SubjectId", "MeanOzTest", "SDOzTest"];

subjectTable = table('Size', [0, 4], ...
 'VariableTypes',varTypes,'VariableNames',varNames);

targetChannel = "Oz";			
neighbors = ["O1", "O2", "Pz"];

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
    
    files = dir(restIPIFolder);

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

        taskEEG = load(taskFilePath);

        if(isfield(taskEEG, 'EEG'))
           taskEEG = taskEEG.EEG; 
        end

        electrodes = ExtractElectrodes(taskEEG.chanlocs, targetChannel, neighbors);
        % check if missing electrodes and skip
        if(electrodes(1) == -1 || size(electrodes, 2) ~= size(neighbors, 2) + 1)
            disp(sprintf("%s missing electrodes", fileName));
            continue;
        end
        
        tokens = split(fileName, "_");
        subjectId = tokens{4};

        if(iscell(taskEEG.data))
            channelData = [];
            for j = 1:length(taskEEG.data)
                channelData = [channelData taskEEG.data{j}(electrodes, :)];
            end
        else
            channelData = taskEEG.data(:, :, electrodes);
        end
        
        
        subjectTable(end + 1, :) = {datasetName, taskFileName, mean(channelData(:)), std(channelData(:))};

    end

end

% Take the average of each group
testMeanTable = varfun(@mean, subjectTable, 'InputVariables', 'MeanOzTest', 'GroupingVariables', 'Name');
testSDTable = varfun(@mean, subjectTable, 'InputVariables', 'SDOzTest', 'GroupingVariables', 'Name');

testTables.mean = testMeanTable;
testTables.SD = testSDTable;

save('testTablesAll.mat', 'testTables');
save('testIndividualTableAll.mat', 'subjectTable');