
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

yamdata = read.csv("data/yamdata.csv") %>%
  mutate_all(as.character)
#yamdata[,grep("Date", names(yamdata))] %<>% mutate_all(as.Date)
yamdata[,grep("_Genotype", names(yamdata))] %<>% mutate_all(as.factor)
yamdata[,c(grep("Total_", names(yamdata)), grep("Number_", names(yamdata)))] %<>% mutate_all(as.integer)

familydata = read.csv("data/familydata.csv") %>%
  mutate_all(as.character)
familydata$FamilyName = as.factor(familydata$FamilyName)
familydata[, grep("Date", names(familydata))] %<>% mutate_all(as.Date)
familydata[,c("Start_of_Sowing","End_of_Sowing")] %<>% mutate_all(as.Date, origin="1970-01-01")
familydata[,grep("_Genotype", names(familydata))] %<>% mutate_all(as.factor)
familydata[,grep("Number_", names(yamdata))] %<>% mutate_all(as.integer)
#familydata$Germination_Rate = as.numeric(familydata$Germination_Rate)

# Clean data
yamdata$FamilyName = ifelse(!is.na(yamdata$Male_Genotype),paste0(yamdata$Female_Genotype,"/",yamdata$Male_Genotype),"")

yamdata = yamdata %>%
  dplyr::select(PlantName, Planting_Date, Bagging_Date, CrossNumber, Female_Genotype, Male_Genotype, everything())

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
# seedlings_germinating = familydata %>%
#   dplyr::filter(!is.na(`Number_of_Seedlings_Germinating`))
# if(nrow(seedlings_germinating)>0){
# familydata$`Number yet to Germinate` = na.omit(as.integer(familydata$Number_of_Seeds_Sowed)) - 
#   na.omit(as.integer(familydata$`Number_of_Seedlings_Germinating`))
# # } else {
#   familydata$`Number yet to Germinate` = NA
# }
# Rename colnames

familydata = familydata %>%
  dplyr::select(FamilyName, "Female_Genotype", "Male_Genotype","Planting_Date","Number_of_Plants", "First_Bagging_Date",            
                "Last_Bagging_Date", "Number_of_Bags", "First_Pollination", "Last_Pollination", "Number_of_crosses", "First_Fruit_Set_Date",          
                "Last_Fruit_Set_Date", "Number_of_Fruit_Sets", "First_Fruit_Harvest_Date", "Last_Fruit_Harvest_Date", "Number_of_Fruit_Harvested", 
                "First_Seed_Processing_Date", "Last_Seed_Processing_Date", "Total_Seeds", "Available_Seeds", everything())
familydata$`Total Seeds Extracted` = NULL



colnames(familydata) = gsub("_"," ", names(familydata))
colnames(yamdata) = gsub("_"," ", names(yamdata))
