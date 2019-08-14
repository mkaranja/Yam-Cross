rm(list=ls(all=T))

setwd("/srv/shiny-server/btract/yamcross/data")

suppressPackageStartupMessages(library(koboloadeR))
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(tidyr))
suppressPackageStartupMessages(library(RCurl))
suppressPackageStartupMessages(library(httr))
suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(jsonlite))
suppressPackageStartupMessages(library(magrittr))
library(naniar)

yam = koboloadeR::kobo_data_downloader("formid", "accountName:username", api="ona")  %>%
  mutate_all(as.character)

yam %<>% replace_with_na_all(~.x == "n/a")

# 1-----------bagging
 

bagging = dplyr::select(yam,ends_with("GetSite"), ends_with("PlantCode"),ends_with("GetAccessionName"), ends_with("GetPlantingDate"),
                        ends_with("BaggingDate"), ends_with("/bag_number"),  ends_with("/Number_of_Spikes")) %>%
  gather("id","Site", ends_with("GetSite"), na.rm = F) %>% 
  gather("id","PlantName", ends_with("PlantCode"), na.rm = T) %>% 
  gather("id","Genotype", ends_with("GetAccessionName"), na.rm = T) %>% 
  gather("id","Planting_Date", ends_with("GetPlantingDate")) %>% 
  gather("id","Bagging_Date", ends_with("BaggingDate"), na.rm = T)  %>% 
  gather("id","BagCode", ends_with("/bag_number"), na.rm=T) %>% 
  gather("id","Number_of_Spikes", ends_with("/Number_of_Spikes")) %>% 
  dplyr::select(-starts_with("id"))

bagging = bagging %>% 
  dplyr::group_by(PlantName) %>% 
  dplyr::mutate(BagNo=row_number()) %>%
  dplyr::arrange(desc(BagNo))

# 3

pollination = dplyr::select(yam, ends_with("CrossNumber"), ends_with("FemaleCode"), ends_with("FemaleAccessionName"),ends_with("FirstPollination/MaleCode"),
                            ends_with("SelectedMaleName"), ends_with("PollinationDate"),ends_with("NumberOfInflorescence"), ends_with("NumberOfFlowers"),
                            ends_with("PollinatorName")) %>%
  gather("id","CrossNumber", ends_with("CrossNumber"), na.rm=T) %>%
  gather("id","Female_Genotype", ends_with("FemaleAccessionName"), na.rm=T) %>%
  gather("id","BagCode",ends_with("FemaleCode"), na.rm=T) %>%
  gather("id","MalePlantName", ends_with("FirstPollination/MaleCode"), na.rm=T) %>% 
  gather("id","Male_Genotype", ends_with("SelectedMaleName"), na.rm=T) %>%
  gather("id","Pollination_Date", ends_with("PollinationDate"), na.rm=T) %>% 
  gather("id","Number_of_Inflorescence", ends_with("NumberOfInflorescence"), na.rm=T) %>% 
  gather("id","Number_of_Flowers", ends_with("NumberOfFlowers"), na.rm=T) %>%
  gather("id","Pollinator_Name", ends_with("PollinatorName")) %>%
  dplyr::select(-starts_with("id")) %>%
  unique()

# 4------------fruit_management
fruit_set = dplyr::select(yam, ends_with("FruitSetCode"),ends_with("FruitSet_Date/FruitSetDate"),ends_with("NumberFruits")) %>%
  gather("id","CrossNumber", ends_with("FruitSetCode"), na.rm=F) %>%
  gather("id","Fruit_Set_Date", ends_with("FruitSet_Date/FruitSetDate"), na.rm=T) %>%
  gather("id","Number_of_Fruits", ends_with("NumberFruits"), na.rm = T) %>%
  dplyr::select(-starts_with("id")) %>%
  unique()

