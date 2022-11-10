% This script will use files identified by atclv pipeline as bad (with
% EXCLUDE or DELETE) in the name, and then delete the corresponding epoched
% and ETP files. 

% This script assumes that 'find . -name "*EXCLUDE*" ' and 
% 'find . -name "*DELETE*" ' was executed in the terminal and a 
% list of the files are saved in a common file (TODELETE.txt)

fid = fopen('TODELETE.txt');
tline = fgetl(fid);
while ischar(tline)
   parts = split(tline, '/');
   datasetName = char(parts(2));
   fname = char(parts(end));
   fname = fname(1:end-4);
   tline = fgetl(fid);
   
   for i = 1:size(mappingReport, 1)
       if(strcmp(mappingReport{i, 4}.open_source_b, fname))
           etpOutput = replace(mappingReport{i, 4}.open_source_c, "REST_DATA", "TASK_OUTPUT");
           etpFilePath = strcat('../../datasets/open_source_d_etp/', datasetName, '/all_epochs/test/', etpOutput);
           if(~isfile(etpFilePath))
              fprintf("DNE: %s\n", etpFilePath);
           else
               delete(etpFilePath);
           end
           
%            Remove file from open_source_c_epoched
% Documents/datasets/open_source_c_epoched/ALPH/not_chan_reduced/rest/mat
           cFilePath = strcat('../../datasets/open_source_c_epoched/', datasetName, '/not_chan_reduced/rest/mat/', ...
                            mappingReport{i, 4}.open_source_c);
           if(~isfile(cFilePath))
              fprintf("CFILE PATH DNE: %s\n", cFilePath);
           else
               delete(cFilePath);
           end   
       end
   end
end