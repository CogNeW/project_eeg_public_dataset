%% ///// AUTOCLAVE /////
% Automated pipeline for cleaning EEG data

%% PROJECT
% Open-Source Dataset Project Pre-Processing

%% PREPROCESSING
           
% PATHS
param.inFolder = 'open_source_a_raw/PVT';% string, folder name
param.outFolder = 'open_source_b_rereferenced/PVT'; % string, folder name
param.fileType = '**/*.set'; % string, file extension

% GENERAL PARAMETERS
param.regEpoch = 1; % number, seconds
param.isDeltaUsed = 1; % flag whether delta value used
param.deltaToDelete = 0.0040; % delta value to consider
eventTabFlag = 0; % whether to run tabulation at end

% RESAMPLING PARAMETERS
param.resampleRate = 250;

% EVENT CLEANING PARAMETERS
param.startEventPattern = regexpPattern('S\s(\s)?\d(\d)?');
%{ '63351' '58982' '2184' '6553' '6' '7' '8' '9'}; % can be regex or a cell array
param.endEventPattern = regexpPattern('S\d\d\d');
%'10922';
param.eventsToStep = 1; % number how many events are between trials
param.numOfBoundaryEvents = 0; % number of how many extra boundary events to disregard in ITI calculation

% AVERAGE REFERENCE PARAMETERS (for .bdf and .edf file types)
numOfChannels = 64;
param.biosigRefChan = (1:numOfChannels); % reference channels to consider for averaging

% CALL TO FUNCTION
funct = {
    %@atclv2_step_resample...
    @atclv2_step_open_source_event_cleaning...
    %@atclv2_step_aveRef...
    %@atclv2_step_count_events
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
indexOfEvents = 10; % index of where the event names are based on num of steps applied

if eventTabFlag
    atclv2_util_event_tabulation(fullReport, eventFileName, indexOfEvents, param.startEventPattern, param.endEventPattern);
end

%% END OF PIPELINE