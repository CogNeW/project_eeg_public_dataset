% We will do some supplementary analysis here

% Compare the instantaneous power between the three conditions

anova1(tbl.Power, tbl.Status)
boxplot(tbl.Power, tbl.Status)