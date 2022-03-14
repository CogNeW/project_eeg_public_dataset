%% PROJECT
% Open-Source Dataset Project Pre-Processing
% This script will create a list of all channels for each dataset, so that
% we can exclude triggering channels from further analyses

%% PREPROCESSING
% Reads in parameters from a separate JSON file
settings = jsondecode(fileread('dataset_common_settings.json'));

toSkip = ["REP" "TRAN" "COG"];

actualReport = struct;

% Get field names to iterate through
datasetNames = fieldnames(settings);
for i = 1:length(datasetNames)
    if(ismember(datasetNames{i}, toSkip))
        continue;
    end

    param = settings.(datasetNames{i}).param;

    % CALL TO FUNCTION
    funct = {
        @atclv2_step_open_source_channel_list...
    };

    if(strcmp(datasetNames{i}, 'JAZZ'))
        funct = [{@atclv2_step_BVchanLabeler} funct];
    elseif(strcmp(datasetNames{i}, 'ENS'))
        funct = [{@atclv2_step_renameFile} funct];        
    end

    % reference channels to consider for averaging if its an edf or bdf file
    if strcmp(param.fileType, '**/*.edf') || strcmp(param.fileType, '**/*.bdf')
        param.biosigRefChan = (1:param.numOfChannels); 
    end

    % whether to add renaming step to avoid having it applied to all datasets
    if param.renamingFlag
        funct = [{@atclv2_step_renaming} funct];
    end

    param.chansInterest = {'Oz' 'O1' 'O2' 'Pz'};

    param.BPhp = 0.15;
    param.BPlp = 60;
    param.BPuseAuto = 1;
    
    % cell of @functionHandles
    fullReport = atclv2_masterSelector(param,funct,...
        'auto',1,'save',0,'vol',1,'global',0);
    actualReport.(datasetNames{i}) = fullReport;
    % auto - whether to ask what file to run
    % save - saves files during runtime
    % vol - 
    % global - 

    % TABULATE EVENTS (IF NEEDED)
    % Call the event name tabulation function if needed, params in dataset file

%     if param.eventTabFlag
%         atclv2_util_event_tabulation(fullReport, param.eventFileName, param.indexOfEvents, param.startEventPattern, param.endEventPattern);
%     end
end
%% END OF PIPELINE
innerParams = fieldnames(actualReport);
channelStruct = struct;

for i = 1:length(innerParams)

   innerParamName = innerParams{i};
   report = actualReport.(innerParamName);
   
   channels = [];
   
   for j = 1:size(report, 1)
       for k = 1:size(report, 2)
          if(strcmp(report{j, k}, 'atclv2_step_open_source_channel_list'))
             channelList = report{j, k+1}.channels;
             for l = 1:size(channelList, 1)
                 if(~any(strcmp(channels(:) , channelList(l))))
                     channels = [channels channelList(l)];
                 end
             end
             break;
          end
       end
   end
   
   
   channelStruct.(innerParamName) = channels; 
end