%% ///// AUTOCLAVE /////
% Automated pipeline for cleaning EEG data

%% PROJECT
% Open-Source Dataset Project Pre-Processing

%% PREPROCESSING
% Reads in parameters from a separate JSON file
settings = jsondecode(fileread('dataset_common_settings.json'));

param = settings.ALPH.param;

% reference channels to consider for averaging if its an edf or bdf file
if strcmp(param.fileType, '**/*.edf') || strcmp(param.fileType, '**/*.bdf')
    param.biosigRefChan = (1:param.numOfChannels); 
end

% CALL TO FUNCTION
funct = {
    @atclv2_step_open_source_check_previous_event...
};
    
% cell of @functionHandles
fullReport = atclv2_masterSelector(param,funct,...
    'auto',1,'save',0,'vol',1,'global',0);
% auto - whether to ask what file to run
% save - saves files during runtime
% vol - 
% global - 
%%
% Get a count of all the status
events = [];
for i = 1:size(fullReport, 1)
    events = [events unique(fullReport{i, 4}.outputEvents)];
end


