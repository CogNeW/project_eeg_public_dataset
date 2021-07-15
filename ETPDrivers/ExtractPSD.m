% This script will extract the power spectral densities (PSD) from both rest and task data. These PSDs will then be used to validate the stability of the EEG waveform both by 1) checking the frequency with maximum power, 2) identifying the signal to noise ratio


% There are multiple ways to take the PSD of a signal.
% 1) Matlab's own dspdata.psd from the Signal Processing Toolbox
% 	https://www.mathworks.com/help/signal/ref/dspdata.psd.html
% 2) EEGlab's spectopo function which uses the above
% 	https://sccn.ucsd.edu/~arno/eeglab/auto/spectopo.html
% 3) Manually window and run a fourier transform like operation

addpath(strcat(pwd, '/../ETPAlgorithm/dependencies/eeglab2021.0'));
addpath(strcat(pwd, '/../ETPAlgorithm/utilities'));
addpath(strcat(pwd, '/../ETPAlgorithm'));
eeglab;

% TODO: Place all dataset and task names into a list and iterate through them
datasetName = 'PVT';
inputFolder = strcat(pwd, '/../FinalDatasets/', datasetName, '/not_chan_reduced/pseudorest/500/mat/');
% inputFolder = strcat(pwd, '/../FinalDatasets/', datasetName, '/not_chan_reduced/task/mat/');
outputFolder = strcat(pwd, '/../FinalDatasets/', datasetName, '/outputs/PSD/pseudorest/500/');

files = dir(inputFolder);

targetChannel = "Oz";
neighbors = ["O1", "O2", "Pz"];

for i = 1:length(files)
    fileName = files(i).name;
 
    if(~ endsWith(fileName, '.mat'))
       continue; 
    end
    filePath = strcat(inputFolder, fileName);
    
    EEG = load(filePath);

    electrodes = ExtractElectrodes(EEG.chanlocs, targetChannel, neighbors);
    % check if missing electrodes and skip
    if(size(electrodes, 2) ~= size(neighbors, 2) + 1)
        print(sprintf("%s missing electrodes", fileName));
        continue;
    end
    
    originalData = EEG.data;
    psdArray = [];
    
    for i = 1:size(originalData, 3)
        epoch = originalData(:, :, i);
        montagedEpoch = laplacianMontage(epoch, electrodes, 1, size(epoch, 2));
        [spectra, freqs] = spectopo(montagedEpoch, 0, 250);
        psd = struct('spectra', spectra, 'freqs', freqs);
        psdArray = [psd psdArray];
        clf();
    end

    outputFileName = strrep(fileName, 'DATA', 'PSD');
    outputFilePath = strcat(outputFolder, outputFileName);

    save(outputFilePath, 'psdArray');

end

