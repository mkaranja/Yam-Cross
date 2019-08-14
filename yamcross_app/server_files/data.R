
library(DT)

data <- function(env_serv) with(env_serv, local({
  
  # summary data table
  summaryIn <- reactive({
    dt = familydata
    if(!is.null(input$bar_clicked)){
      dt = dt %>%
        dplyr::filter(FamilyName %in% input$bar_clicked[1])
    }
    if(!is.null(input$button_availableseeds) && input$button_availableseeds[1]>0){
     dt = dt %>%
       dplyr::filter(`Available Seeds` > 0)
    }
    if(!is.null(input$button_seedlinggermination) && input$button_seedlinggermination[1]>0){
      dt = dt %>%
        dplyr::filter(`Number of Seedlings Germinating` > 0)
    }
    if(!is.null(input$button_sproutingtubers) && input$button_sproutingtubers[1]>0){
      dt = dt %>%
        dplyr::filter(`Number of Sprouting Tubers` > 0)
    }
    dt  %<>%
      janitor::remove_empty("cols")
  })
  
 
  output$summaryTable <- DT::renderDataTable({
   
    DT::datatable(summaryIn(), filter = 'top', rownames = FALSE, escape = FALSE, 
                  options = list(pageLength = 5, lengthMenu = c(5, 10, 50, 100, 500,1000),
                                 searchHighlight=T, stateSave = TRUE),
                  selection=list(mode="single", target="cell")
                  )
  })
  
  output$downloadSummary <- downloadHandler(
    filename = function(){paste("Summary data -", Sys.Date(),".csv")},
    content = function(file) {
      write.csv(summaryIn(), file, row.names = FALSE)
    }
  )

  output$txt1 <- renderPrint({
    input$summaryTable_cell_clicked$value
  })
  
  # details table
  observeEvent(input$summaryTable_cell_clicked$value,{
    updateTabItems(session, "dataTabs", "Details Table")
  })
  
  detailsIn <- reactive({
    dt = yamdata
    #dt[dt=='<NA>'] <- NA
    id = input$summaryTable_cell_clicked$value
    
    if(length(id)>0 && id %in% yamdata$FamilyName){
      dt = yamdata %>%
        dplyr::filter(FamilyName %in% id)
    } 
    if(length(id)>0 && id %in% yamdata$`Female Genotype`){
      dt = yamdata %>%
        dplyr::filter(`Female Genotype` %in% id)
    } 
    if(length(id)>0 && id %in% yamdata$`Male Genotype`){
      dt = yamdata %>%
        dplyr::filter(`Male Genotype` %in% id)
    } 
    if(nrow(dt)>0){
      dt %<>%
        dplyr::select(FamilyName, everything()) %>%
        janitor::remove_empty("cols")
    } else {
      dt %<>%
        janitor::remove_empty("cols")
    }
  })
  
  detailsName <- reactive({
    name = "data"
    if(length(input$summaryTable_cell_clicked$value)>0){
      name = input$summaryTable_cell_clicked$value
    }
    return(name)
  })
  
  
  
  # Details data table
  
   output$detailsTable <- DT::renderDataTable({
    
    DT::datatable(detailsIn(), filter = 'top', rownames = FALSE, escape = FALSE, 
                  options = list(pageLength = 5, lengthMenu = c(5, 10, 50, 100, 500,1000),
                                 searchHighlight=T, stateSave = TRUE))
  })
   
   output$downloadDetails <- downloadHandler(
     filename = function(){paste(detailsName(),"-", Sys.Date(),".csv")},
     content = function(file) {
       write.csv(detailsIn(), file, row.names = FALSE)
     }
   )
   
})
)