# 5
fruit_harvest = dplyr::select(yam, ends_with("FruitHarvestCode"),ends_with("FruitHarvest_Date/FruitHarvestDate"),ends_with("TotalFruits")) %>%
  gather("id","CrossNumber",ends_with("FruitHarvestCode"), na.rm=T) %>%
  gather("id","Fruit_Harvest_Date",ends_with("FruitHarvest_Date/FruitHarvestDate"), na.rm=T) %>%
  gather("id","Total_Fruits",ends_with("TotalFruits"), na.rm=T) %>%
  dplyr::select(-starts_with("id")) %>%
  unique()


# 6-------------seed_management
seed_processing = dplyr::select(yam, ends_with("SeedProcessingCode"),ends_with("SeedProcessing_Date/SeedProcessingDate"),
                                ends_with("TotalSeedsExtracted")) %>%
  gather("id","CrossNumber",ends_with("SeedProcessingCode"), na.rm=T) %>%
  gather("id","Seed_Processing_Date",ends_with("SeedProcessing_Date/SeedProcessingDate"), na.rm=T) %>%
  gather("id","Total_Seeds_Extracted",ends_with("TotalSeedsExtracted"), na.rm=T) %>%
  dplyr::select(-starts_with("id")) %>%
  unique()

#####################################################################
# ------------- combine datasets

crosses = dplyr::left_join(bagging, pollination, by="BagCode")
yamset = list(crosses, fruit_set, fruit_harvest,seed_processing)
# seeds_sowing,seedlings_germination,
#               transplant, transplant_survival, harvesting, tuber_storage, sprouting)
yamdata = Reduce(function(x,y) merge(x,y, all=T, by = "CrossNumber"), yamset)
#yamdata[,grep("Date", names(yamdata))] %<>% mutate_all(as.Date)
write.csv(yamdata, file = "yamdata.csv", row.names = F)

#######################################

###################################################### FAMILY ID FROM YAMBASE

# 8------------------Nursery
total_seeds = yamdata %>%
  dplyr::filter(!is.na(Female_Genotype),!is.na(Male_Genotype)) %>%
  dplyr::mutate(FamilyName = paste0(Female_Genotype,"/", Male_Genotype)) %>%
  dplyr::group_by(FamilyName) %>%
  dplyr::summarise(Number_of_crosses=n(),Start_of_Seeds_Extraction_Date = min(na.omit(Seed_Processing_Date)), 
                   End_of_Seeds_Extraction_Date = max(na.omit(Seed_Processing_Date)), 
                   Total_Seeds_Extracted = sum(na.omit(as.integer(Total_Seeds_Extracted))))

sowing_seeds = dplyr::select(yam, ends_with("SeedSowingCode"),ends_with("SowingDate"),ends_with("NumberOfSeedsSowed"),ends_with("ScreenhouseNumber"),ends_with("ScreenhouseOperatorName")) %>%
  gather("id","FamilyName",ends_with("SeedSowingCode"), na.rm=T) %>%
  gather("id","Sowing_Date",ends_with("SowingDate"),na.rm=T) %>%
  gather("id","Number_of_Seeds_Sowed", ends_with("NumberOfSeedsSowed"), na.rm = T) %>%
  gather("id","Screenhouse_Number", ends_with("ScreenhouseNumber"), na.rm=T) %>%
  gather("id","Screenhouse_Operator_Name", ends_with("ScreenhouseOperatorName"), na.rm=T) %>%
  dplyr::select(-starts_with("id")) %>%
  dplyr::arrange(desc(Sowing_Date)) %>%
  setDT()  
sowing_seeds$Number_of_Seeds_Sowed = as.integer(sowing_seeds$Number_of_Seeds_Sowed)

seeds_sowing = sowing_seeds %>% 
  dplyr::group_by(FamilyName) %>%
  # unite("Screenhouse_Operators", contains("Operator"), sep=",") %>%
  # unite("Screenhouse_Number", contains("Screenhouse_Number"), sep=",") %>%
  summarise(Start_of_Sowing = min(na.omit(Sowing_Date)), End_of_Sowing = max(na.omit(Sowing_Date)),Number_of_Seeds_Sowed = sum(na.omit(Number_of_Seeds_Sowed))) 
