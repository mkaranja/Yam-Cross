

source("ui_files/carousels.R")

homeTab <- div(
  includeCSS("www/AdminLTE.css"),
  includeScript("www/app.js"), 
  
  tags$style(".topimg {
                              margin-left:-30px;
                              margin-right:-30px;
                              margin-top:-15px;
                            }"), 
  #div(class="topimg", img(src="images/yam.png", width="100%")),
  column(8, offset = 2,
    div(style = "width:12; height:550px;",
      carousel
      ), br(),br(),
    
    box(width = 12,
      div(style = "text-align: center;",                             
          bsButton("goOverview", label = "Overview",  style = "primary", size = "large", 
                   disabled = FALSE, icon = icon("medkit", lib = "font-awesome")),                             
          bsButton("goTables", label = "Data Tables",  style = "primary", size = "large", 
                   disabled = FALSE, icon = icon("table", lib = "font-awesome")),
          bsButton("goHelp", label = "About",  style = "primary", size = "large", 
                   disabled = FALSE, icon = icon("question", lib = "font-awesome"))
      )
    ),
    tags$p(tags$span(class = "bold", "PLEASE NOTE:"), style="font-family:serif;",
           "This webpage may time-out if left idle too long, which will cause the screen to grey-out.",
           "To use the webpage again, refresh the page. This will reset all previously-selected input options.")
  )
)

overviewTab <- div(
  
  uiOutput("infoboxOut"),
  box(width = 6, title = "Number of crosses",
      highchartOutput("number_crosses")
    ),
  box(width = 6, title = "Available seeds",
      highchartOutput("seeds")
    )
)


dataTab <- navlistPanel(id="dataTabs", widths = c(2,9), #selected = "Summary Table",
  tabPanel("Summary Table",
           column(1, offset = 11,
                  downloadBttn("downloadSummary", "Download", style = "fill", size="sm", no_outline = FALSE)), 
           box(width = 12,
             div(style = 'overflow-x: scroll',
                 DT::dataTableOutput("summaryTable"))
            ), br(), br(),br(), # br(),br(), br(),
           
            uiOutput("drillOut")
                
           ),
  tabPanel("Plant level data",
           column(1, offset = 11,
                  downloadBttn("downloadRaw", "Download", style = "fill", size="sm", no_outline = FALSE)),
           box(width = 12,
             div(style = 'overflow-x: scroll',
                 DT::dataTableOutput("rawTable")),
             verbatimTextOutput("txt")
             )
  )
  
)
  

  
 aboutTab <- navlistPanel(
   id = "aboutTabs", widths = c(2,10),
   tabPanel("This app",
            column(7,
                   wellPanel(
                     includeMarkdown("www/about.md")
                   )
              )
            ),
   tabPanel(a("using yamcross", href = "tutorial.html", target="_blank", icon=icon("note"))),
   tabPanel(a("source code", href = 'https://github.com/mkaranja/Yam-Cross', target="_blank", icon=icon("github")))
 )
 
