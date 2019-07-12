# Yam script to download data from ona,
# organizing and re-uploading back to ona 
# for validation purposes as well as feed yam dashboard
rm(list=ls(all=T))
cat("\014")
#setwd("/srv/shiny-server/btract/yamcross/data")
setwd("C:/Users/Margaret/Desktop/yamcross/data")

suppressPackageStartupMessages(library(koboloadeR))
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(tidyr))
suppressPackageStartupMessages(library(RCurl))
suppressPackageStartupMessages(library(httr))
suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(jsonlite))
suppressPackageStartupMessages(library(magrittr))
library(naniar)

yam = koboloadeR::kobo_data_downloader("formid", "account:username", api="ona")  %>%
  mutate_all(as.character)

yam %<>% replace_with_na_all(~.x == "n/a")

# 1-----------planting_bagging_pollination
#,ends_with("plantDate"))

planting = dplyr::select(yam,  ends_with("Planting/Site"), ends_with("Planting/Site_Other"), ends_with("Planting/GPS"), 
                         ends_with("PlantBarcode/PlantName"), ends_with("GetPlantGenotype"), ends_with("Planting/Planting_Date")) %>%
  gather(id,Site,ends_with("Planting/Site"), na.rm=T) %>% 
  gather(id,Other,ends_with("Planting/Site_Other")) %>% 
  gather(id,Geopoint,ends_with("Planting/GPS"), na.rm=T) %>%
  gather(id,PlantName, ends_with("PlantBarcode/PlantName"), na.rm=T)  %>%
  gather(id, Genotype, ends_with("GetPlantGenotype"), na.rm = T) %>%
  gather(id,Planting_Date, ends_with("Planting/Planting_Date"), na.rm=T) %>% 
  dplyr::select(-starts_with("id")) %>%
  unique() 

# 2
bagging = dplyr::select(yam, ends_with("BaggingCode"), ends_with("BaggingDate"), ends_with("/bag_number")) %>%
  gather("id","PlantName", ends_with("BaggingCode"), na.rm=T) %>% 
  gather("id","Bagging_Date", ends_with("BaggingDate"), na.rm=T)  %>% 
  gather("id","BagCode", ends_with("/bag_number"), na.rm=T) %>% 
  dplyr::select(-starts_with("id"))
bagging = bagging %>% 
  dplyr::group_by(PlantName) %>% 
  dplyr::mutate(BagNo=row_number()) 

plantingBagging = dplyr::left_join(planting, bagging, by='PlantName')
plantingBagging[,grep("Date", names(plantingBagging))] %<>% mutate_all(as.Date)


# 3

pollination = dplyr::select(yam, ends_with("CrossNumber"), ends_with("FemaleCode"),ends_with("FirstPollination/MaleCode"),
                            ends_with("SelectedMaleName"), ends_with("PollinationDate"),ends_with("NumberOfInflorescence"), ends_with("NumberOfFlowers")) %>%
  gather("id","CrossNumber", ends_with("CrossNumber"), na.rm=T) %>%
  gather("id","BagCode",ends_with("FemaleCode"), na.rm=T) %>%
  gather("id","MalePlantName", ends_with("FirstPollination/MaleCode"), na.rm=T) %>% 
  gather("id","Male_Genotype", ends_with("SelectedMaleName"), na.rm=T) %>%
  gather("id","Pollination_Date", ends_with("PollinationDate"), na.rm=T) %>% 
  gather("id","Number_of_Inflorescence", ends_with("NumberOfInflorescence"), na.rm=T) %>% 
  gather("id","Number_of_Flowers", ends_with("NumberOfFlowers"), na.rm=T) %>%
  dplyr::select(-starts_with("id")) %>%
  unique()

