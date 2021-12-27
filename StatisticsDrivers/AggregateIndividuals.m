% This script will aggregate all the phase angle and power measurements for
% each individual and store them in a file within open_source_e_statistics

taskDatasets = ["ALPH" "B3" "AB" "COV" "ENS", "PVT"];
restDatasets = ["ABS" "PVTRest" "SENS" "TMS"];
allDatasets = [taskDatasets restDatasets];

columnTypes = ["string", "string", "string", "string", "string", "double", "double"];
columnNames = ["Dataset", "Experiment", "Block", "Subject", "Day", "Accuracy", "Power"];

for datasetIndex = 1:length(allDatasets)
    
    datasetName = allDatasets(datasetIndex);

    % Determine the right suffix depending on the dataset type
    currentStatus = "";
    if(any(ismember(restDatasets, datasetName)))
        currentStatus = "rest";
    else
        currentStatus = "task";
    end
    
    inputFolder = strcat(pwd, '/../../datasets/open_source_d_etp/', datasetName, '/all_epochs/test/');
    files = dir(inputFolder);
    
    Dataset = strings(100000, 1);
    Experiment = strings(100000, 1);
    Block = strings(100000, 1);
    Subject = strings(100000, 1);
    Day = strings(100000, 1);
    Status = strings(100000, 1);
    Accuracy = zeros(100000, 1);
    Power = zeros(100000, 1);
    index = 1;
    
    for i = 1:length(files)
        fileName = files(i).name;

        if(~ endsWith(fileName, '.mat'))
           continue; 
        end
        
        filePath = strcat(inputFolder, fileName);
        output = load(filePath);
        if(isfield(output, 'output'))
           output = output.output; 
        end
        
        tokens = split(fileName, "_");
        experimentNumber = tokens{2};
        blockNumber = tokens{3};
        subjectId = tokens{4};
        dayNumber = tokens{5};
      
        for j = 1:length(output.allPhases)
            instPhase = output.allPhases(j);
            instPower = output.allPowers(j);
            
            Dataset(index) = datasetName;
            Experiment(index) = experimentNumber;
            Block(index) = blockNumber;
            Subject(index) = subjectId;
            Day(index) = dayNumber;
            Accuracy(index) = 1 - (1 / pi) * abs(instPhase);
            Power(index) = instPower;
            Status(index) = currentStatus;
            
            index = index + 1;
        end
        
    end
    
%     Write output table to a file
    Dataset(index:end) = [];
    Experiment(index:end) = [];
    Block(index:end) = [];
    Subject(index:end) = [];
    Day(index:end) = [];
    Accuracy(index:end) = [];
    Power(index:end) = [];
    Status(index:end) = [];
    outputTable = table(Dataset, Experiment, Block, Subject, Day, Accuracy, Power, Status);
    outputFolder = strcat(pwd, '/../../datasets/open_source_e_statistics/', datasetName);
    save(outputFolder, 'outputTable');
end