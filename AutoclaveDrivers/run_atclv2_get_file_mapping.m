% This project will get the file name mappings from open_source_b to open_source_c

settings = jsondecode(fileread('dataset_epoch_settings.json'));

toSkip = ["REP" "TRAN" "COG"];
toDo = ["ALPH"];

% Get field names to iterate through
datasetNames = fieldnames(settings);
mappingReport = {};
for i = 1:length(datasetNames)

    if(~ismember(datasetNames{i}, toDo))
       continue; 
    end
    
    if(ismember(datasetNames{i}, toSkip))
        continue;
    end
    
    wholeSettings = settings.(datasetNames{i});
    innerParams = fieldnames(wholeSettings);
    
    for j = 1:length(innerParams)
    
        innerParamName = innerParams{j};
        
        % GENERAL PARAMETERS
        % Reads in parameters from a separate JSON file
        param = wholeSettings.(innerParamName);

        % Loads events based on file name passed in from JSON if its task data
        if param.isTaskData
            param.events = loadjson(param.eventFileName);
        end

        % CALL TO FUNCTION
        funct = {
            @atclv2_step_open_source_file_mapping
        };

        % cell of @functionHandles
        fullReport = atclv2_masterSelector(param,funct,...
            'auto',1,'save',0,'vol',1,'global',0);
        % auto - whether to ask what file to run
        % save - saves files during runtime
        % vol - 
        % global - 
        mappingReport = [mappingReport; fullReport];    
    end

end

%% END OF PIPELINE