

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
  
  #uiOutput("infoboxOut"),
  fluidRow(
    
    tags$style("#n_crosses .small-box, #n_availableseeds .small-box, #n_seedlinggermination .small-box, #n_sproutingtubers .small-box {cursor: pointer;}"),
    
    valueBoxOutput("n_crosses", width = 3),tags$style("#n_crosses"),
    valueBoxOutput("n_availableseeds", width = 3), tags$style("#n_availableseeds"),
    valueBoxOutput("n_seedlinggermination", width = 3), tags$style("#n_seedlinggermination"),
    valueBoxOutput("n_sproutingtubers", width = 3), tags$style("#n_sproutingtubers")
  ),
  box(width=8,  status = "primary", solidHeader = T),
  box(width=4, status = "primary", solidHeader = T,
      loadEChartsLibrary(),
      title = "Most crossed genotypes",
      tags$div(id="freq_genotypes", style="width:100%;height:476px;"),  # Specify the div for the chart. Can also be considered as a space holder
      deliverChart(div_id = "freq_genotypes")  # Deliver the plotting
      
  ),
  box(width = 4, solidHeader = T, title = "Available seeds by genotypes",
      status = "primary",
      highchartOutput("seeds")
  ),
  column(1),
  box(width = 7, solidHeader = T, title = "Seedling Germination by genotype",
      status = "primary",
      plotOutput("germination")
    )
)


dataTab <- navlistPanel(id="dataTabs", widths = c(2,9), selected = "Summary Table",
  tabPanel("Summary Table",
           
           wellPanel(
             fluidRow(
               column(1, offset = 11,
                      downloadBttn("downloadSummary", "Download", style = "fill", size="xs", no_outline = FALSE)), 
               column(12,
                   div(style = 'overflow-x: scroll',
                       DT::dataTableOutput("summaryTable")), br(),
                   tags$p(style = "font-size: 14px; color: blue","Click on any value under Family column to display specific details"),
                   verbatimTextOutput("txt1"),
                   verbatimTextOutput("txt2"),
                   verbatimTextOutput("txt3"),
                   verbatimTextOutput("txt4")
               )
             ), br()
           ),
           wellPanel(
             fluidRow(
                uiOutput("drillOut")
             ))
           ),

  tabPanel("Plant level data",
           wellPanel(
             fluidRow(
               column(1, offset = 11,
                      downloadBttn("downloadRaw", "Download", style = "fill", size="xs", no_outline = FALSE)),
               column(12,
                 div(style = 'overflow-x: scroll',
                       DT::dataTableOutput("rawTable"))
                 )
             )
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
   tabPanel(a("Code on github", href = 'https://github.com/mkaranja/Yam-Cross', target="_blank", icon=icon("github")))
 )
 
# footer <- bulmaFooter(
#   tags$ul(a(href = 'https://africayam.org/',
#             img(src = 'africayam.png',
#                 title = "", height = "50px"),
#             style = "padding-top:5px; padding-bottom:5px;"),
#           
#           a(href = 'https://iita.org/',
#             img(src = 'iita.png',
#                 title = "", height = "50px"),
#             style = "padding-top:5px; padding-bottom:5px;"),
#           
#           a(href = 'https://btiscience.org/',
#             img(src = 'bti.png',
#                 title = "", height = "50px"),
#             style = "padding-top:5px; padding-bottom:5px;"),
#           class = "dropdown", style="center")
# )