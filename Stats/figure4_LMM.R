setwd('R')

library(lme4)
library(stargazer)

p = "figure4data.csv"
mydata = read.csv(p)

newdata = mydata[mydata$MovFlag %in% c("imm","mov"),]

# full model with interaction
mdl <- lmer(Peakrangenorm ~ MovFlag*Species + Chan + (1|Species/ID/Session),newdata)

# separate model for each species to accurately estimate single factor coeffs
rat <- subset(newdata, Species=="R")
ferret <- subset(newdata, Species=="F")

mdlR <- lmer(Peakrangenorm ~ MovFlag + Chan + (1|ID/Session),rat)
mdlF <- lmer(Peakrangenorm ~ MovFlag + Chan + (1|ID/Session),ferret)


# save in text file
sink("fig3_mov_vs_imm_lmer.txt")
print(summary(mdl))
print("------------------------------------------------")
print(summary(mdlR))
print("------------------------------------------------")
print(summary(mdlF))
print("------------------------------------------------")
model_results <- stargazer(mdl,mdlR,mdlF, type = "text", digits = 3, star.cutoffs = c(0.05,0.01,0.001), digit.separator = "",ci=TRUE,report="vcstp*",column.labels = c("Full", "Rat", 'Ferret'))



closeAllConnections()  # brute force way to close all text files
#save.image("~/R/fig3_mov_v_imm_lmer.RData")
#rm(list=ls())          # clear workspace