library(DT)
data <- function(env_serv) with(env_serv, local({
  
  # summary data table
  
  output$summaryTable <- DT::renderDataTable({
   
    DT::datatable(familydata, filter = 'top', rownames = FALSE, escape = FALSE, 
                  options = list(pageLength = 5, lengthMenu = c(5, 10, 50, 100, 500,1000),
                                 searchHighlight=T, stateSave = TRUE),
                  selection=list(mode="single", target="cell")
                  )
  })
  
  output$downloadSummary <- downloadHandler(
    filename = function(){paste("Summary data -", Sys.Date(),".csv")},
    content = function(file) {
      write.csv(familydata, file, row.names = FALSE)
    }
  )
   
  # update
  # send data from R to Javascript
  # observeEvent(input$summaryTable_cell_clicked, {
  #   session$sendCustomMessage(
  #     type = "update-tabs",
  #     message = "raw"
  #   )
  # })
  
  # drilldown table
  
  drilldata <- reactive({
    id = input$summaryTable_cell_clicked$value
    if(length(id)>0 && id %in% yamdata$FamilyID){
      yamdata[yamdata$FamilyID %in% id]
    } else { 
      return(NULL)
    }
  })
  
  
  
  output$drillOut <- renderUI({
    id = input$summaryTable_cell_clicked$value
    if(!is.null(drilldata())){
      argonRow(
        argonCard(width = 12, status = "primary", shadow = TRUE, border_level = 2, hover_shadow = TRUE,
              argonRow(    
                 argonColumn(width=11, 
                        tags$p(style = "color: #5e72e4; font-size: 20px; font-weight: bold; text-align: center;",input$summaryTable_cell_clicked$value)
                        ),
                 argonColumn(width=1,
                        downloadBttn("drillDownload", "Download", style = "fill", size="xs", no_outline = FALSE)
                        ),
                  
                  div(style = 'overflow-x: scroll',
                      DT::dataTableOutput("drilldownTable")
                  )
                )
        )
      )
    }
  })
  
  
  output$drilldownTable <- DT::renderDataTable({
    
    DT::datatable(drilldata(), filter = 'top', rownames = FALSE, escape = FALSE, 
                  options = list(pageLength = 5, lengthMenu = c(5, 10, 50, 100, 500,1000),
                                 searchHighlight=T, stateSave = TRUE),
                  selection=list(mode="single", target="cell"))
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
})
)