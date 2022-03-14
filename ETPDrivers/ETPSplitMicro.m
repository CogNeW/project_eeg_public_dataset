% This script will split the MICRO data into eyes open and eyes closed
% Currently for a given recording, both eyes open and eyes closed are
% together, although they are alternating. The current script will separate
% the two, and then further split each condition to match the resting state 
% epoch length of two seconds. We will change the experiment number to EO 
% or EC, and then save the file.

% S200 - Eyes Open Rest; S210 - Eyes Closed Rest
% Had to manually delete 'MICRO_E1_B1_S010015_D1_TASK_DATA.mat' before
% running and run the 'CleanMICRO.m' script located in datasets


microPath = strcat(pwd, '/../../datasets/open_source_c_epoched/MICRO/not_chan_reduced/rest/mat/');
outputFolderTest = strcat(pwd, '/../../datasets/open_source_c_epoched/MICRO/not_chan_reduced/rest/test/mat/');
outputFolderTrain = strcat(pwd, '/../../datasets/open_source_c_epoched/MICRO/not_chan_reduced/rest/train/mat/');

mkdir(outputFolderTest);
mkdir(outputFolderTrain);

files = dir(microPath);

for i = 85:length(files)
    fileName = files(i).name;

    if(~ endsWith(fileName, '.mat'))
       continue; 
    end
    filePath = strcat(microPath, fileName);

    EEG = load(filePath);
%     Assuming that eyes open are first
%     size(EEG.data)
    i
    if(size(EEG.data, 3) == 1)
       fprintf("BAD FILE: %s\n", filePath); 
       continue;
    end
    numEpochs = size(EEG.data, 3);
    eyesOpen = EEG.data(:, :, 1:2:numEpochs);
    eyesClosed = EEG.data(:, :, 2:2:numEpochs);
    
%     If eyes closed are actually first
    if(strcmp(EEG.event(2).type, 'S210'))
        eyesClosed = EEG.data(:, :, 1:2:numEpochs);
        eyesOpen = EEG.data(:, :, 2:2:numEpochs);
    end
    
    eyesOpenSplit = partitionEpochedData(eyesOpen, EEG.srate * 2);
    eyesClosedSplit = partitionEpochedData(eyesClosed, EEG.srate * 2);
    
%     save eyes open
    eoTestPath = replace(fileName, 'E1', 'EO');
    eoTrainPath = replace(eoTestPath, 'TASK_DATA', 'REST_DATA'); 
    [output1, output2] = splitEpochedData(eyesOpenSplit);
    EEG.data =  ConvertToCellArray(output1, 0);
    outputTrainPath = strcat(outputFolderTrain, eoTrainPath);
    save(outputTrainPath, 'EEG');
    EEG.data =  ConvertToCellArray(output2, 0);
    outputTestPath = strcat(outputFolderTest, eoTestPath);
    save(outputTestPath, 'EEG');
    
    ecTestPath = replace(fileName, 'E1', 'EC');
    ecTrainPath = replace(ecTestPath, 'TASK_DATA', 'REST_DATA'); 
    [output1, output2] = splitEpochedData(eyesClosedSplit);
    EEG.data =  ConvertToCellArray(output1, 0);
    outputTrainPath = strcat(outputFolderTrain, ecTrainPath);
    save(outputTrainPath, 'EEG');
    EEG.data =  ConvertToCellArray(output2, 0);
    outputTestPath = strcat(outputFolderTest, ecTestPath);
    save(outputTestPath, 'EEG');
end

function [firstHalf, secondHalf] = splitEpochedData(splitData)
% This function splits the epoched data into two and converts it into a
% cell array, to match the format of previous datasets
    halfLength = fix(size(splitData, 3) / 2);
    firstHalf = splitData(:, :, 1:halfLength);
    secondHalf = splitData(:, :, (halfLength + 1):end);
end

function [splitData] = partitionEpochedData(epochedData, samples)
% This function will take in epoched data and convert the data so that each
% epoch will have 'samples' samples

    totalEpochs = (size(epochedData, 3) * size(epochedData, 2)) / samples;
    splitData = zeros(size(epochedData, 1), samples, totalEpochs);

    epochIndex = 1;
    
    for i = 1:size(epochedData, 3)
        numSamples = size(epochedData, 2) / samples;
        for j = 1:numSamples
            splitData(:, :, epochIndex) = epochedData(:, ((j - 1) * samples + 1) : j * samples , i);
            epochIndex = epochIndex + 1;
        end
    end
    
end