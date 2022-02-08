%% ///// AUTOCLAVE /////
% Automated pipeline for cleaning EEG data

%% PROJECT
% Open-Source Dataset Project Pre-Processing

%% PREPROCESSING
% Reads in parameters from a separate JSON file
settings = jsondecode(fileread('dataset_epoch_settings.json'));


param = settings.MICRO.param_rest;

% CALL TO FUNCTION
funct = {
    @atclv2_step_open_source_rest_events...
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
statuses = [];
for i = 1:size(fullReport, 1)
    statuses = [statuses fullReport{i, 4}.status];
end

% -5 seems to be the most common, followed by -2 and -1
% -999 appears twice

count = 0;
for i = 1:size(EEG.event, 2)
   if(strcmp(EEG.event(i).type, 'S  1'))
       count = count + 1;
   end
end