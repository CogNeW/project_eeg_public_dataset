%% ///// AUTOCLAVE /////
% Automated pipeline for epoching EEG data

%% PROJECT
% Open-Source Dataset Project Epoching

%% PREPROCESSING
           
% PATHS
param.inFolder = 'open_source_b_rereferenced/PVT/task';% string, folder name
param.outFolder = 'open_source_c_epoched/PVT/rest'; % string, folder name
param.fileType = '**/*.set'; % string, file extension

% GENERAL PARAMETERS
param.regEpoch = 1; % number, seconds
param.startEpochFlag = 0; % where data is epoched with respect to start
param.epochTag = 'REST'; % name for file suffix to use
param.epochInterval = [0 1]; % interval to epoch over
param.events = loadjson('PVT_event_codes.json'); % JSON file with event names
param.fileDelimiter = '_'; % character between file name info
param.taskLabel = 'PVT'; % task being epoched
param.subjFormat = 'S[1-9][0-9]?'; % regex for subject info
param.runFormat = 's[1-9][1]?'; % regex for run info

% CALL TO FUNCTION
funct = {
    @atclv2_step_open_source_epoching
	};

% cell of @functionHandles
fullReport = atclv2_masterSelector(param,funct,...
	'auto',1,'save',1,'vol',1,'global',0);
% auto - whether to ask what file to run
% save - saves files during runtime
% vol - 
% global - 

%% END OF PIPELINE