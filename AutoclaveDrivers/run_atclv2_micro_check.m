%% ///// AUTOCLAVE /////
% Automated pipeline for cleaning EEG data

%% PROJECT
% Open-Source Dataset Project Pre-Processing

%% PREPROCESSING
% Reads in parameters from a separate JSON file
settings = jsondecode(fileread('dataset_common_settings.json'));


param = settings.MICRO.param_rest;

% CALL TO FUNCTION
funct = {
    @atclv2_step_open_source_rest_events...
};
    
% cell of @functionHandles
fullReport = atclv2_masterSelector(param,funct,...
    'auto',0,'save',0,'vol',1,'global',0);
% auto - whether to ask what file to run
% save - saves files during runtime
% vol - 
% global - 

