
library(DT)

data <- function(env_serv) with(env_serv, local({
  
  # summary data table
  summaryIn <- reactive({
    dt = familydata
    if(!is.null(input$bar_clicked)){
      dt = dt %>%
        dplyr::filter(Family %in% input$bar_clicked[1])
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
    dt
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
  
  drilldata <- reactive({
    dt = yamdata
    id = input$summaryTable_cell_clicked$value
    
    if(length(id)>0 && id %in% yamdata$Family){
      dt = yamdata %>%
        dplyr::filter(Family %in% id)
    } 
    dt %<>%
      dplyr::select(Family, everything())
  })
  
  
  drillName <- reactive({
    name = "data"
    if(length(input$summaryTable_cell_clicked$value)>0){
      name = input$summaryTable_cell_clicked$value
    }
    return(name)
  })
  
  output$drillOut <- renderUI({
    id = input$summaryTable_cell_clicked$value
    if(length(id)>0 && id %in% yamdata$Family){
      div(
      column(1, offset = 11,
             downloadBttn("drillDownload", "Download", style = "fill", size="xs", no_outline = FALSE)), 
      column(width = 12, tags$p(style = "color: #8D0610; font-size: 18px; font-weight: bold; text-align: center;",input$summaryTable_cell_clicked$value),
          div(style = 'overflow-x: scroll',
              DT::dataTableOutput("drilldownTable"))
        )
      )
    }
  })
  
  output$drilldownTable <- DT::renderDataTable({
    
    DT::datatable(drilldata(), filter = 'top', rownames = FALSE, escape = FALSE, 
                  options = list(pageLength = 5, lengthMenu = c(5, 10, 50, 100, 500,1000),
                                 searchHighlight=T, stateSave = TRUE))
  })
  
  
  output$drillDownload <- downloadHandler(
    filename = function(){paste(input$summaryTable_cell_clicked$value,"_",Sys.Date(),".csv")},
    content = function(file) {
      write.csv(drilldata(), file, row.names = FALSE)
    }
  )
  
  
  # all data table
  
  
   output$rawTable <- DT::renderDataTable({
    
    DT::datatable(yamdata, filter = 'top', rownames = FALSE, escape = FALSE, 
                  options = list(pageLength = 5, lengthMenu = c(5, 10, 50, 100, 500,1000),
                                 searchHighlight=T, stateSave = TRUE))
  })
   
   output$downloadRaw <- downloadHandler(
     filename = function(){paste(drillName(),"-", Sys.Date(),".csv")},
     content = function(file) {
       write.csv(dt(), file, row.names = FALSE)
     }
   )
})
)