% Quick code to get counts by split status
countcats(tbl(tbl.Dataset == 'PVTRest', :).Status)
%% Get accurate counts of each dataset
datasetNames = unique(tbl.Dataset);
for i = 1:length(datasetNames)
   curName = datasetNames(i)
   countcats(tbl(tbl.Dataset == curName, :).Status)
end

countcats(tbl.Status)
%% Get number of participants per dataset

% ABSEO 95, ABtask 41, ALPHtask 14, B3task 21, COVtask 24, ENStask 29, JAZZEC 38, JAZZEO 38, MICROEC 152, MICROEO 152, PVTRestEC 35, PVTRestEO 34, PVTtask 32, SENSEC 19, TMSEC 16, TMSEO 15


totalSubject = 0;

for i = 1:length(datasetNames)
   curName = datasetNames(i)
   length(unique(tbl(tbl.Dataset == curName, :).Subject))
   totalSubject = totalSubject + length(unique(tbl(tbl.Dataset == curName, :).Subject));
end

%% Get breakdown by prediction

taskDatasets = ["AB" "ALPH" "B3" "COV" "ENS" "PVT"];
% taskDatasets = ["ALPH" "B3" "COV" "ENS"];
pseudoRestDatasets = ["PVT"];
restDatasets = ["JAZZ" "PVTRest" "SENS" "TMS" "MICRO" "ABS"];
allDatasets = [taskDatasets pseudoRestDatasets restDatasets];

datasetNames = fieldnames(epochLengths);
predictionBreakdown = table;
predictionBreakdown.name = string(datasetNames);
predictionBreakdown.type = ["Task","Task","Task","Task","Task","Task","EC", "EO", "EO", "EC", "EC", "EC", "EO", "EC", "EO", "EO"]';

predCount = [];

for i = 1:length(datasetNames)
%    datasetName = datasetNames{i};
   curName = datasetNames(i);
   if(any(ismember(taskDatasets, curName)))
        curName = strcat(curName, 'task');
   end
   sum(countcats(tbl(tbl.Dataset == curName, :).Status))
   predCount = [predCount, sum(countcats(tbl(tbl.Dataset == curName, :).Status))];
end

predictionBreakdown.predictions = predCount';

%% Check Accuracies

boxplot(tbl.Accuracy, tbl.Dataset)

%% Compare Correlations Between SNR and Power
corr(tbl.Power, tbl.SNR);


%% Plot Accuracy by power for each status

ectbl = tbl(tbl.Status == 'EC', :);

scatter(ectbl.SNR, ectbl.Accuracy);

ec_means = zeros(25, 1);
ec_stds = zeros(25, 1);

for i = 1:25
    ec_means(i) = mean(ectbl(ectbl.SNR < i & ectbl.SNR > i-1, :).Accuracy);
    ec_stds(i) = std(ectbl(ectbl.SNR < i & ectbl.SNR > i-1, :).Accuracy);
end

hold on;
errorbar(ec_means, ec_stds, 'r', 'LineWidth', 3);

eotbl = tbl(tbl.Status == 'EO', :);
scatter(eotbl.Power, eotbl.Accuracy);

tasktbl = tbl(tbl.Status == 'task', :);
scatter(tasktbl.Power, tasktbl.Accuracy);


%% Plot boxplot of accuracies

h = boxplot(tbl.Accuracy, tbl.Status, 'Orientation', 'horizontal');
set(h,{'linew'},{2})

%% Draw Accuracy by power with line of best fit

scatter(tbl.Power, tbl.Accuracy);

% These fit lines might make it more confusing
figure
myfittype=fittype('a +b*log(x)',...
'dependent', {'y'}, 'independent',{'x'},...
'coefficients', {'a','b'});
myfit=fit(tbl.Power,tbl.Accuracy,myfittype);
plot(myfit, tbl.Power, tbl.Accuracy);

%% Compare Accuracy and SNR between all datasets

grpstats(tbl, "Dataset", ["mean", "std"], "DataVars", ["Accuracy", "Power", "SNR", "IAF"])

grpstats(tbl, "Status", ["mean", "std"], "DataVars", ["Accuracy", "Power", "SNR", "IAF"])
%% Try to simulate Zrenner's plot drawing SNR versus Accuracy plots for different levels of power

quartiles = [0, 0.25, 0.5, 0.75, 1];
colors = [99, 0, 204; 250, 194, 10; 23, 138, 3; 0, 143, 250]/255;

datasets = string(unique(tbl.Dataset));

