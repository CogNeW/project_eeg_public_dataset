Place all ETP scripts related to analyzing Public Dataset files here.

These are the necessary steps to run the ETP Algorithm

1) Make sure that PVT has been duplicated to a PVTRest (that only contains the rest files)
2) Run ETPSplitRest.m to convert the resting data into cell arrays that have been split into a training and test set
3) Run ETPTrainDataset.m
4) Run ETPTestDataset.m