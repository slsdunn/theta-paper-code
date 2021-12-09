setwd('R')

library(lme4)
library(stargazer)

p = "figure5data.csv"
mydata = read.csv(p)

newdata = mydata[mydata$MovFlag %in% c("imm","mov"),]

# full model with interaction
mdl <- lmer(Peakrangenorm ~ MovFlag*DrugFlag + (1|ID/Chan/Session),newdata)

# separate model for each mov condition to accurately estimate single factor coeffs
mov <- subset(newdata, MovFlag=="mov")
imm <- subset(newdata, MovFlag=="imm")

mdlmov <- lmer(Peakrangenorm ~ DrugFlag  + (1|ID/Chan/Session),mov)
mdlimm <- lmer(Peakrangenorm ~ DrugFlag  + (1|ID/Chan/Session),imm)


# save in text file
sink("fig4_lmer.txt")
print(summary(mdl))
print("------------------------------------------------")
print(summary(mdlmov))
print("------------------------------------------------")
print(summary(mdlimm))
print("------------------------------------------------")
model_results <- stargazer(mdl,mdlmov,mdlimm, type = "text", digits = 3, star.cutoffs = c(0.05,0.01,0.001), digit.separator = "",ci=TRUE,report="vcstp*",column.labels = c("Full", "mov", 'imm'))



closeAllConnections()  # brute force way to close all text files
#save.image("~/R/fig4_atropine_lmer.RData")
#rm(list=ls())          # clear workspace