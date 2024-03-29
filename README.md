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

## Pipeline Steps

To replicate our analysis pipeline, the following steps will need to be taken:

1. Download all raw data and place into a single directory organized as follows:
	- open_source_a_raw/
	|_ dataset_name/
		|_ rest/
		|_ task/
	- The rest/ and task/ folders should have all the raw datasets. The current pipeline is able to handle .eeg, .edf, .bdf, .set, and .rdf extensions.
2. Create a `dataset_common_settings.json` (Refer to `AutoclaveDrivers/ex_dataset_common_settings.json`) folder which will store metadata about each dataset including
	- path to input and output folders
		- The input folder will be `open_source_a_raw`. You can call the output folder whatever you like, but we called it `open_source_b_rereferenced`
	- file type
	- target sampling rate
	- file representing the event codes (only for task data)
		- Refer to `ex_B3_event_codes.json` for an example file. In general, the start_events key should have the flags corresponding to the start of a trial, and the same for end_events.
3. Run `AutoclaveDrivers/run_atclv2_os_common.m`, which will read from the file from Step 2, and apply the following preprocessing steps: 1) removal of bad channels, 2) cleaning of artifacts, 3) checking for flag channels, 4) resampling, 5) Event flag cleaning, 6) Bandpass filtering, 7) Counting events (for debugging)
4. We can now extract the 1/f background lines, SNR and individual alpha frequency for each recording. Run the `AutoclaveDrivers/run_atclv2_checkSNR.m` script, which will go through each of the output files and compute the metrics.
	- The output variable `actualReport` contains file paths relative to `open_source_b_rereferenced` but must be changed to be more consistent with what future steps will require. To do so, we must run `AutoclaveDrivers/run_atclv2_get_file_mapping.m`, and then `SummaryStatistics/CombineSNR.m`. The finalized version will be stored in `MinPeakMEMOIZEDeBOSCSNRTableCombined.mat`.
5. Create a `dataset_epoch_settings.json` file (Refer to `AutoclaveDrivers/ex_dataset_epoch_settings.json`) folder which will store metadata on how to epoch each dataset including
	- path to input and output folders
		- The input folder will be the output from Step 3, which in our case was `open_source_b_rereferenced`. You can call the output folder whatever you like, but we called it `open_source_c_epoched`
	- Timing offsets for the epoch intervals for the flags identified previously
	- Regular expressions indicating the original file, so we can extract the subject ID, day, and experiment ID.
6. The files from `open_source_b_rereferenced` will now be epoched using the `AutoclaveDrivers/run_atclv2_os_epoching.m` file.
7. One dataset (Zanesco et al., 2020) had a different recording structure, where periods of eyes-open and eyes-closed resting-state happened consecutively in a single block. Run the `AutoclaveDrivers/run_atclv2_micro_clean.m` script to split this dataset into separate eyes-open and eyes-closed data.
7. Steps 5 and 6 only did epoching on the task datasets, since they are based on flags and use EEGLab's `pop_epoch` function. Epoching for the resting-state data will be done manually in one of two ways
	- 2000ms:2000ms split between train and test epochs, which was the original analysis of the paper. To do so, run the `ETPDrivers/ETPSplitRest.m` and `ETPDrivers/ETPSplitMicro.m` scripts. 
	- 803ms:2725ms split between train and test epochs, which was done to equalize the distribution of training and testing epoch lengths between the task and rest conditions. To do so, run the `ETPDrivers/ETPSplitRestUneven.m` and `ETPDrivers/ETPSplitMicroUneven.m` scripts.
8. For each of the recordings, we will compute the distribution of instantaneous alpha power to build artifact rejection criteria during the ETP Algorithm. Run `SummaryStatistics/PowerCalculationTrain.m`, which will create `trainIndividualTableAll.mat`, which contains the mean and standard deviation of instantaneous alpha power for each training file in `open_source_c_epoched`.
9. Run the training portion of the ETP algorithm through `ETPDrivers/ETPTrainDataset.m`. The outputs of this script will be in `open_source_d_etp`. 
10. We need to do step 8, but for the test recordings as well (this was not done simultaneously to make the process slightly more efficient, since not all files that are candidates for train will also be candidate for test due to file rejection). Run `SummaryStatistics/PowerCalculationTest.m`, which will create `testIndividualTableAll.mat`, which contains the mean and standard deviation of instantaneous alpha power for each test file in `open_source_c_epoched`.
11. Run the test portion of the ETP algorithm through `ETPDrivers/ETPTestDataset.m`. The outputs of this script will be in `open_source_d_etp`. 
12. At this point, the ETP algorithm's predictions are made but are separated into different files for each recording of a dataset. We will run the `StatisticsDrivers/AggregateIndividuals.m` script to aggregate all of these different files and store them into a single table for each dataset, which will be output into separate files in `open_source_e_statistics`.
13. We will now run the linear mixed-effects models in the `StatisticsDrivers/MixedEffectsModels.m` script. The output variable from this script is `lm_struct`, which will contain the multiple models (basic, intermediate, full) used for this analysis.
14. There are multiple supplemental analysis and sanity check scripts available:
	- `ETPDrivers/CalculateDatasetBreakdownETP.m` will go through the `open_source_d_etp` folders and calculate how many epochs were used in the testing and training portions of the ETP for each dataset. This analysis was used to equalize the number of epochs across the conditions. 
	- `SummaryStatistics/SNRCalculations.m` goes through the struct from `MinPeakMEMOIZEDeBOSCSNRTableCombined.mat` and plots some summary statistics while also computing the correlation betwee Zrenner's and eBOSC's approach.
	- `SummaryStatistics/SupplementaryAnalyses.m` contains multiple short scripts used for plotting and doing sub-analyses

## Data Output

Finalized frozen version of the data are stored in one of the hard drives in Stratton.