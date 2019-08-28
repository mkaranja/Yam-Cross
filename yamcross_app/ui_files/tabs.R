

source("ui_files/carousels.R")

homeTab <- div(
  includeCSS("www/AdminLTE.css"),
  includeScript("www/app.js"), 
  
  tags$style(".topimg {
                              margin-left:-30px;
                              margin-right:-30px;
                              margin-top:-15px;
                            }"), 
  fluidPage(
  column(8, offset = 2,
    div(style = "width:12;", # height:570px;
      carousel
      ), br(),
    
    box(width = 12, status = "primary",
      div(style = "text-align: center;",                             
          bsButton("goOverview", label = "Overview",  style = "primary", size = "large", 
                   disabled = FALSE, icon = icon("medkit", lib = "font-awesome")),                             
          bsButton("goTables", label = "Data Tables",  style = "primary", size = "large", 
                   disabled = FALSE, icon = icon("table", lib = "font-awesome")),
          bsButton("goHelp", label = "About",  style = "primary", size = "large", 
                   disabled = FALSE, icon = icon("info", lib = "font-awesome"))
      )
    ),
    tags$p(tags$span(class = "bold", "PLEASE NOTE:"), style="font-family:serif;text-align: center;",
           "This webpage may time-out if left idle too long, which will cause the screen to grey-out.",
           "To use it again, refresh the page.")
    )
  )
)

overviewTab <- div(
  
  #uiOutput("infoboxOut"),
  fluidRow(
    
    tags$style("#n_plants .small-box, #n_crosses .small-box,#n_totalseeds .small-box, #n_availableseeds .small-box, #n_seedlinggermination .small-box, #n_sproutingtubers .small-box {cursor: pointer;}"),
    
    valueBoxOutput("n_plants", width = 2),tags$style("#n_plants"),
    valueBoxOutput("n_crosses", width = 2),tags$style("#n_crosses"),
    valueBoxOutput("n_totalseeds", width = 2), tags$style("#n_totalseeds"),
    valueBoxOutput("n_availableseeds", width = 2), tags$style("#n_availableseeds"),
    valueBoxOutput("n_seedlinggermination", width = 2), tags$style("#n_seedlinggermination"),
    valueBoxOutput("n_sproutingtubers", width = 2), tags$style("#n_sproutingtubers")
  ),
  uiOutput('numberOfCrossesOut'),
  uiOutput('mostCrossedGenotypes'), br(),
  
  uiOutput('availableSeedsOut')
  
  # uiOutput("germinationOut")
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
                   tags$p(style = "font-size: 12px; color: maroon",
                          "Click Family, Female Genotype or Male Genotype to display specific details below")
               )
             ), br()
           )
          ),

  tabPanel("Details Table",
           wellPanel(
             fluidRow(
               column(1, offset = 11,
                      downloadBttn("downloadDetails", "Download", style = "fill", size="xs", no_outline = FALSE)),
               column(12,
                 div(style = 'overflow-x: scroll',
                       DT::dataTableOutput("detailsTable"))
                 )
             )
           ), uiOutput('nrows')
    )
)
  
  labelsTab <- div(
    fluidRow(
      includeCSS("www/AdminLTE.css"), # for activating shinydashboard/plus widgets
      tags$p(style = "color: black; font-size: 28px; text-align: center;","Barcode generator"),
      tags$p(style = "color: green; font-size: 18px; text-align: center;","Generate and download barcodes in a pdf file"), hr(),
      
      sidebarLayout(
        sidebarPanel(width = 3,
          fluidRow(
            selectInput("type", "Barcode Type", choices = list("Matrix (2D)" = "matrix", "Linear (1D)" = "linear"), multiple = F),
            
            fluidRow(
              column(6,
                     numericInput("font_size", "Font Size", value = 12, min = 5, max = 20, step = 1)),
              
              column(6,
                     radioButtons("across", "Print across?", choices = c(Yes = TRUE, No = FALSE), selected = TRUE, inline = T)),
              checkboxInput("trunc", "Truncate label text?", value=FALSE)
            ), br(), 
            
            box(width=12,collapsed = TRUE, collapsible = TRUE, title = 'Page Setup', status = 'info', solidHeader = T,
                fluidRow(
                  column(4,
                         numericInput("page_height", "Page height", value = 11, min = 1, max = 20, width=NULL, step = 0.5),
                         numericInput("page_width", "Page width", value = 8.5, min = 1, max = 20, width=NULL, step = 0.5)),
                  column(5,
                         numericInput("height_margin", "Page height margin", value = 0.5, min = 0, max = 20, width=NULL, step = 0.05),
                         numericInput("width_margin", "Page width margin", value = 0.25, min = 0, max = 20, width=NULL, step = 0.05)),
                  column(3,
                         numericInput("numrow", "Rows", value = 10, min = 1, max = 100, width=NULL, step = 1),
                         numericInput("numcol", "Columns", value = 1, min = 1, max = 10, width=NULL, step = 1))
                ), hr(),
                
                fluidRow(
                  
                  column(4,
                         numericInput("label_width", "Label width", value = NA, min=0, max=100),
                         numericInput("label_height", "Label height", value = NA, min=0, max=100)),
                  column(8,
                         numericInput("x_space", "Horizontal space btn barcode & text", value = 0, min = 0, max = 1),
                         numericInput("y_space", "Vertical location of text on label", value = 0.5, min = 0, max = 1)), br(),
                  column(12,
                         selectInput(inputId = "err_corr", label = "Error Correction", 
                                     choices = c("L (up to 7% damage)"="L", "M (up to 15% damage)"= "M", "Q (up to 25% damage)" = "Q", "H (up to 30% damage)" = "H"),
                                     multiple=FALSE, width = "50%"))
                )
                ),
            br(),
            
            withBusyIndicatorUI(
              actionBttn("make_pdf", "Generate", color = 'success', icon = icon('play'), size = 'sm', style = 'jelly')), hr(),
            
            column(8,
                   textInput("filename", "Enter PDF file name", value = paste0("labels", Sys.Date()), placeholder = 'type name of pdf to download')),
            column(4, br(),
                   downloadBttn('downloadpdf', 'PDF', size = 'sm', color = 'primary', style = 'unite')),
            verbatimTextOutput('txt33')
            
          )
        ),
        mainPanel(
          
          # output elements
        
          fluidRow(
              uiOutput('labels_previewOut')
            ), br(), hr(),
          fluidRow(
              uiOutput('selVarOut')
          ),
           
          fluidRow(   
            tags$p(style = "color:green; font-size: 18px; text-align: left;","Click on any cell in table below corresponding to the desired column to select field for barcode information"), br(),
            
                
                wellPanel( 
                  div(style = 'overflow-x: scroll',
                      DT::DTOutput("check_make_labels")
                  )
                )
            
          )
        )
      )
  )
  )
 aboutTab <- navlistPanel(
   id = "aboutTabs", widths = c(2,10), 
   tabPanel('This application',
            column(7,
              includeMarkdown("www/docs/datatable.md")
                )
            ),
   tabPanel(a("Using yamcross Mobile App", href = "usingyamcross.html", target="_blank", icon=icon("question", lib = "font-awesome"))),
   tabPanel(a("Code", href = 'https://github.com/mkaranja/Yam-Cross', target="_blank", icon=icon("github", lib = "font-awesome")))
 )
 