# 4------------fruit_management
fruit_set = dplyr::select(yam, ends_with("FruitSetCode"),ends_with("FruitSets/FruitSetDate"),ends_with("NumberFruits")) %>%
  gather("id","CrossNumber", ends_with("FruitSetCode"), na.rm=F) %>%
  gather("id","Fruit_Set_Date", ends_with("FruitSets/FruitSetDate"), na.rm=T) %>%
  gather("id","Number_of_Fruits", ends_with("NumberFruits"), na.rm = T) %>%
  dplyr::select(-starts_with("id")) %>%
  unique()

# 5
fruit_harvest = dplyr::select(yam, ends_with("FruitHarvestCode"),ends_with("FruitHarvestDate"),ends_with("TotalFruits")) %>%
  gather("id","CrossNumber",ends_with("FruitHarvestCode"), na.rm=T) %>%
  gather("id","Fruit_Harvest_Date",ends_with("FruitHarvestDate"), na.rm=T) %>%
  gather("id","Total_Fruits",ends_with("TotalFruits"), na.rm=T) %>%
  dplyr::select(-starts_with("id")) %>%
  unique()


# 6-------------seed_management
seed_processing = dplyr::select(yam, ends_with("SeedProcessingCode"),ends_with("SeedProcessingDate"),ends_with("TotalSeedsExtracted"),ends_with("GoodSeedsExtracted")) %>%
  gather("id","CrossNumber",ends_with("SeedProcessingCode"), na.rm=T) %>%
  gather("id","Seed_Processing_Date",ends_with("SeedProcessingDate"), na.rm=T) %>%
  gather("id","Total_Seeds_Extracted",ends_with("TotalSeedsExtracted"), na.rm=T) %>%
  gather("id","Good_Seeds", ends_with("GoodSeedsExtracted"),na.rm=T) %>%
  dplyr::select(-starts_with("id")) %>%
  unique()

#####################################################################
# ------------- combine datasets

pollination = dplyr::left_join(plantingBagging, pollination, by="BagCode")
yamset = list(pollination, fruit_set, fruit_harvest,seed_processing)
# seeds_sowing,seedlings_germination,
#               transplant, transplant_survival, harvesting, tuber_storage, sprouting)
yamdata = Reduce(function(x,y) merge(x,y, all=T, by = "CrossNumber"), yamset)
yamdata = yamdata %>%
  dplyr::arrange(desc(BagCode,BagNo)) 
write.csv(yamdata, file = "yamdata.csv", row.names = F)

#######################################
family_dt = yamdata %>%
  dplyr::group_by(Genotype, Male_Genotype) %>%
  mutate(FamilyID = paste0(Genotype,"/",Male_Genotype), Number_of_crosses=n(), Available_Seeds = sum(as.integer(na.omit(Total_Seeds_Extracted))))
family_dt %<>%
  dplyr::select(Site, Genotype, Male_Genotype, FamilyID, Number_of_crosses, Available_Seeds) %>%
  unique() %>%
  .[complete.cases(.$Male_Genotype),]
  
write.csv(family_dt, file = "familydata.csv", row.names = F)

###################################################### FAMILY ID FROM YAMBASE

# 8------------------Nursery
sowing_seeds = dplyr::select(yam, ends_with("SeedSowingCode"),ends_with("SowingDate"),ends_with("NumberOfSeedsSowed"),ends_with("ScreenhouseNumber"),ends_with("ScreenhouseOperatorName")) %>%
   gather("id","CrossNumber",ends_with("SeedSowingCode"), na.rm=T) %>%
   gather("id","Sowing_Date",ends_with("SowingDate"),na.rm=T) %>%
   gather("id","Number_of_Seeds_Sowed", ends_with("NumberOfSeedsSowed"), na.rm = T) %>%
   gather("id","Screenhouse_Number", ends_with("ScreenhouseNumber"), na.rm=T) %>%
   gather("id","Screenhouse_Operator_Name", ends_with("ScreenhouseOperatorName"), na.rm=T) %>%
   dplyr::select(-starts_with("id")) %>%
  dplyr::arrange(desc(Sowing_Date)) %>%
  setDT()  
sowing_seeds$Number_of_Seeds_Sowed = as.integer(sowing_seeds$Number_of_Seeds_Sowed)

