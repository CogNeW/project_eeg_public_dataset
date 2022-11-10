%% ///// AUTOCLAVE /////
% Automated pipeline for cleaning EEG data

%% PROJECT
% Open-Source Dataset Project Pre-Processing

%% PREPROCESSING
% Reads in parameters from a separate JSON file
settings = jsondecode(fileread('dataset_common_settings.json'));

param = settings.ALPH.param;

param.inFolder = "open_source_b_rereferenced/ALPH2/"
param.outFolder = "open_source_b_rereferenced/ALPH/not_chan_reduced/"
param.fileType = "**/*.set"

% CALL TO FUNCTION
funct = {
    @atclv2_step_renaming_alpha...
};
    
% cell of @functionHandles
fullReport = atclv2_masterSelector(param,funct,...
    'auto',1,'save',1,'vol',1,'global',0);
% auto - whether to ask what file to run
% save - saves files during runtime
% vol - 
% global - 
%%
% Get a count of all the status