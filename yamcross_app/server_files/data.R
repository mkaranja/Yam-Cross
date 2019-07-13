
library(DT)

data <- function(env_serv) with(env_serv, local({
  
  # summary data table
  summaryIn <- reactive({
    dt = familydata
    if(!is.null(input$bar_clicked)){
      dt = familydata %>%
        dplyr::filter(Family %in% input$bar_clicked[1])
    }
    return(dt)
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

  # drilldown table
  
  observeEvent(input$summaryTable_cell_clicked, {
    updateNavlistPanel(session, "dataTabs",
                      selected = "Plant level data")
  })
  
  
  drilldata <- reactive({
    dt = yamdata
    id = input$summaryTable_cell_clicked$value
    if(length(id)>0 && id %in% yamdata$Family){
    dt = yamdata %>%
      dplyr::filter(Family %in% id)
    } 
    dt
  })
  

  drillName <- reactive({
    name = "data"
    if(length(input$summaryTable_cell_clicked$value)>0){
      name = input$summaryTable_cell_clicked$value
    }
    return(name)
  })
  
  
  output$txt <- renderPrint({
    input$summaryTable_cell_clicked$value
  })
  # all data table
  
   output$rawTable <- DT::renderDataTable({
    
    DT::datatable(drilldata(), filter = 'top', rownames = FALSE, escape = FALSE, 
                  options = list(pageLength = 5, lengthMenu = c(5, 10, 50, 100, 500,1000),
                                 searchHighlight=T, stateSave = TRUE))
  })
   
   output$downloadRaw <- downloadHandler(
     filename = function(){paste(drillName(),"-", Sys.Date(),".csv")},
     content = function(file) {
       write.csv(drilldata(), file, row.names = FALSE)
     }
   )
})
)