% Going to go through each dataset and get a count of participants with the
% channels that I want

montage1 = ["POz", "Oz", "Pz", "PO4", "PO3"];
montage2 = ["Pz", "POz", "P1", "P2", "CPz"];
montage3 = ["Pz", "Cz", "P3", "P4", "Oz"];
montage4 = ["Pz", "P1", "P2", "CPz", "POz"];

montage = montage3;
missing = zeros(length(montage) + 2, 1);

innerParams = fieldnames(actualReport);
missingStruct = struct;

toDo = ["ENS"];

for i = 1:length(innerParams)

   innerParamName = innerParams{i};
   report = actualReport.(innerParamName);
   
%     if(~ismember(datasetNames{i}, toDo))
%         continue;
%     end
   
   channels = [];
   
   for j = 1:size(report, 1)
       for k = 1:size(report, 2)
          if(strcmp(report{j, k}, 'atclv2_step_open_source_channel_list'))
             channelList = report{j, k+1}.channels;
             anyMissing = 0;
             for l = 1:length(montage);
                 if(~any(strcmp(channelList(:) , montage(l))))
                     missing(l) = missing(l) + 1;
                     anyMissing = 1;
                 end
             end
             missing(length(montage) + 1) = missing(length(montage) + 1) + anyMissing; % counter increases if ANY channel is bad
             break; % Each row will only have one channel listing
          end
       end
   end
   missing(length(montage) + 2) = size(report, 1); % store the total count of participants for each dataset
   missingStruct.(innerParamName) = missing;
   missing = zeros(length(montage) + 2, 1);
   
end