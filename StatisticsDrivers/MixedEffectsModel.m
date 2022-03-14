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

lm = fitlme(sub, 'Accuracy ~ Status');
lme = fitlme(sub, 'Accuracy ~ Status + (Status | Dataset) + (Status | Dataset : Subject)');
lme_power_int = fitlme(sub, 'Accuracy ~ Status + Power + Power * Status + (Status + Power + Power * Status | Dataset) + (Status + Power + Power * Status | Dataset : Subject)');
lme_power_snr = fitlme(sub, 'Accuracy ~ Power * Status + SNR*Status + (SNR*Status + Power * Status | Dataset) + (SNR*Status + Power * Status | Dataset : Subject)');

% lme_domain = fitlme(tbl, 'Accuracy ~ Status + (Status | Domain) + (Status | Domain:Dataset) + (Status | Domain: Dataset : Subject)');
% lme_domain_power = fitlme(tbl, 'Accuracy ~ Status + Power + Power * Status + (Status + Power + Power * Status | Domain) + (Status + Power + Power * Status | Domain:Dataset) + (Status + Power + Power * Status | Domain: Dataset : Subject)');

% lme_trial = fitlme(tbl, 'Accuracy ~ Status + (Status | Dataset) + (Status | Dataset : Subject) + (Status | Dataset : Subject : Trial)');

% boxplot(tbl.Accuracy, tbl.Dataset)
% compare(lm, lme)

