# EEG Cognition Prediction

This repo will contain our main drivers for the Cognition Prediction project, particularly:
- Autoclave Drivers - will drive the Autoclave 2.0 EEG automated pipeline to standardize all EEG data from all open-source datasets downloaded, as well as perform epoching for EEG to be in a format that the ETP algorithm will be able to run on
	- **Note:** You will have to add this driver on your path. To run on particular data, you will need your working directory to be above all of your data. You'll specify its specific path in the driver.
- ETP Drivers - will take epoched EEG data generated from Autoclave 2.0 pipeline and run specialized version of ETP algorithm on epochs from each dataset