seeds_sowing = dplyr::left_join(total_seeds, seeds_sowing, by='FamilyName')
# Available seeds 
seeds_sowing$Available_Seeds = ifelse(!is.na(seeds_sowing$Number_of_Seeds_Sowed),
                                      (as.integer(seeds_sowing$Total_Seeds_Extracted) - as.integer(seeds_sowing$Number_of_Seeds_Sowed)),
                                      seeds_sowing$Total_Seeds_Extracted)

seeds_sowing$Available_Seeds = as.integer(seeds_sowing$Available_Seeds)
# 9
seedlings_germination = dplyr::select(yam, ends_with("TrayCode"),ends_with("Germination_Date/GerminationDate"),ends_with("NumberOfSeedlingsGerminating")) %>%
  gather("id","FamilyName",ends_with("TrayCode"),na.rm = T) %>%
  gather("id","Germination_Date", ends_with("Germination_Date/GerminationDate"), na.rm=T) %>%
  gather("id","Number_of_Seedlings_Germinating", ends_with("NumberOfSeedlingsGerminating"), na.rm=T) %>%
  dplyr::select(-starts_with("id")) %>%
  unique()
# seedlings_germination = seedlings_germination %>%
#   dplyr::group_by(FamilyName) %>%
#   summarise(First_Germination_Date = min(na.omit(Germination_Date)),
#             Last_Germination_Date = max(na.omit(Germination_Date)),
#             Number_of_Seedlings_Germinating = sum(na.omit(as.integer(Number_of_Seedlings_Germinating)))
#             )
# 10------------------Transplanting
transplant = dplyr::select(yam, ends_with("TransplantCode"),ends_with("Transplanting_Date/TransplantingDate"),ends_with("NumberOfSeedlingsTransPlanted"),ends_with("SeedlingsScreenhouseNumber")) %>%
  gather("id","FamilyName",ends_with("TransplantCode"), na.rm = T) %>%
  gather("id","Transplanting_Date", ends_with("Transplanting_Date/TransplantingDate"), na.rm = T) %>%
  gather("id","Number_of_Seedlings_Transplanted",ends_with("NumberOfSeedlingsTransPlanted"), na.rm=T) %>%
  gather("id","Seedlings_Screenhouse_Number",ends_with("SeedlingsScreenhouseNumber"), na.rm=T) %>%
  dplyr::select(-starts_with("id")) %>%
  unique()
# transplant = transplant %>%
#   dplyr::group_by(FamilyName) %>%
#   summarise(First_Transplanting_Date = min(na.omit(Transplanting_Date)),
#             Last_Transplanting_Date = max(na.omit(Transplanting_Date)),
#             Number_of_Seedlings_Transplanted = sum(na.omit(as.integer(Number_of_Seedlings_Transplanted)))
#   )
# 11
transplant_survival = dplyr::select(yam,ends_with("FamilyCode"),ends_with("Survival_Date/SurvivalDate"),ends_with("SeedlingsSurvived")) %>%
  gather("id","FamilyName",ends_with("FamilyCode"), na.rm = T) %>%
  gather("id","Survival_Date", ends_with("Survival_Date/SurvivalDate"), na.rm = T) %>%
  gather("id","Seedlings_Surviving", ends_with("SeedlingsSurvived"), na.rm = T) %>%
  dplyr::select(-starts_with("id")) %>%
  unique()

harvesting = dplyr::select(yam,  ends_with("HarvestCode"),ends_with("Harvesting_Date/HarvestingDate"),ends_with("NumberOfTubers")) %>%
  gather("id","FamilyName",ends_with("HarvestCode"),na.rm = T) %>%
  gather("id","Harvesting_Date", ends_with("Harvesting_Date/HarvestingDate"), na.rm = T) %>%
  gather("id","Number_of_Tubers_Harvested", ends_with("NumberOfTubers"), na.rm = T) %>%
  dplyr::select(-starts_with("id")) %>%
  unique()

