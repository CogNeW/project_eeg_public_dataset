% Quick code to get counts by split status
countcats(tbl(tbl.Dataset == 'PVTRest', :).Status)

%% Check Accuracies

boxplot(tbl.Accuracy, tbl.Dataset)

%% Plot Accuracy by power for each status

ectbl = tbl(tbl.Status == 'EC', :);
scatter(ectbl.Power, ectbl.Accuracy);

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

grpstats(tbl, "Dataset", ["mean", "std"], "DataVars", ["Accuracy", "Power", "SNR", "IAF"]);