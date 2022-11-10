%% ///// AUTOCLAVE /////
% Automated pipeline for cleaning EEG data

%% PROJECT
% Open-Source Dataset Project Pre-Processing

%% PREPROCESSING
% Reads in parameters from a separate JSON file
settings = jsondecode(fileread('dataset_common_settings.json'));

toSkip = ["REP" "TRAN" "COG"];
toDo = ["JAZZ"];

% Get field names to iterate through
datasetNames = fieldnames(settings);
for i = 1:length(datasetNames)
    if(ismember(datasetNames{i}, toSkip))
        continue;
    end
  
%     if(~ismember(datasetNames{i}, toDo))
%         continue;
%     end

    param = settings.(datasetNames{i}).param;

    % CALL TO FUNCTION
    funct = {
        @atclv2_step_removeBadChans...
        @atclv2_step_clean_artifacts...
        @atclv2_step_checkFlatChans...
        @atclv2_step_resample...
        @atclv2_step_open_source_event_cleaning...
        @atclv2_step_bandpass...
        @atclv2_step_count_events
    };

% REMOVING AVERAGE REFERENCE FOR NOW:        @atclv2_step_aveRef...

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
    if strcmp(datasetNames{i}, "ALPH")
        funct = [{@atclv2_step_renaming_alpha} funct];
    elseif param.renamingFlag
        funct = [{@atclv2_step_renaming} funct];
    end

%     param.chansInterest = {'POz' 'Oz' 'Pz' 'PO4' 'PO3'};
%     param.chansInterest = {'Pz' 'P1' 'P2' 'CPz' 'POz'}; % TEST1
    param.chansInterest = {'Pz' 'Oz' 'Cz' 'P4' 'P3'}; % TEST2
    
    param.BPhp = 0.15;
    param.BPlp = 60;
    param.BPuseAuto = 1;

    param.badChannels = ["EXG1" "EXG2" "EXG3" "EXG4" "EXG5" "EXG6" "EXG7" "EXG8" "EXG9" "EXG10" "EXG11" "EXG12" "EXG13" "EXG14" "EXG15" "EXG16" ...
        "HEOG" "VEOG" "Status", "TRIG", "StimTrak", "SCR", "EKG", "EOG"];
    
    % cell of @functionHandles
    fullReport = atclv2_masterSelector(param,funct,...
        'auto',1,'save',1,'vol',1,'global',0);
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