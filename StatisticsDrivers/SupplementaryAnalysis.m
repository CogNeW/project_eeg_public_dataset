% We will do some supplementary analysis here

% Compare the instantaneous power between the three conditions

% anova1(tbl.Power, tbl.Status)
% boxplot(tbl.Power, tbl.Status)

%%

% Compare the accuracies between the three conditions
datasetName = "PVTEOPost";
inputFolder = strcat(pwd, '/../../datasets/open_source_d_etp/', datasetName, '/all_epochs/test/');

files = dir(inputFolder);
accuracies = [];

for i = 1:length(files)
    fileName = files(i).name;

    if(~ endsWith(fileName, '.mat'))
       continue; 
    end
    filePath = strcat(inputFolder, fileName);

    etpStruct = load(filePath);
    accuracies = [accuracies (1 - abs(etpStruct.output.allPhases) / pi)];

end

mean(accuracies)
std(accuracies)

% ECPre = 71.16% +/- 23.73%
% EOPre = 74.23% +/- 22.97%
% EOPost = 73.73% +/- 23.29%
% Intertrial Interval = 75.22% +/- 22.50%

%%

% Get the learned cycle lengths

datasetName = "PVTECPre";
inputFolder = strcat(pwd, '/../../datasets/open_source_d_etp/', datasetName, '/all_epochs/train/');

files = dir(inputFolder);
cycleLengths = [];

for i = 1:length(files)
    fileName = files(i).name;

    if(~ endsWith(fileName, '.mat'))
       continue; 
    end
    filePath = strcat(inputFolder, fileName);

    etpStruct = load(filePath);
    cycleLengths = [cycleLengths etpStruct.output.cycleEstimate*4];

end

mean(cycleLengths)
std(cycleLengths)

% eo pre (93.54 +/- 10.41)
% eo post (93.29 +/- 9.22)
% ec pre (95.06 +/- 9.01)
% task (91.4 +/- 9.85)
% 

%%
% Boxplot with increased thickness
h = boxplot(tbl.Accuracy, tbl.Status, 'Orientation', 'horizontal');
set(h,{'linew'},{2});
title('Accuracy by Cognitive State', 'FontSize', 24);
xlabel('Accuracy', 'FontSize', 24);
ylabel('Cognitive State', 'FontSize', 24);
ax = gca;
ax.FontSize = 24;
ax.LineWidth = 3;
%%
% Boxplot with increased thickness
h = boxplot(tbl.Power, tbl.Status, 'Orientation', 'horizontal');
set(h,{'linew'},{2});
set(h,{'linew'},{2});
title('Power by Cognitive State', 'FontSize', 24);
xlabel('Power (μV)', 'FontSize', 24);
ylabel('Cognitive State', 'FontSize', 24);
ax = gca;
ax.FontSize = 24;
ax.LineWidth = 3;
%%
h = boxplot(tbl.SNR, tbl.Status, 'Orientation', 'horizontal');
set(h,{'linew'},{2});
set(h,{'linew'},{2});
title('SNR by Cognitive State', 'FontSize', 24);
xlabel('SNR (dB)', 'FontSize', 24);
ylabel('Cognitive State', 'FontSize', 24);
ax = gca;
ax.FontSize = 24;
ax.LineWidth = 3;
%%
scatter(tbl.Power, tbl.Accuracy);
title('Power versus Accuracy', 'FontSize', 24);
xlabel('Power (μV)', 'FontSize', 24);
ylabel('Accuracy', 'FontSize', 24);
ax = gca;
ax.FontSize = 24;
ax.LineWidth = 3;