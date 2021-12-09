setwd('R')

library(lme4)
library(stargazer)

p= "figure6data.csv"
mydata = read.csv(p)

mydata$Epoch<- factor(mydata$Epoch)
mydata$Epoch<- relevel(mydata$Epoch, ref = "Run")

mydata <-subset(mydata,Correct==1 & NanIdx==0 & RwdWinIdx==1) # only want to consider clean, correct trials (ie receiving reward)

## rat models
rat <- subset(mydata, Species=="R")
rat_ori <- subset(rat, Chan=="ori")
rat_rad <- subset(rat, Chan=="rad")

mdlR <- lmer(Peakrangenorm ~ Epoch*Chan + (1|ID/Session),rat)
mdlRori <- lmer(Peakrangenorm ~ Epoch + (1|ID/Session),rat_ori)
mdlRrad <- lmer(Peakrangenorm ~ Epoch + (1|ID/Session),rat_rad)

# save in text file
sink("fig6_rat_trials_lmer.txt")
print(summary(mdlR))
print("------------------------------------------------")
print(summary(mdlRori))
print("------------------------------------------------")
print(summary(mdlRrad))
print("------------------------------------------------")
model_results <- stargazer(mdlR,mdlRori,mdlRrad, type = "text", digits = 3, star.cutoffs = c(0.05,0.01,0.001), digit.separator = "",ci=TRUE,report="vcstp*",column.labels = c("Full rat", "Oriens", 'Radiatum'))


## ferret models
ferret <- subset(mydata, Species=="F")
ferret_ori <- subset(ferret, Chan=="ori")
ferret_rad <- subset(ferret, Chan=="rad")

mdlF <- lmer(Peakrangenorm ~ Epoch*Chan + (1|ID/Session),ferret)
mdlFori <- lmer(Peakrangenorm ~ Epoch + (1|ID/Session),ferret_ori)
mdlFrad <- lmer(Peakrangenorm ~ Epoch + (1|ID/Session),ferret_rad)

# save in text file
sink("fig6_ferret_trials_lmer.txt")
print(summary(mdlF))
print("------------------------------------------------")
print(summary(mdlFori))
print("------------------------------------------------")
print(summary(mdlFrad))
print("------------------------------------------------")
model_results <- stargazer(mdlF,mdlFori,mdlFrad, type = "text", digits = 3, star.cutoffs = c(0.05,0.01,0.001), digit.separator = "",ci=TRUE,report="vcstp*",column.labels = c("Full ferret", "Oriens", 'Radiatum'))


closeAllConnections()  # brute force way to close all text files
#save.image("~/R/fig5_trials_lmer.RData")
#rm(list=ls())          # clear workspace