% This script will partition each resting state data into epochs of length
% two seconds. These two second epochs match the length of the shortest
% epoch from our task dataset. Afterwards, half of the epochs will be
% designated as training, with the other half designated as test/task

addpath(strcat(pwd, '/../../ETPAlgorithm/utilities'));
restDatasets = ["PVTRest"];
epochLength = 4000;
% folder structure is currently
% datasets/opensource_c_epoched/__NAME__/not_chan_reduced/rest

for datasetIndex = 1:length(restDatasets)
    datasetName = restDatasets(datasetIndex);
    inputFolder = strcat(pwd, '/../../datasets/open_source_c_epoched/', datasetName, '/not_chan_reduced/rest/mat/');
    outputFolderTrain = strcat(pwd, '/../../datasets/open_source_c_epoched/', datasetName, '/not_chan_reduced/rest/train/mat/');
    outputFolderTest = strcat(pwd, '/../../datasets/open_source_c_epoched/', datasetName, '/not_chan_reduced/rest/test/mat/');
    
    mkdir(outputFolderTrain);
    mkdir(outputFolderTest);
    
    files = dir(inputFolder);

    for i = 1:length(files)
        fileName = files(i).name;

        if(~ endsWith(fileName, '.mat'))
           continue; 
        end
        filePath = strcat(inputFolder, fileName);

        EEG = load(filePath);
        cellData = PartitionToCellArray(EEG.data, EEG.srate, epochLength);
        halfLength = fix(length(cellData) / 2);
        firstHalf = cellData(1:halfLength);
        secondHalf = cellData((halfLength + 1):end);
        
        outputTrainFilePath = strcat(outputFolderTrain, fileName);
        EEG.data = firstHalf;
        save(outputTrainFilePath, 'EEG');
        
        fileName = strrep(fileName, 'REST', 'TASK');
        outputTestFilePath = strcat(outputFolderTest, fileName);
        EEG.data = secondHalf;
        save(outputTestFilePath, 'EEG');
        
    end
    
end