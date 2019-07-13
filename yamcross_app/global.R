
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

yamdata = fread("data/yamdata.csv")
familydt = read.csv("data/familydata.csv") 


# Clean data
yamdata = yamdata[,-c("Site","Other","Geopoint")]
colnames(yamdata)[3] = "Female_Genotype"
yamdata$Family = ifelse(!is.na(yamdata$Male_Genotype),paste0(yamdata$Female_Genotype,"/",yamdata$Male_Genotype),"")

yamdata = yamdata %>%
   dplyr::select(PlantName, Planting_Date, Bagging_Date, BagCode, CrossNumber, Family,Female_Genotype, Male_Genotype, everything())


yamdt = yamdata %>%
  dplyr::group_by(Family) %>%
  summarise(
    Number_of_Plants = n(),
    First_Bagging_Date = min(na.omit(Bagging_Date)),
    Last_Bagging_Date = max(na.omit(Bagging_Date)),
    Number_of_Bags = max(na.omit(BagNo)),
    First_Pollination = min(na.omit(Pollination_Date)),
    Last_Pollination = min(na.omit(Pollination_Date)),
    Number_of_crosses = n_distinct(na.omit(CrossNumber)),
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
yam = dplyr::left_join(yamdata[,c("Family", "Female_Genotype", "Male_Genotype","Planting_Date")], yamdt, by = "Family") %>%
  dplyr::filter(!is.na(Male_Genotype)) %>%
  unique()
yamdata$BagNo = NULL
yamdata[,c("Female_Genotype", "Male_Genotype", "Family")] %<>% mutate_all(as.factor) 
yamdata[,c("Number_of_Flowers","Number_of_Fruits","Total_Fruits", "Total_Seeds_Extracted","Good_Seeds")] %<>% mutate_all(as.integer) 
yamdata[,c("Planting_Date","Bagging_Date", "Pollination_Date", "Fruit_Set_Date","Fruit_Harvest_Date",
           "Seed_Processing_Date")] %<>% mutate_all(as.Date, '1492-11-29', format='%Y-%m-%d')

familydt %<>% mutate_all(as.character)
colnames(familydt)[1]="Family"
familydt$Total_Seeds = NULL

familydata = dplyr::left_join(yam, familydt, by="Family")
familydata = familydata %>%
  dplyr::select(Family, everything())

familydata[,c("Female_Genotype", "Male_Genotype", "Family")] %<>% mutate_all(as.factor) 
familydata[,c("Number_of_Plants","Number_of_Bags","Number_of_crosses", "Number_of_Fruit_Sets", "Number_of_Fruit_Harvested", "Number_of_Seeds_Sowed",
              "Available_Seeds","Number_of_Seedlings_Germinating","Number_yet_to_Germinate","Number_of_Seedlings_Transplanted","Seedlings_Surviving",
              "Number_of_Tubers_Harvested","Number_of_Tubers_Stored","Number_of_Sprouting_Tubers")] %<>% mutate_all(as.integer) 
familydata[grep("Date", names(familydata)),] %<>% mutate_all(as.Date, '1492-11-29', format='%Y-%m-%d')

familydata = familydata  %>%
  dplyr::filter(!is.na(Family))

# Rename colnames
colnames(familydata) = gsub("_"," ", names(familydata))
colnames(yamdata) = gsub("_"," ", names(yamdata))

familydata = familydata %>%
  dplyr::select(Family, "Female Genotype", "Male Genotype","Planting Date","Number of Plants", "First Bagging Date",            
                "Last Bagging Date", "Number of Bags", "First Pollination", "Last Pollination", "Number of crosses", "First Fruit Set Date",          
                "Last Fruit Set Date", "Number of Fruit Sets", "First Fruit Harvest Date", "Last Fruit Harvest Date", "Number of Fruit Harvested", 
                "First Seed Processing Date", "Last Seed Processing Date", "Total Seeds", "Available Seeds", everything())
  
#familydata$`Germination Rate` = as.numeric(familydata$`Germination Rate`)



