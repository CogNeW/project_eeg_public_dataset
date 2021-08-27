% This script will aggregate all phase angles of the rest and task set
% separately and run a Watson-Williams test (circular equivalent of 
% ANOVA/t-test) to compare the differences in mean

% addpath('dependencies/CircStat2012a/');
addpath('dependencies/PhasePACK/');
addpath('dependencies/github_repo/');

restFolder = strcat(pwd, '/../datasets/open_source_e_statistics/rest/');
taskFolder = strcat(pwd, '/../datasets/open_source_e_statistics/task/');

restFiles = dir(restFolder);
restAngles = [];

for i = 1:length(restFiles)

    restFileName = restFiles(i).name;
    if(~ endsWith(restFileName, '.mat'))
        continue; 
    end
    restFileName
    
    restFilePath = strcat(restFolder, restFileName);
    currentRestAngles = load(restFilePath).output.allPhases;
    restAngles = [restAngles currentRestAngles];
    
end

taskFiles = dir(taskFolder);
taskAngles = [];

for i = 1:length(taskFiles)

    taskFileName = taskFiles(i).name;
    if(~ endsWith(taskFileName, '.mat'))
        continue; 
    end
    taskFileName
    
    taskFilePath = strcat(taskFolder, taskFileName);
    currentTaskAngles = load(taskFilePath).output.allPhases;
    taskAngles = [taskAngles currentTaskAngles];
    
end

% Tried the watson william test from the circstat package, but our data
% does not satisfy that the resultant vector must have length < 0.45

% Trying another package: https://github.com/iandol/spikes/tree/master/Various/PhasePACK
% which has a non-parametric test for comparing the means of two datasets
cmean_test(restAngles', taskAngles')
% circ_cmtest(restAngles, taskAngles)