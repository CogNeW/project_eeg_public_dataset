% Quick code to get counts by split status
countcats(tbl(tbl.Dataset == 'PVTRest', :).Status)
%% Get accurate counts of each dataset
datasetNames = unique(tbl.Dataset);
for i = 1:length(datasetNames)
   curName = datasetNames(i)
   countcats(tbl(tbl.Dataset == curName, :).Status)
end
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