%% Get center of deviation (are our predictions centered at the peak)

% This script will aggregate all the phase angle and power measurements for
% each individual and store them in a file within open_source_e_statistics

taskDatasets = ["AB" "ALPH" "B3" "COV" "ENS" "PVT"];
pseudoRestDatasets = ["PVT"];
restDatasets = ["JAZZ" "PVTRest" "SENS" "TMS" "MICRO" "ABS"];
allDatasets = [taskDatasets restDatasets];

allPhases = [];

for datasetIndex = 1:length(allDatasets)
    
    datasetName = allDatasets(datasetIndex)
    inputFolder = strcat(pwd, '/../../datasets/open_source_d_etp/', datasetName, '/all_epochs/test/');
    files = dir(inputFolder);
    
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
        
        allPhases = [allPhases output.allPhases];
        
    end
    

end