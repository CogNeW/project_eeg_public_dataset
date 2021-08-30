# This script will run a Circular ANOVA using the bpnreg package (https://www.rdocumentation.org/packages/bpnreg/versions/2.0.2)

library("bpnreg")
library("R.matlab")
library("data.table")

# Read in all mat files into rest and task vector
baseFolder = "C:/Users/brian/OneDrive - Drexel University/Documents/classes/cognew/mxene-eeg/MXeneEEG/open_source_e_statistics/"
restFolder = paste(baseFolder, "rest/", sep="")
taskFolder = paste(baseFolder, "task/", sep="")

restAngles = list()
restPower = list()
taskAngles = list()
taskPower = list()

setwd(restFolder)
for (fileName in dir()){
  if(!endsWith(fileName, ".mat")){
    next
  }
  restData = readMat(paste(restFolder, fileName, sep=""))
  restAngles = c(restAngles, restData$output[2])
  restPower = c(restPower, restData$output[3])
}
restAngles = unlist(restAngles)
restPower = unlist(restPower)

setwd(taskFolder)
for (fileName in dir()){
  if(!endsWith(fileName, ".mat")){
    next
  }
  taskData = readMat(paste(taskFolder, fileName, sep=""))
  taskAngles = c(taskAngles, taskData$output[2])
  taskPower = c(taskPower, taskData$output[3])
}
taskAngles = unlist(taskAngles)
taskPower = unlist(taskPower)

numAngles = length(restAngles) + length(taskAngles)
status = rep(0, numAngles)
status[(length(restAngles) + 1):numAngles] = 1

dt = data.table(angles = c(restAngles, taskAngles), powers = c(restPower, taskPower),
                status=status)
fit = bpnr(pred.I = angles ~ 1 + status, data = dt, its = 1000)
fit_p = bpnr(pred.I = angles ~ 1 + status + powers, data = dt, its = 1000)
coef_circ(fit, type="categorical", units="degrees")
