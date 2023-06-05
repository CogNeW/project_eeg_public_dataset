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

metrics = ["Accuracy", "SNR", "IAF", "Power"];

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

metrics = ["Accuracy", "SNR", "IAF", "Power"];

for i = 1:length(metrics)
    subplot(2, 2, i);
    hold on;
    hp = bar(eval(strcat('average', metrics(i))), 'LineWidth', 2);
    hax = gca;
    hax.LineWidth = 1;
    hax.FontSize = 24;
    for b = 1:16
        vertIndexStart = 4 * (b - 1) + 1;
        vertIndexEnd = vertIndexStart + 3;
        
        if(b <= 5)
            
        else
            drawnow
            vertdat = hp.Face.VertexData(:, vertIndexStart:vertIndexEnd);
            hpatch = patch(vertdat(1,:),vertdat(2,:), 'white', 'FaceAlpha', 0);
            if(b <= 10)
                hatchfill2(hpatch,'single','HatchAngle',0,'hatchcolor', [0, 0, 0]);
            else
                hatchfill2(hpatch,'cross','HatchAngle',45,'hatchcolor', [0, 0, 0]);
            end
        end
        hp(1).FaceColor = 'none';
    end
    
    % b.FaceColor = 'flat';
    % b.CData = colorCode;
    errorbar(1:16, eval(strcat('average', metrics(i))), eval(strcat('sd', metrics(i))), 'k.', 'LineWidth', 2); % 'k.' specifies black dots for error bar markers
    xticks(1:16);
    xticklabels(cleanNames);
    xtickangle(45);
    ylabel(metrics(i));
%     set(gca,'TickLength',[0.0001, 0.0001])
    if(i == 4)
       ylim([0 6]); 
    end
end