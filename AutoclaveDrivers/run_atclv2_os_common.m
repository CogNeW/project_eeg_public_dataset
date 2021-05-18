%% ///// AUTOCLAVE /////
% Automated pipeline for cleaning EEG data

%% PROJECT
% Open-Source Dataset Project Pre-Processing

%% PREPROCESSING
           
% PATHS
param.inFolder = 'open_source_a_raw/PVT/task';% string, folder name
param.outFolder = 'open_source_b_rereferenced/PVT/task'; % string, folder name
param.fileType = '**/*.set'; % string, file extension

% GENERAL PARAMETERS
param.regEpoch = 1; % number, seconds
param.isDeltaUsed = 1; % flag whether delta value used
param.deltaToDelete = 0.0040; % delta value to consider
param.startEventPattern = regexpPattern('S\s(\s)?\d(\d)?');
param.endEventPattern = regexpPattern('S\d\d\d');
param.resampleRate = 250;
% ensure to specify for .bdf and .edf file types
% numOfChannels = 64;
% param.biosigRefChan = (1:numOfChannels);

% Flag to trigger event tabulation, only run when count_events has already been run with auto on 1.
eventTabFlag = 0;

% CALL TO FUNCTION
funct = {
    @atclv2_step_resample...
    @atclv2_step_open_source_event_cleaning...
    @atclv2_step_aveRef...
    @atclv2_step_count_events
	};

% cell of @functionHandles
fullReport = atclv2_masterSelector(param,funct,...
	'auto',1,'save',1,'vol',1,'global',0);
% auto - whether to ask what file to run
% save - saves files during runtime
% vol - 
% global - 

%% TABULATE EVENTS (IF NEEDED)
% Call the event name tabulation function if needed. 
eventFileName = 'PVT_event_codes.json';
indexOfEvents = 10;

if eventTabFlag
    atclv2_util_event_tabulation(fullReport, eventFileName, indexOfEvents, param.startEventPattern, param.endEventPattern);
end

%% END OF PIPELINE