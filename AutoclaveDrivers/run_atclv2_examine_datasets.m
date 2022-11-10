%% ///// AUTOCLAVE /////
% Examining data by printing out drift and frequency spectra

%% PROJECT
% Open-Source Dataset Project Epoching

%% PREPROCESSING 

% GENERAL PARAMETERS
% Reads in parameters from a separate JSON file
% settings = jsondecode(fileread('dataset_common_settings.json'));
settings = jsondecode(fileread('dataset_epoch_settings.json'));

% Get field names to iterate through
datasetNames = fieldnames(settings);
% toSkip = ["PVT" "ALPH" "COV" "AB" "B3" "ENS" "JAZZ" "REP" "TRAN" "COG"];
toSkip = ["JAZZ"];
for i = 1:length(datasetNames)
    
    if(ismember(datasetNames{i}, toSkip))
        continue;
    end


    
    param = settings.(datasetNames{i}).param;
    if(strcmp(datasetNames{i}, 'JAZZ'))
       funct = {
        @atclv2_step_BVchanLabeler...
        % @atclv2_step_checkFlatChans...
        @atclv2_step_showAmp...
        % @atclv2_step_showSpectra...
       };
    else
        funct = {
            @atclv2_step_checkFlatChans...
            % @atclv2_step_showAmp...
            % @atclv2_step_showSpectra...
        }; 
    end
    
    % CALL TO FUNCTION


    % reference channels to consider for averaging if its an edf or bdf file
    if strcmp(param.fileType, '**/*.edf') || strcmp(param.fileType, '**/*.bdf')
        param.biosigRefChan = (1:param.numOfChannels); 
    end

    % cell of @functionHandles
    fullReport = atclv2_masterSelector(param,funct,...
        'auto',1,'save',0,'vol',1,'global',0);
    % auto - whether to ask what file to run
    % save - saves files during runtime
    % vol - 
    % global - 

end