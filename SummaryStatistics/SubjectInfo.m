% This script will extract the number of participants within each dataset
% and store them within a table

taskDatasets = ["ALPH" "AB" "B3" "COV" "ENS"];
pseudoRestDatasets = ["PVT"];
restDatasets = ["ABS" "JAZZ" "PVTRest" "SENS" "TMS" "TRAN" "MICRO"];
allDatasets = [taskDatasets pseudoRestDatasets restDatasets];

varTypes = ["string", "double"];
varNames = ["Name", "Participants"];

subjectTable = table('Size', [length(allDatasets), 2], ...
 'VariableTypes',varTypes,'VariableNames',varNames);

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
    
    % Decided to change the counts to those in the final output ETP folder
    inputFolder = strcat(pwd, '/../../datasets/open_source_d_etp/', datasetName, '/all_epochs/test/');
    
    files = dir(inputFolder);
    names = strings(0);

    for i = 1:length(files)
        fileName = files(i).name;

        if(~ endsWith(fileName, '.mat'))
           continue; 
        end
        
        tokens = split(fileName, "_");
        subjectId = tokens{4};

%          filePath = strcat(inputFolder, fileName);

%         EEG = load(filePath);
%         % Sometimes the struct is saved instead of the fields
%         if(isfield(EEG, 'EEG'))
%            EEG = EEG.EEG; 
%         end
%         
%         electrodes = ExtractElectrodes(EEG.chanlocs, targetChannel, neighbors);
%         % check if missing electrodes and skip
%         if(electrodes(1) == -1 || size(electrodes, 2) ~= size(neighbors, 2) + 1)
%             continue;
%         end
        names(end + 1) = subjectId;
    end

    % if(length(names) ~= length(unique(names)))
    	% fprintf("%s has duplicate names\n\n", datasetName);
    % end

    names = unique(names);
    subjectTable(datasetIndex, :) = {datasetName, length(names)};

end