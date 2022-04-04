% This script will aggregate all the phase angle and power measurements for
% each individual and store them in a file within open_source_e_statistics

taskDatasets = ["ALPH" "B3" "AB" "COV" "ENS", "PVT"];
restDatasets = ["ABS" "PVTRest" "SENS" "TMS" "JAZZ" "MICRO"];
allDatasets = [taskDatasets restDatasets];

taskDomains = ["Attention", "Decision", "Attention", "Attention", "Working Memory", "Vigilance"];

columnTypes = ["string", "string", "string", "string", "string", "double", "double" "double" "string", "double", "double"];
columnNames = ["Dataset", "Experiment", "Block", "Subject", "Day", "Accuracy", "Power" "Trial" "Domain", "SNR", "IAF"];

% Block numbers for PVTRest
BEO = ["B1", "B3", "B6", "B10"];
EODatasets = ["ABS"];
ECDatasets = ["SENS"];

for datasetIndex = 1:length(allDatasets)
    
    datasetName = allDatasets(datasetIndex);

    % Determine the right suffix depending on the dataset type
    currentStatus = "";
    if(any(ismember(restDatasets, datasetName)))
        currentStatus = "rest";
        currentDomain = "rest";
    else
        currentStatus = "task";
        currentDomain = taskDomains(datasetIndex);
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
    Trial = zeros(100000, 1);
    Domain = strings(100000, 1);
    SNR = zeros(100000, 1);
    IAF = zeros(100000, 1);
    
    
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
%             COMMENT THIS LATER
%             currentStatus = "rest";
        end

      
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
            Trial(index) = j;
            Domain(index) = currentDomain;
            SNR(index) = output.SNR;
            IAF(index) = output.IAF;
            
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
    Trial(index:end) = [];
    Domain(index:end) = [];
    SNR(index:end) = [];
    IAF(index:end) = [];
    
%     outputTable = table(Dataset, Experiment, Block, Subject, Day, Accuracy, Power, Status, Trial, Domain);
    outputTable = table(Dataset, Experiment, Block, Subject, Day, Accuracy, Power, Status, Trial, Domain, SNR, IAF);
    outputFolder = strcat(pwd, '/../../datasets/open_source_e_statistics/', datasetName);
    save(outputFolder, 'outputTable');
end