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
 
no_rest = tbl(tbl.Domain ~= 'rest', :);
no_rest.Domain = categorical(no_rest.Domain);
no_rest.AttentionType = categorical(no_rest.AttentionType);

tbl.Status = categorical(tbl.Status);
tbl.Dataset  = categorical(tbl.Dataset);
tbl.Subject  = categorical(tbl.Subject);
tbl.Domain = categorical(tbl.Domain);

% sub = tbl(tbl.Dataset ~= 'ALPH', :);

% lm = fitlme(tbl, 'Accuracy ~ Status');
% lme = fitlme(tbl, 'Accuracy ~ Status + (1 | Dataset) + (1 | Dataset : Subject)');
% lme_power_int = fitlme(tbl, 'Accuracy ~ Status + Power + Power * Status + (Power | Dataset) + (Power | Dataset : Subject)');
% lme_power_snr = fitlme(tbl, 'Accuracy ~ Power * Status + SNR*Status + (SNR + Power | Dataset) + (SNR + Power| Dataset : Subject)');
% lme_power_snr_complete = fitlme(tbl, 'Accuracy ~ Power * Status + SNR*Status + Power*SNR*Status + (SNR*Power | Dataset) + (SNR*Power| Dataset : Subject)');
% lme_power_iaf = fitlme(tbl, 'Accuracy ~ Power * Status + IAF*Status + (IAF + Power | Dataset) + (IAF + Power| Dataset : Subject)');

% slm = fitlme(sub, 'Accuracy ~ Status');
% slme = fitlme(sub, 'Accuracy ~ Status + (1 | Dataset) + (1 | Dataset : Subject)');
% slme_power_int = fitlme(sub, 'Accuracy ~ Status + Power + Power * Status + (Power | Dataset) + (Power | Dataset : Subject)');
% slme_power_snr = fitlme(sub, 'Accuracy ~ Power * Status + SNR*Status + (SNR + Power | Dataset) + (SNR + Power| Dataset : Subject)');



% cd_lme = fitlme(no_rest, 'Accuracy ~ Domain + (1 | Dataset) + (1 | Dataset : Subject)');
% cd_lme1 = fitlme(no_rest, 'Accuracy ~ Status + Domain + (1 | Dataset) + (1 | Dataset : Subject)');
% cd_lme2 = fitlme(no_rest, 'Accuracy ~ Domain + Domain * Power + Domain * SNR + (SNR + Power | Dataset) + (SNR + Power | Dataset : Subject)');

at_lme = fitlme(no_rest, 'Accuracy ~ AttentionType + (1 | Dataset) + (1 | Dataset : Subject)');
% at_lme1 = fitlme(no_rest, 'Accuracy ~ Status + AttentionType + (1 | Dataset) + (1 | Dataset : Subject)');
at_lme2 = fitlme(no_rest, 'Accuracy ~ AttentionType + AttentionType*SNR*Power + (SNR*Power | Dataset) + (SNR*Power | Dataset : Subject)');


% boxplot(tbl.Accuracy, tbl.Dataset)
% compare(lm, lme)
% boxplot(tbl.Accuracy, {tbl.Status, tbl.Dataset}, 'ColorGroup', tbl.Status)
