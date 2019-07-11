
library(argonR)
library(argonDash)

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
    result = yamdt %>%
      dplyr::filter(Number_of_crosses>0)
  })
  
 

 output$infoboxOut <- renderUI({
   
   div(
       valueBox(width = 3,
         value = sum(yamdt$Number_of_crosses),
         subtitle = "Crosses", 
         color = "light-blue"
       ),
       valueBox(width = 3,
         value = sum(na.omit(availableseedsIn()$`Available Seeds`)), 
         subtitle = "Available Seeds", 
         color = "light-blue"
       ),
       valueBox(width = 3,
         value = 0, 
         subtitle = "Seedling germination", 
         color = "light-blue"
       ),
       valueBox(width = 3,
         value = 0, 
         subtitle = "Sprouting",  
         color = "light-blue"
       )
   )
 })
 
 
 # seeds available
 
 seedsIn <- familydata %>%
     dplyr::filter(`Available Seeds`>0)
 
 
 js_bar_clicked <- JS("function(event) {Shiny.onInputChange('bar_clicked', [event.point.category]);}")
 
 output$seeds <- renderHighchart({
   
     highchart() %>%
       hc_add_series(data = familydata$`Available Seeds`,type = "bar", name = paste("Number of seeds"), events = list(click = js_bar_clicked)) %>%
       hc_xAxis(categories = familydata$FamilyID) %>%
       hc_exporting(enabled = TRUE) %>% 
       hc_tooltip(crosshairs = TRUE, backgroundColor = "#FCFFA5", valueDecimals=0,
                  shared = TRUE, borderWidth = 2) %>%
       hc_title(text="Number of seeds available by genotype") %>%
       hc_add_theme(hc_theme_elementary())
   
 })
 

 # on family click, go to 'Data' tab
 observeEvent(input$bar_clicked, {
   updateTabsetPanel(session, "nav",
                     selected = "Data Tables")
 })
 
 
})
)