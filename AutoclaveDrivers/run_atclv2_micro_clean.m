%% ///// AUTOCLAVE /////
% Automated pipeline for cleaning EEG data

%% PROJECT
% Open-Source Dataset Project Pre-Processing

%% PREPROCESSING
% Reads in parameters from a separate JSON file
settings = jsondecode(fileread('dataset_epoch_settings.json'));

param = settings.MICRO.param_rest;
if param.isTaskData
    param.events = loadjson(param.eventFileName);
end
% CALL TO FUNCTION
funct = {
    @atclv2_step_open_source_micro_event_cleaning...
    @atclv2_step_open_source_epoching
};
    
% cell of @functionHandles
fullReport = atclv2_masterSelector(param,funct,...
    'auto',1,'save',1,'vol',1,'global',0);
% auto - whether to ask what file to run
% save - saves files during runtime
% vol - 
% global - 