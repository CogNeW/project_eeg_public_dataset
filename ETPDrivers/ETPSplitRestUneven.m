% This script will partition the resting state datasets into epochs of
% different lengths for the training and testing portion. Based on
% calculations to match the task datasets, the training epochs should be
% 800ms, while the the testing epochs should be 2724ms

addpath(strcat(pwd, '/../../ETPAlgorithm/utilities'));
restDatasets = ["JAZZ" "SENS" "TMS" "PVTRest" "TRAN" "ABS"];
% restDatasets = ["ABS"];
trainLength = 803;
testLength = 2725;
totalEpochLength = trainLength + testLength;
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
        [trainCellData, testCellData] = PartitionToUnevenCellArray(EEG.data, EEG.srate, totalEpochLength, trainLength, testLength);
        
        outputTrainFilePath = strcat(outputFolderTrain, fileName);
        EEG.data = trainCellData;
        save(outputTrainFilePath, 'EEG');
        
        fileName = strrep(fileName, 'REST', 'TASK');
        outputTestFilePath = strcat(outputFolderTest, fileName);
        EEG.data = testCellData;
        save(outputTestFilePath, 'EEG');
        
    end
    
end