# EEG Public Dataset Project

## Introduction / Data flow

This repository contains scripts that were used in the paper, "Cognitive States Affect EEG Phase Prediction Accuracy". The scripts were organized as follows:

1. `AutoclaveDrivers/` - Driver scripts concerned with preprocessing EEG data using the [Autoclave pipeline](https://github.com/CogNeW/general_pipeline_autoclave). 
2. `ETPDrivers/` - Driver scripts concerned with executing the training and test phase of the [ETP algorithm](https://github.com/CogNeW/general_etp_algorithm).
3. `StatisticsDrivers/` - Driver scripts that ran the multilevel models from the output of the ETP algorithm.
4. `SummaryStatistics/` - Scripts that computed summary statistics on the EEG datasets
5. `FigureCreation/` - Scripts that created figures for the manuscript.

## Data Source

EEG data was pulled from multiple public datasets, as reference to in the manuscript here. **Include link to manuscript once it is published**

## Data Output

Finalized frozen version of the data are stored in one of the hard drives in Stratton.