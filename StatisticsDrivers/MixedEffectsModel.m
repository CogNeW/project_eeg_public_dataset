% This script will read in all the data from our datasets and run a linear
% mixed effects model on them

inputFolder = strcat(pwd, '/../../datasets/open_source_e_statistics/');
files = dir(inputFolder);
tbl = table;

for i = 1:length(files)
        fileName = files(i).name;
        if(~ endsWith(fileName, '.mat'))
            continue; 
        end
        filePath = strcat(inputFolder, fileName);
        currentTable = load(filePath);
        if(i == 1)
           tbl = currentTable.outputTable;
        else
           tbl = [tbl; currentTable.outputTable];
        end
end
 
tbl.Status = categorical(tbl.Status);
tbl.Dataset  = categorical(tbl.Dataset);
tbl.Subject  = categorical(tbl.Subject);

lme = fitlme(tbl, 'Accuracy ~ Status + (Status | Dataset) + (Status | Dataset : Subject)');
lme_cov = fitlme(tbl, 'Accuracy ~ Status + Power + Power * Status + (Status | Dataset) + (Status | Dataset : Subject)');