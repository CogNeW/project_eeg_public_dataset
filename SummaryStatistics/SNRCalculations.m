% This script will display statistics of the SNR of each dataset
% Make sure to load the SNRReport.mat data file

load("SNRReport.mat");

varTypes = ["string", "double", "double"];
varNames = ["Dataset", "SNR", "PeakAlpha"];

SNRTable = table('Size', [0, 3], ...
 'VariableTypes',varTypes,'VariableNames',varNames);

noPeaks = strings(0, 0);
negativeSNR = strings(0, 0);

for i = 1:size(actualReport, 1)
    filePath = actualReport{i, 2};
    tokens = split(filePath, "/");
    datasetName = tokens{7};
    SNRStats = actualReport{i, 4};
    
%     if(strcmp(datasetName, "ENS"))
%        continue; 
%     end
    
%     An SNR of -999 means that the channel was not found

    if(~ isempty(SNRStats.peak_frequency) && SNRStats.peak_frequency ~= -999)
        SNRTable(end + 1, :) = {datasetName, SNRStats.peak_SNR, SNRStats.peak_frequency};
    elseif(isempty(SNRStats.peak_frequency))
        noPeaks(size(noPeaks, 2) + 1) = datasetName;
    end
    
    if(~ isempty(SNRStats.peak_frequency) && SNRStats.peak_SNR < 0)
        negativeSNR(size(negativeSNR, 2) + 1) = datasetName;
    end
    
end

% boxplot(SNRTable.SNR, SNRTable.Dataset)
% xlabel('Dataset Name')
% ylabel('SNR')
% title('SNR Distribution')
% boxplot(SNRTable.PeakAlpha, SNRTable.Dataset)
% xlabel('Dataset Name')
% ylabel('Peak Alpha Frequency')
% title('Individual Alpha Frequency')

% There are 120 individuals with no discernable alpha peak
% There are 269 individuals with a negative SNR

% p = anova1(SNRTable.SNR, SNRTable.Dataset)

% Calculate how many files are dropped as a result

totaltbl = tabulate(SNRTable.Dataset);
nptbl = tabulate(noPeaks);
ngtbl = tabulate(negativeSNR);

for i = 1:size(totaltbl, 1)
   totaltbl{i, 3} = 0; 
   totaltbl{i, 4} = 0; 
end
for i = 1:size(nptbl, 1)
   dataset = nptbl{i, 1}; 
   idx = -1;
   for j = 1:size(totaltbl, 1)
       if(strcmp(totaltbl{j, 1}, dataset))
          idx = j;
          break;
       end
   end
   totaltbl{idx, 3} = nptbl{i, 2};
end
for i = 1:size(ngtbl, 1)
   dataset = ngtbl{i, 1}; 
   idx = -1;
   for j = 1:size(totaltbl, 1)
       if(strcmp(totaltbl{j, 1}, dataset))
          idx = j;
          break;
       end
   end
   totaltbl{idx, 4} = ngtbl{i, 2};
end
cell2table(totaltbl, 'VariableNames', {'Dataset', 'Remaining Files', 'Negative SNR', 'No Peaks'})
% for i = 1:size(totaltbl, 1)
%    totaltbl{i, 5} = totaltbl{i, 3} + totaltbl{i, 4}; 
%    totaltbl{i, 6} = totaltbl{i, 5} / totaltbl{i, 2};
% end