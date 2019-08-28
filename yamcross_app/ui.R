
source("ui_files/tabs.R")
# Begin shinyUI -----------------------------------------------------------
# _________________________________________________________________________


jsResetCode <- "shinyjs.reset2 = function() {history.go(0)}" # Define the js method that resets the page

shinyUI(
        
    fluidPage(  
        list(
            tags$head(
                HTML('<link rel="icon" href="yamcross.png" # add icon on the windowTitle 
                type="image/png" />'))
            
             ),
        # Custom CSS to hide the default logout panel
        tags$head(tags$style(HTML('.shiny-server-account { display: none; }'))),
        
        shinyjs::useShinyjs(),
        #includeCSS("css/ShinyStan.css"),
        
        navbarPage(id = "nav",position = "fixed-top",collapsible = TRUE, theme = shinythemes::shinytheme("flatly"), windowTitle = "yamcross",
            img(src = "images/africayam.png", height = "35px", width = "35px"),
            
            #### HOME ####
            tabPanel(
                title = strong(style = "color: orange;text-highlight:yellow; font-size:16;", "Yam Cross"), ##B2011D
                value = "home",icon = icon("home"),br(),br(),br(),
                
                homeTab
            ),
            
            #### OVERVIEW ####
            tabPanel(
                title = "Overview", icon = icon("medkit", lib = "font-awesome"), br(),br(), br(),br(),
                shinyjs::useShinyjs(), 
                
                overviewTab
            ),
            
            #### DATA TABLES ####
            tabPanel(
                    title = "Data Tables", icon = icon("table", lib = "font-awesome"), br(),br(),br(),br(),
                    
                    dataTab
                ),
            
            # Labels
            tabPanel(
                title = "Barcodes", icon = icon("qrcode", lib = "font-awesome"), br(),br(),br(),
                
                labelsTab
            ),
            
            #### ABOUT ####
            navbarMenu("About", 
                    icon = icon("question", lib = "font-awesome"), #br(),br(),br(),br(),
                    #aboutTab
                     tabPanel(a("using yamcross", href = "usingyamcross.html", target="_blank", icon=icon("question", lib = "font-awesome"))),
                     tabPanel(a("Code on github", href = 'https://github.com/mkaranja/Yam-Cross', target="_blank", icon=icon("github", lib = "font-awesome")))
                    
                 
             )
        ), # End navbarPage
        # user logout panel
        HTML(paste("<script>var parent = document.getElementsByClassName('navbar-nav');
           parent[0].insertAdjacentHTML( 'afterend', '<ul class=\"nav navbar-nav navbar-right\"><li class=\"disabled\"><a href=\"#\"><strong>",
                   uiOutput("out_id"),"</strong></a></li><li class=\"disabled\"><a href=\"#\"><strong>",uiOutput('userpanel'),"</strong></a></ul>' );</script>"))
        
    ) # End tagList

)# End shinyUI -------------------------------------------------------------
# -------------------------------------------------------------------------
