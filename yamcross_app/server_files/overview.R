
source("helper_funs.R")

overview <- function(env_serv) with(env_serv, local({
  
  
  plantsIn <- reactive({
    result = yamdata %>%
      dplyr::group_by(Genotype) %>%
      tally()
  })
  
  crossesIn <- reactive({
    result = yamdata %>%
      dplyr::group_by(Genotype, `Male Genotype`) %>%
      tally()
  })
  
  availableseedsIn <- reactive({
    familydata %>% dplyr::filter(`Available Seeds`>0)
    
  })
  
  crossesIn <- reactive({
    result = yamdata %>%
      dplyr::group_by(Genotype, `Male Genotype`) %>%
      tally()
  })
  
 

 output$infoboxOut <- renderUI({
   
   div(
     argonRow(
         argonInfoCard2(
           value = nrow(familydata),
           title = "Crosses", 
           description = "Unique genotypes", 
           stat = NULL,
           icon = argonIcon("planet"), 
           icon_background = "primary",
           shadow = TRUE,
           background_color = NULL
         ),
       argonInfoCard2(
         value = sum(na.omit(availableseedsIn()$`Available Seeds`)), 
         title = "Available Seeds", 
         stat = nrow(availableseedsIn()), 
         description = "Unique genotypes", 
         icon = icon("chart-pie"), 
         icon_background = "success",
         shadow = TRUE,
         background_color = NULL
       ),
       argonInfoCard2(
         value = "924", 
         title = "SALES", 
         stat = 12, 
         description = "Since yesterday", 
         icon = icon("users"), 
         icon_background = "yellow",
         background_color = NULL
       ),
       argonInfoCard2(
         value = "49,65%", 
         title = "PERFORMANCE", 
         stat = 34, 
         stat_icon = icon("arrow-up"),
         description = "Since last month", 
         icon = icon("percent"), 
         icon_background = "warning",
         gradient = TRUE,
         background_color = NULL
       )
     )
   )
 })
 
 
 # seeds available
 output$seeds <- renderHighchart({
   
     highchart() %>%
       hc_add_series(data = familydata$`Available Seeds`,type = "bar", name = paste("Available seeds")) %>%
       hc_xAxis(categories = familydata$FamilyID) %>%
       hc_exporting(enabled = TRUE) %>% 
       hc_tooltip(crosshairs = TRUE, backgroundColor = "#FCFFA5", valueDecimals=0,
                  shared = TRUE, borderWidth = 2) %>%
       hc_title(text="Available seeds by genotype") %>%
       hc_add_theme(hc_theme_elementary())
   
 })
 
})
)