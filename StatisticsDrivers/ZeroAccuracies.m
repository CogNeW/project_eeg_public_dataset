% This script will identify the number of data points with zero accuracy
% table.mat should be loaded which contains all observations

taskDatasets = ["ALPH" "AB" "B3" "COV" "ENS"];
pseudoRestDatasets = ["PVT"];
restDatasets = ["ABS" "JAZZ" "PVTRest" "SENS" "TMS" "MICRO"];
allDatasets = [taskDatasets pseudoRestDatasets restDatasets];

tiledlayout = tiledlayout(4, 3);


for datasetIndex = 1:length(allDatasets)
    datasetName = allDatasets(datasetIndex);
    nexttile;
    histogram(tbl(tbl.Dataset == datasetName, :).Accuracy);
    title(datasetName);
    
end