for di = 1:length(datasets)
    dataset_name = datasets(di)

    alph = tbl(tbl.Dataset == dataset_name, :);
    alph = tbl;
    
    clf;
    hold on;
    for i = 1:4
        power_level_low = quantile(alph.Power, quartiles(i));
        power_level_high = quantile(alph.Power, quartiles(i + 1));
        power_level_high
        colors(i, :)

        rows = alph(alph.Power > power_level_low & alph.Power <= power_level_high, :);
        height(rows)
        rows(rows.SNR > 20, :) = [];
        scatter(rows.SNR, rows.Accuracy, 1, colors(i, :), 'filled');
    end

    legend('Lowest', 'Low', 'Medium', 'High', 'AutoUpdate','off');

    for i = 1:4
        power_level_low = quantile(alph.Power, quartiles(i));
        power_level_high = quantile(alph.Power, quartiles(i + 1));

        rows = alph(alph.Power > power_level_low & alph.Power <= power_level_high, :);
        rows(rows.SNR > 20, :) = [];

        X = [ones(height(rows), 1) rows.SNR];
        coeffs = X \ rows.Accuracy;
        regression_line = X * coeffs;

        plot(rows.SNR, regression_line, 'Color', colors(i, :), 'LineWidth', 3);
    end
    
    disp('here');
    
end

%% Match Zrenner's Analysis of looking at the median error deviation in prediction

% Split the trials based on amplitude quartiles
% Split SNR also into quartiles within each block and then compute the
% average accuracy (broken into degrees)

quartiles = [0, 0.25, 0.5, 0.75, 1];
for qi = 1:4
    power_level_low = quantile(tbl.Power, quartiles(qi));
    power_level_high = quantile(tbl.Power, quartiles(qi + 1));
    
    rows = tbl(tbl.Power > power_level_low & tbl.Power <= power_level_high, :);
    low_snr_rows = rows(rows.SNR > 0 & rows.SNR <= 1, :);
    high_snr_rows = rows(rows.SNR > 19 & rows.SNR <= 20, :);
    
    [mean(low_snr_rows.Accuracy), mean(high_snr_rows.Accuracy)]

end



%% Get number of recordings each participants was in

datasets = string(unique(tbl.Dataset));

for di = 1:length(datasets)
    dataset_name = datasets(di)
    unique(tbl(tbl.Dataset == dataset_name & tbl.Subject == "S01", 1:5))
    unique(tbl(tbl.Dataset == dataset_name & tbl.Subject == "S1", 1:5))
    unique(tbl(tbl.Dataset == dataset_name & tbl.Subject == "S010003", 1:5))
    unique(tbl(tbl.Dataset == dataset_name & tbl.Subject == "S001", 1:5))
    
end

%%

means = [75.604, 72.838, 74.516];
stds = [22.544, 23.759, 22.777];
labels = {"EC", "EO", "Task"};
bar(means, 'LineWidth', 2);
hold on;
er = errorbar(means, stds, "LineStyle", "none", "LineWidth", 3);
er.Color = [1 0 0];
set(gca, 'xticklabel', labels);
set(gca, 'linewidth', 2);
set(gca, 'FontSize', 24);

% We will do some supplementary analysis here

% Compare the instantaneous power between the three conditions

% anova1(tbl.Power, tbl.Status)
% boxplot(tbl.Power, tbl.Status)

%%

% Compare the accuracies between the three conditions

conditions = ["EC", "EO", "task"];

for i = 1:length(conditions)
    condition = conditions(i)
    disp("Accuracy");
    mean(tbl(tbl.Status == condition, :).Accuracy)
    std(tbl(tbl.Status == condition, :).Accuracy)
    disp("Power");
    mean(tbl(tbl.Status == condition, :).Power)
    std(tbl(tbl.Status == condition, :).Power)
    disp("SNR");
    mean(tbl(tbl.Status == condition, :).SNR)
    std(tbl(tbl.Status == condition, :).SNR)
end

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

accuracies = [ .76039, .76039 - 0.016107, .76039 - .017376];
errors = [ 0.00056911, 0.00079621, 0.0006034];

h = barh(accuracies);
set(h,{'linew'},{2});
title('Accuracy by Cognitive State', 'FontSize', 24);
xlabel('Accuracy', 'FontSize', 24);
ylabel('Cognitive State', 'FontSize', 24);

set(gca, 'yticklabel', { 'EC', 'EO', 'Task' });

ax = gca;
ax.FontSize = 24;
ax.LineWidth = 3;


% h = boxplot(tbl.Accuracy, tbl.Status, 'Orientation', 'horizontal');
% set(h,{'linew'},{2});
% title('Accuracy by Cognitive State', 'FontSize', 24);
% xlabel('Accuracy', 'FontSize', 24);
% ylabel('Cognitive State', 'FontSize', 24);

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