tuber_storage = dplyr::select(yam, ends_with("TuberStorageCode"),ends_with("Storage_Date/StorageDate"),ends_with("NumberTubersStored"),ends_with("StorageLocation")) %>%
  gather("id","FamilyName", ends_with("TuberStorageCode"), na.rm = T) %>%
  gather("id","Storage_Date", ends_with("Storage_Date/StorageDate"), na.rm = T) %>%
  gather("id","Number_of_Tubers_Stored", ends_with("NumberTubersStored"), na.rm=T) %>%
  gather("id","Storage_Location", ends_with("StorageLocation"), na.rm=T) %>%
  dplyr::select(-starts_with("id")) %>%
  unique()

# sprouting
sprouting = dplyr::select(yam, ends_with("SproutingCode"),ends_with("Sprouting_Date/SproutingDate"), ends_with("NumberSprouting")) %>%
  gather("id","FamilyName",ends_with("SproutingCode"),na.rm = T) %>% 
  gather("id","Sprouting_Date",ends_with("Sprouting_Date/SproutingDate"), na.rm = T) %>% 
  gather("id","Number_of_Sprouting_Tubers", ends_with("NumberSprouting"), na.rm=T) %>%
  dplyr::select(-starts_with("id")) %>%
  unique()

#############################################################################################################################################

familydata = Reduce(function(x,y)merge(x,y,all=T, by='FamilyName'), list(seeds_sowing,seedlings_germination,transplant,
                                                                         transplant_survival,harvesting,tuber_storage,sprouting))
familydata$Germination_Rate = as.integer(familydata$Number_of_Seedlings_Germinating)/as.integer(familydata$Number_of_Seeds_Sowed)
familydata[, grep("Date",names(familydata))] %<>% mutate_all(as.Date)
write.csv(familydata, file = "familydata.csv", row.names = F)

#############################################################################################################################################
# Get tokens
#############################################################################################################################################
raw.result <- GET("https://api.ona.io/api/v1/user.json", authenticate(user = "seedtracker",password = "Seedtracking101"))
raw.result.char<-rawToChar(raw.result$content)
raw.result.json<-fromJSON(raw.result.char)
TOKEN_KEY <- raw.result.json$temp_token

# yamdata - crosses

crosses <- readChar("crossesID.txt", 10)
hdr=c(Authorization=paste("Temptoken ",TOKEN_KEY))
DELETE(paste("https://api.ona.io/api/v1/metadata/",crosses),add_headers(Authorization=paste("Temptoken ",TOKEN_KEY)))

# upload
new_crosses <- ''
while(new_crosses == ''){
  header=c(Authorization=paste("Temptoken ", TOKEN_KEY), `Content-Type` = 'multipart/form-data')
  post.crosses <- postForm("https://api.ona.io/api/v1/metadata.json",
                           data_value='yamdata.csv',data_type='media',xform='formid',
                           data_file=fileUpload(filename = "yamdata.csv",contentType = 'text/csv'),
                           .opts=list(httpheader=header), verbose = TRUE)
  
  ## get ID
  
  raw.crosses.json<-fromJSON(post.crosses)
  new_crosses <- raw.crosses.json$id
}
cat(new_crosses, file = "crossesID.txt")


# Family data

family <- readChar("familyID.txt", 10)
hdr=c(Authorization=paste("Temptoken ",TOKEN_KEY))
DELETE(paste("https://api.ona.io/api/v1/metadata/",family),add_headers(Authorization=paste("Temptoken ",TOKEN_KEY)))

# upload
new_family <- ''
while(new_family == ''){
  header=c(Authorization=paste("Temptoken ", TOKEN_KEY), `Content-Type` = 'multipart/form-data')
  post.family <- postForm("https://api.ona.io/api/v1/metadata.json",
                          data_value='familydata.csv',data_type='media',xform='formid',
                          data_file=fileUpload(filename = "familydata.csv",contentType = 'text/csv'),
                          .opts=list(httpheader=header), verbose = TRUE)
  
  ## get ID
  
  raw.family.json<-fromJSON(post.family)
  new_family <- raw.family.json$id
}
cat(new_family, file = "familyID.txt")