if(nrow(sowing_seeds)>0){
total_sowed = sowing_seeds %>%
   group_vars(CrossNumber) %>%
   summarise(Number_of_Seeds_Sowed = sum(na.omit(Number_of_Seeds_Sowed)), Start_of_Sowing = min(na.omit(Sowing_Date)), End_of_Sowing = max(na.omit(Sowing_Date)))

 sowed = sowing_seeds[,number := 1:.N, by = CrossNumber]
 s.sowed = reshape(sowed, direction = "wide", idvar = "CrossNumber", timevar = "number")
 
 s.seeds = s.sowed %>%
   dplyr::select(CrossNumber, contains("Seeds")) 
 s.seeds$Number_of_Seeds_Sowed = rowSums(s.seeds[,2:ncol(s.seeds)])
 s.seeds = s.seeds %>%
   dplyr::select(-starts_with("Number_of_Seeds_Sowed."))   
 
 s.dates = s.sowed %>%
   dplyr::select(CrossNumber, contains("Date"))
 s.dates$Start_of_Sowing = s.dates[,2]
 s.dates %<>% setDT()
 s.dates$End_of_Sowing = s.dates[,(ncol(s.dates)-1)]
 s.dates = s.dates %>%
   dplyr::select(-starts_with("Sowing_Date."))   
 
 s.operators = s.sowed %>%
   dplyr::select(CrossNumber, contains("Operator")) %>%
   unite("Screenhouse_Operators", contains("Operator"), sep=",")
 
 s.screenhouse = s.sowed %>%
   dplyr::select(CrossNumber, contains("Screenhouse_Number")) %>%
   unite("Screenhouse_Number", contains("Screenhouse_Number"), sep=",")
 
 seeds_sowing = Reduce(function(x,y) merge(x,y, all=T, by = "CrossNumber"), list(s.seeds, s.dates, s.operators, s.screenhouse))
} else {
  seeds_sowing = sowing_seeds
}
# Available seeds 
if(dim(sowing_seeds)[1]>0){
  seed_processing$Available_Seeds = as.integer(seed_processing$Good_Seeds) - as.integer(seeds_sowing$Number_of_Seeds_Sowed)
}else {
  seed_processing$Available_Seeds = as.integer(seed_processing$Good_Seeds)
}

# 9
seedlings_germination = dplyr::select(yam, ends_with("TrayCode"),ends_with("GerminationDate"),ends_with("NumberOfSeedlingsGerminating")) %>%
  gather("id","CrossNumber",ends_with("TrayCode"),na.rm = T) %>%
  gather("id","Germination_Date", ends_with("GerminationDate"), na.rm=T) %>%
  gather("id","Number_of_Seedlings_Germinating", ends_with("NumberOfSeedlingsGerminating"), na.rm=T) %>%
  dplyr::select(-starts_with("id")) %>%
  unique()

# 10------------------Transplanting
transplant = dplyr::select(yam, ends_with("TransplantCode"),ends_with("TransplantingDate"),ends_with("NumberOfSeedlingsTransPlanted"),ends_with("SeedlingsScreenhouseNumber")) %>%
  gather("id","CrossNumber",ends_with("TransplantCode"), na.rm = T) %>%
  gather("id","Transplanting_Date", ends_with("TransplantingDate"), na.rm = T) %>%
  gather("id","Number_of_Seedlings_Transplanted",ends_with("NumberOfSeedlingsTransPlanted"), na.rm=T) %>%
  gather("id","Seedlings_Screenhouse_Number",ends_with("SeedlingsScreenhouseNumber"), na.rm=T) %>%
  dplyr::select(-starts_with("id")) %>%
  unique()

