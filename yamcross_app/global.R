
suppressPackageStartupMessages(library(shiny))
suppressPackageStartupMessages(library(shinydashboard))
suppressPackageStartupMessages(library(shinyWidgets))
suppressPackageStartupMessages(library(shinyBS))

suppressPackageStartupMessages(library(magrittr))

suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(magrittr))
suppressPackageStartupMessages(library(tidyverse))

suppressPackageStartupMessages(library(highcharter))

yamdata = fread("data/yamdata.csv")
yamdata = yamdata[,-c("Site","Other","Geopoint")]
yamdata$FamilyID = ifelse(!is.na(yamdata$Genotype) & !is.na(yamdata$Male_Genotype),paste0(yamdata$Genotype,"/",yamdata$Male_Genotype),"")
yamdata = yamdata %>%
   dplyr::select(PlantName, Genotype, Planting_Date, Bagging_Date, BagCode, CrossNumber, FamilyID, everything())

yamdt = yamdata %>%
  dplyr::group_by(Genotype, Male_Genotype) %>%
  summarise(
    First_Bagging_Date = min(na.omit(Bagging_Date)),
    Last_Bagging_Date = max(na.omit(Bagging_Date)),
    Number_of_Bags = max(na.omit(BagNo)),
    First_Pollination = min(na.omit(Pollination_Date)),
    Last_Pollination = min(na.omit(Pollination_Date)),
    Number_of_crosses = n_distinct(na.omit(CrossNumber))
    )

colnames(yamdata) = gsub("_"," ", names(yamdata))

familydata = read.csv("data/familydata.csv")
familydata = familydata %>%
  dplyr::select(FamilyID, everything())

#familydata[,c("Genotype", "Male_Genotype")] %<>% mutate_all(as.factor) 
colnames(familydata) = gsub("_"," ", names(familydata))


