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
tbl.Domain = categorical(tbl.Domain);

sub = tbl(tbl.Dataset ~= 'ALPH', :);

lm = fitlme(tbl, 'Accuracy ~ Status');
lme = fitlme(tbl, 'Accuracy ~ Status + (1 | Dataset) + (1 | Dataset : Subject)');
lme_power_int = fitlme(tbl, 'Accuracy ~ Status + Power + Power * Status + (Power | Dataset) + (Power | Dataset : Subject)');
lme_power_snr = fitlme(tbl, 'Accuracy ~ Power * Status + SNR*Status + (SNR + Power | Dataset) + (SNR + Power| Dataset : Subject)');


slm = fitlme(sub, 'Accuracy ~ Status');
slme = fitlme(sub, 'Accuracy ~ Status + (1 | Dataset) + (1 | Dataset : Subject)');
slme_power_int = fitlme(sub, 'Accuracy ~ Status + Power + Power * Status + (Power | Dataset) + (Power | Dataset : Subject)');
slme_power_snr = fitlme(sub, 'Accuracy ~ Power * Status + SNR*Status + (SNR + Power | Dataset) + (SNR + Power| Dataset : Subject)');



% boxplot(tbl.Accuracy, tbl.Dataset)
% compare(lm, lme)
% boxplot(tbl.Accuracy, {tbl.Status, tbl.Dataset}, 'ColorGroup', tbl.Status)