# 11
transplant_survival = dplyr::select(yam,ends_with("FamilyCode"),ends_with("SurvivalDate"),ends_with("SeedlingsSurvived")) %>%
  gather("id","CrossNumber",ends_with("FamilyCode"), na.rm = T) %>%
  gather("id","Survival_Date", ends_with("SurvivalDate"), na.rm = T) %>%
  gather("id","Seedlings_Surviving", ends_with("SeedlingsSurvived"), na.rm = T) %>%
  dplyr::select(-starts_with("id")) %>%
  unique()

harvesting = dplyr::select(yam,  ends_with("HarvestCode"),ends_with("HarvestingDate"),ends_with("NumberOfTubers")) %>%
  gather("id","CrossNumber",ends_with("HarvestCode"),na.rm = T) %>%
  gather("id","Harvesting_Date", ends_with("HarvestingDate"), na.rm = T) %>%
  gather("id","Number_of_Tubers_Harvested", ends_with("NumberOfTubers"), na.rm = T) %>%
  dplyr::select(-starts_with("id")) %>%
  unique()

tuber_storage = dplyr::select(yam, ends_with("TuberStorageCode"),ends_with("StorageDate"),ends_with("NumberTubersStored"),ends_with("StorageLocation")) %>%
  gather("id","CrossNumber", ends_with("TuberStorageCode"), na.rm = T) %>%
  gather("id","Storage_Date", ends_with("StorageDate"), na.rm = T) %>%
  gather("id","Number_of_Tubers_Stored", ends_with("NumberTubersStored"), na.rm=T) %>%
  gather("id","Storage_Location", ends_with("StorageLocation"), na.rm=T) %>%
  dplyr::select(-starts_with("id")) %>%
  unique()

tuber_treatment = dplyr::select(yam, ends_with("TuberTreatmentCode"), ends_with("TreatmentDate"),ends_with("NumberTubersTreated")) %>%
  gather("id","CrossNumber",ends_with("TuberTreatmentCode"),na.rm = T) %>%
  gather("id", "Treatment_Date", ends_with("TreatmentDate"), na.rm = T) %>%
  gather("id","Number_of_Tubers_Treated", ends_with("NumberTubersTreated"), na.rm = T) %>%
  dplyr::select(-starts_with("id")) %>%
  unique()

# sprouting
sprouting = dplyr::select(yam, ends_with("SproutingCode"),ends_with("SproutingDate"), ends_with("NumberSprouting")) %>%
  gather("id","CrossNumber",ends_with("SproutingCode"),na.rm = T) %>% 
  gather("id","Sprouting_Date",ends_with("SproutingDate"), na.rm = T) %>% 
  gather("id","Number_of_Sprouting_Tubers", ends_with("NumberSprouting"), na.rm=T) %>%
  dplyr::select(-starts_with("id")) %>%
  unique()

#############################################################################################################################################

#############################################################################################################################################
# Get tokens
#############################################################################################################################################
raw.result <- GET("https://api.ona.io/api/v1/user.json", authenticate(user = "seedtracker",password = "Seedtracking101"))
raw.result.char<-rawToChar(raw.result$content)
raw.result.json<-fromJSON(raw.result.char)
TOKEN_KEY <- raw.result.json$temp_token


#delete

metaID <- readChar("metadataID.txt", 10)
hdr=c(Authorization=paste("Temptoken ",TOKEN_KEY))
DELETE(paste("https://api.ona.io/api/v1/metadata/",metaID),add_headers(Authorization=paste("Temptoken ",TOKEN_KEY)))

# upload
new_yamdata_id <- ''
while(new_yamdata_id == ''){
header=c(Authorization=paste("Temptoken ", TOKEN_KEY), `Content-Type` = 'multipart/form-data')
post.results <- postForm("https://api.ona.io/api/v1/metadata.json",
                         data_value='yamdata.csv',data_type='media',xform=294772,
                         data_file=fileUpload(filename = "yamdata.csv",contentType = 'text/csv'),
                         .opts=list(httpheader=header), verbose = TRUE)

## get ID

raw.result.json<-fromJSON(post.results)
new_yamdata_id <- raw.result.json$id
}
cat(new_yamdata_id, file = "metadataID.txt")

