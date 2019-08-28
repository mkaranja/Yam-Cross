
suppressPackageStartupMessages(library(shiny))
suppressPackageStartupMessages(library(shinydashboard))
suppressPackageStartupMessages(library(shinyWidgets))
suppressPackageStartupMessages(library(shinyBS))

suppressPackageStartupMessages(library(magrittr))

suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(magrittr))
suppressPackageStartupMessages(library(tidyverse))

suppressPackageStartupMessages(library(highcharter))
suppressPackageStartupMessages(library(ggplot2))
suppressPackageStartupMessages(library(ggthemes))
suppressPackageStartupMessages(library(ECharts2Shiny))
suppressPackageStartupMessages(library(RColorBrewer))
suppressPackageStartupMessages(library(naniar))
suppressPackageStartupMessages(library(shinycssloaders))
suppressPackageStartupMessages(library(baRcodeR))

source("helpers.R") # Load all the code needed to show feedback on a button click

yamdata = read.csv("data/yamdata.csv") %>%
  mutate_all(as.character)
yamdata[,grep("Date", names(yamdata))] %<>% mutate_all(anytime::anydate)
yamdata[,c(grep("Total_", names(yamdata)), grep("Number_", names(yamdata)))] %<>% mutate_all(as.integer)

familydata = read.csv("data/familydata.csv") %>%
  mutate_all(as.character)
familydata[, grep("Date", names(familydata))] %<>% mutate_all(anytime::anydate)
familydata[,c("Start_of_Sowing","End_of_Sowing")] %<>% mutate_all(anytime::anydate)
familydata[,grep("Number_", names(yamdata))] %<>% mutate_all(as.integer)

# Clean data
yamdata$FamilyName = ifelse(!is.na(yamdata$Male_Genotype),paste0(yamdata$Female_Genotype,"/",yamdata$Male_Genotype),"")

yamdata = yamdata %>%
  dplyr::select(Site, FamilyName, PlantName, Genotype, Planting_Date, Bagging_Date, CrossNumber, Female_Genotype, Male_Genotype, everything())

yamdt = yamdata %>%
  dplyr::filter(!is.na(Male_Genotype))
yamdt %<>%
  dplyr::group_by(FamilyName) %>%
  summarise(
    Number_of_Plants = n(),
    First_Bagging_Date = min(na.omit(Bagging_Date)),
    Last_Bagging_Date = max(na.omit(Bagging_Date)),
    Number_of_Bags = max(na.omit(BagNo)),
    First_Pollination = min(na.omit(Pollination_Date)),
    Last_Pollination = min(na.omit(Pollination_Date)),
    First_Fruit_Set_Date = min(na.omit(Fruit_Set_Date)),
    Last_Fruit_Set_Date = max(na.omit(Fruit_Set_Date)),
    Number_of_Fruit_Sets = sum(na.omit(Number_of_Fruits)),
    First_Fruit_Harvest_Date = min(na.omit(Fruit_Harvest_Date)),
    Last_Fruit_Harvest_Date = max(na.omit(Fruit_Harvest_Date)),
    Number_of_Fruit_Harvested = sum(na.omit(Total_Fruits)),
    First_Seed_Processing_Date = min(na.omit(Seed_Processing_Date)),
    Last_Seed_Processing_Date = max(na.omit(Seed_Processing_Date)),
    Total_Seeds = sum(na.omit(Total_Seeds_Extracted))
  )
yam = dplyr::left_join(yamdata[,c("FamilyName", "Female_Genotype", "Male_Genotype",
                                  "Planting_Date")], yamdt, by = "FamilyName") %>%
  dplyr::filter(!is.na(Male_Genotype)) %>%
   unique()
yamdata$BagNo = NULL


familydata = dplyr::left_join(yam, familydata, by="FamilyName")
familydata = familydata %>%
  dplyr::select(FamilyName, everything())

familydata = familydata  %>%
  dplyr::filter(!is.na(FamilyName))

familydata = familydata %>%
  dplyr::select(FamilyName, "Female_Genotype", "Male_Genotype","Planting_Date","Number_of_Plants", "First_Bagging_Date",            
                "Last_Bagging_Date", "Number_of_Bags", "First_Pollination", "Last_Pollination", "Number_of_crosses", "First_Fruit_Set_Date",          
                "Last_Fruit_Set_Date", "Number_of_Fruit_Sets", "First_Fruit_Harvest_Date", "Last_Fruit_Harvest_Date", "Number_of_Fruit_Harvested", 
                "First_Seed_Processing_Date", "Last_Seed_Processing_Date", "Total_Seeds", "Available_Seeds", everything())
familydata$`Total Seeds Extracted` = NULL



colnames(familydata) = gsub("_"," ", names(familydata))
colnames(yamdata) = gsub("_"," ", names(yamdata))


# set data types

yamdata[,grep("Date", names(yamdata), value = T)] %<>% mutate_all(anytime::anydate)
yamdata[,c("PlantName","Genotype","Female Genotype","Male Genotype","Site","Pollinator Name","FamilyName")] %<>% mutate_all(as.factor)
yamdata[,c("Day","Number of Flowers","Number of Fruits","Total Fruits","Total Seeds Extracted")] %<>% mutate_all(as.integer)


ffacs <- c("FamilyName","Female Genotype","Male Genotype", "Storage Location")
fdates = grep("Date", names(familydata), value = T)
fnums <- c(grep("Number", names(familydata), value = T), grep("Total", names(familydata), value = T),
           "Available Seeds", "Seedlings Surviving","Germination Rate")

familydata[, ffacs] %<>% mutate_all(as.factor)
familydata[,fdates] %<>% mutate_all(anytime::anydate)
familydata[,fnums] %<>% mutate_all(as.integer)
