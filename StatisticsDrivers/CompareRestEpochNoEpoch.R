# This script will run a Circular ANOVA using the bpnreg package (https://www.rdocumentation.org/packages/bpnreg/versions/2.0.2)

library("bpnreg")
library("R.matlab")
library("data.table")

# Read in all mat files into rest and task vector
basePath = "C:/Users/Brian Kim/Documents/OneDrive - Drexel University/Documents/classes/cognew/mxene-eeg/MXeneEEG/PVTRestEpochNoEpoch.mat"

file = readMat(basePath)

epochAngles = file$epochAngles
noEpochAngles = file$noEpochAngles

numAngles = length(epochAngles) + length(noEpochAngles)
status = rep(0, numAngles)
status[(length(epochAngles) + 1):numAngles] = 1

dt = data.table(angles = c(epochAngles, noEpochAngles), status=status)
fit = bpnr(pred.I = angles ~ 1 + status, data = dt, its = 1000)
coef_circ(fit, type="categorical", units="degrees")
