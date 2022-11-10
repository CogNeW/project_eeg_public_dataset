

inputFolder = strcat(pwd, '/../../datasets/ALPH_FINAL/mat/');
outputFolder = strcat(pwd, '/../../datasets/open_source_d_etp/', datasetName, '/all_epochs/train/');
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

files = dir(inputFolder);