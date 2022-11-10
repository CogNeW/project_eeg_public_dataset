% This script will combined the SNR table with the mapping report
% table. Two tables will be read -> actualReport (containing SNR values),
% SNRMapping (containing mapping of file names),


% sub-02_ses-02_task-offlinecatch_run-01_eeg_Renamed_checked_reSmpl_Clean_BP0p15-60_aveRef_Tab
% sub-02_ses-02_task-offlinecatch_run-01_eeg_Renamed_checked_reSmpl_Clean_BP0p15-60_aveRef_Tab.set

for i = 1:size(actualReport, 1)
    b_name = actualReport{i, 1}(1:end-4);
    row = -1;
    for j = 1:size(mappingReport, 1)
        if(strcmp(mappingReport{j, 4}.open_source_b, b_name))
            mappingReport{j, 4}.SNR = actualReport{i, 4}.peak_SNR;
            mappingReport{j, 4}.IAF = actualReport{i, 4}.peak_frequency;
            row = j;
        end
    end
    if(row == -1)
        fprintf("Could not find matching file for %s...\n", b_name);
        continue;
    end
end

save('SNRTableCombined.mat', 'mappingReport');