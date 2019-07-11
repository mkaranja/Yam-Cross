
library(shinybulma)

source("ui_files/tabs.R")

# Begin shinyUI -----------------------------------------------------------
# _________________________________________________________________________
tagList(
    tags$noscript(
        style = "color: orange; font-size: 40px; text-align: center;",
        "Please enable JavaScript"
    ), 
    shinyjs::useShinyjs(),
    #includeCSS("css/ShinyStan.css"),
    
    navbarPage(
        id = "nav",
        position = "fixed-top",
        collapsible = TRUE,
        theme = shinythemes::shinytheme("flatly"),
        windowTitle = "yamcross",
        img(src = "africayam.png", height = "35px", width = "35px"),
        
        
        #### HOME ####
        tabPanel(
             title = strong(style = "color: orange; font-size:16;", "Yam Cross"), ##B2011D
             value = "home",
             icon = icon("home"),
             br(),br(),br(),#br(),br(),br(),
             
             homeTab
        ),
        
        #### OVERVIEW ####
        tabPanel(
            title = "Overview",
            icon = icon("medkit", lib = "font-awesome"),
            br(),br(), br(),br(),#br(),br(),
            shinyjs::useShinyjs(), 
            overviewTab
        ),
        
        #### DATA TABLES ####
        tabPanel(
            title = "Data Tables",
            icon = icon("table", lib = "font-awesome"),
            br(),br(),br(),br(),#br(),br(),
                
                dataTab
            ),
        
        #### ABOUT ####
        tabPanel(
            title = "About",
            icon = icon("question", lib = "font-awesome"),
            br(),br(),br(),br(),#br(),br(),
            
            aboutTab
        )
    ) # End navbarPage
) # End tagList

# End shinyUI -------------------------------------------------------------
# -------------------------------------------------------------------------
