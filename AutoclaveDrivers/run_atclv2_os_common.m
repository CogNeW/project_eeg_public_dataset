%% ///// AUTOCLAVE /////
% Automated pipeline for cleaning EEG data

%% PROJECT
% Open-Source Dataset Project Pre-Processing

%% PREPROCESSING
% Reads in parameters from a separate JSON file
param = jsondecode(fileread('dataset_common_settings.json')).ALPH.param;

% GENERAL PARAMETERS - flags whether to apply additional steps on data
renamingFlag = 1; % whether events need to be renamed
param.biosigRefChan = (1:param.numOfChannels); % reference channels to consider for averaging
eventTabFlag = 0; % whether to run tabulation at end

% CALL TO FUNCTION
funct = {
    @atclv2_step_resample...
    @atclv2_step_open_source_event_cleaning...
    @atclv2_step_aveRef...
    @atclv2_step_count_events
	};

% whether to add renaming step to avoid having it applied to all datasets
if renamingFlag
    funct = [{@atclv2_step_renaming} funct];
end

% cell of @functionHandles
fullReport = atclv2_masterSelector(param,funct,...
	'auto',1,'save',1,'vol',1,'global',0);
% auto - whether to ask what file to run
% save - saves files during runtime
% vol - 
% global - 

%% TABULATE EVENTS (IF NEEDED)
% Call the event name tabulation function if needed, params in dataset file

if eventTabFlag
    atclv2_util_event_tabulation(fullReport, param.eventFileName, param.indexOfEvents, param.startEventPattern, param.endEventPattern);
end

%% END OF PIPELINE