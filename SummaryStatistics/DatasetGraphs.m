datasetNames = unique(tbl.Dataset);
datasetNames = ["ABSEO", "JAZZEO","MICROEO","PVTRestEO","TMSEO", ...
    "JAZZEC","MICROEC","PVTRestEC","SENSEC","TMSEC"...
    "ABtask","ALPHtask","B3task",...
    "COVtask","ENStask", "PVTtask"]
cleanNames = ["ABS", "JAZZ", "MICRO", "PVT", "TMS", "JAZZ",...
    "MICRO", "PVT", "SENS", "TMS", "AB", "ALPH", "B3", "COV", "ENS", "PVT"];
% colorCode = ["blue", "blue", "blue", "blue", "blue", "green", "green", "green", ...
%     "green", "green", "red", "red", "red", "red", "red", "red"];
colorCode = [[0, 0, 1];[0, 0, 1];[0, 0, 1];[0, 0, 1];[0, 0, 1];[0, 1, 0];[0, 1, 0];[0, 1, 0];...
    [0, 1, 0];[0, 1, 0];[1, 0, 0];[1, 0, 0];[1, 0, 0];[1, 0, 0];[1, 0, 0];[1, 0, 0]];
averageAccuracy = [];
sdAccuracy = [];
averageSNR = [];
sdSNR = [];
averageIAF = [];
sdIAF = [];
averagePower = [];
sdPower = [];

for i = 1:length(datasetNames)
   curName = datasetNames(i);
   averageAccuracy = [averageAccuracy, mean(tbl(tbl.Dataset == curName, :).Accuracy)];
   sdAccuracy = [sdAccuracy, std(tbl(tbl.Dataset == curName, :).Accuracy)];
   averageSNR = [averageSNR, mean(tbl(tbl.Dataset == curName, :).SNR)];
   sdSNR = [sdSNR, std(tbl(tbl.Dataset == curName, :).SNR)];
   averageIAF = [averageIAF, mean(tbl(tbl.Dataset == curName, :).IAF)];
   sdIAF = [sdIAF, std(tbl(tbl.Dataset == curName, :).IAF)];
   averagePower = [averagePower, mean(tbl(tbl.Dataset == curName, :).Power)];
   sdPower = [sdPower, std(tbl(tbl.Dataset == curName, :).Power)];
end

subplot(2, 2, 1);
hold on;
b = bar(averageAccuracy, 'LineWidth', 2);
b.FaceColor = 'flat';
b.CData = colorCode;
errorbar(1:16, averageAccuracy, sdAccuracy, 'k.', 'LineWidth', 2); % 'k.' specifies black dots for error bar markers
xticks(1:16);
xticklabels(cleanNames);
xtickangle(45);
ylabel('Accuracy');

hax = gca;
hax.LineWidth = 3;
hax.FontSize = 24;

subplot(2, 2, 2);
hold on;
b = bar(averageSNR, 'LineWidth', 2);
b.FaceColor = 'flat';
b.CData = colorCode;
errorbar(1:16, averageSNR, sdSNR, 'k.', 'LineWidth', 2); % 'k.' specifies black dots for error bar markers
xticks(1:16);
xticklabels(cleanNames);
xtickangle(45);
ylabel('SNR');

hax = gca;
hax.LineWidth = 3;
hax.FontSize = 24;

subplot(2, 2, 3);
hold on;
b2 = bar(averageIAF, 'LineWidth', 2);
errorbar(1:16, averageIAF, sdIAF, 'k.', 'LineWidth', 2); % 'k.' specifies black dots for error bar markers
b2.FaceColor = 'flat';
b2.CData = colorCode;
xticks(1:16);
xticklabels(cleanNames);
xtickangle(45);
ylabel('IAF');
% title('Here')

hax = gca;
hax.LineWidth = 3;
hax.FontSize = 24;

subplot(2, 2, 4);
hold on;
b3 = bar(averagePower, 'LineWidth', 2);
errorbar(1:16, averagePower, sdPower, 'k.', 'LineWidth', 2); % 'k.' specifies black dots for error bar markers
b3.FaceColor = 'flat';
b3.CData = colorCode;
% legend("EO", "EC", "Task");
xticks(1:16);
xticklabels(cleanNames);
xtickangle(45);
ylabel('Power');
ylim([0, 6]);



hax = gca;
hax.LineWidth = 3;
hax.FontSize = 24;