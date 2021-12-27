% This script will extract the number of participants within each dataset
% and store them within a table

taskDatasets = ["ALPH" "AB" "B3" "COV" "ENS"];
pseudoRestDatasets = ["PVT"];
restDatasets = ["ABS" "JAZZ" "PVTRest" "SENS" "TMS" "TRAN"];
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
    files = dir(inputFolder);
    names = strings(0);

    for i = 1:length(files)
        fileName = files(i).name;

        if(~ endsWith(fileName, '.mat'))
           continue; 
        end
        
        tokens = split(fileName, "_");
        subjectId = tokens{4};

        names(end + 1) = subjectId;
    end

    % if(length(names) ~= length(unique(names)))
    	% fprintf("%s has duplicate names\n\n", datasetName);
    % end

    names = unique(names);
    subjectTable(datasetIndex, :) = {datasetName, length(names)};

end