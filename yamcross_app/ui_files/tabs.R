library(shinydashboardPlus)

startTab <- argonTabItem(
  tabName = "start",
  argonRow(
      argonCarousel(id = "carousel",
        floating = TRUE, width = 12, hover_lift = TRUE,
        
        argonCarouselItem(
          active = TRUE,
          src = "images/1.jpg",
          mode = "img"
        ),
        argonCarouselItem(
          active = FALSE,
          src = "images/2.jpg",
          mode = "img"
        ),
        argonCarouselItem(
          active = FALSE,
          src = "images/3.jpg",
          mode = "img"
        ),
        argonCarouselItem(
          active = FALSE,
          src = "images/4.jpg",
          mode = "img"
        ),
        argonCarouselItem(
          active = FALSE,
          src = "images/5.jpg",
          mode = "img"
        )
      )
    ),
  argonRow(
    argonCard(
      p("The yamcross is an automated data management system that integrates yambase with mobile app. 
        This dashboard aggregates datasets from diferent locations for querrying and analytics purposes. 
        It is built using R and Shiny. The code is available on github.")
    )
  )
)
overviewTab <- argonTabItem(
  tabName = "overview",
  
  uiOutput("infoboxOut"),
  argonRow(
    argonCard(width = 6,
              highchartOutput("seeds")
              )
    
  )
)

aboutTab <- argonTabItem(
  tabName = "about",
  argonRow(
    argonCard(width = 8, icon = icon("cogs"), status = "success", shadow = TRUE, border_level = 2, hover_shadow = TRUE,
              title = "About yamcross",
              includeMarkdown("www/about.md")
              
    )
  )
)

summaryTab <- argonTab(
    tabName = "Summary Data",active = TRUE,
    argonRow(
      argonCard(width = 12, icon = icon("cogs"), status = "success", shadow = TRUE, border_level = 2, hover_shadow = TRUE,
                argonRow(
                   argonColumn(width=4,
                       selectizeInput("group_by", "Group by:", c(names(familydata)[1:3]))
                       ),
                   argonColumn(width=7),
                   argonColumn(width=1,
                       downloadBttn("downloadSummary", "Download", style = "fill", size="sm", no_outline = FALSE)), # stretch
                    
                   div(style = 'overflow-x: scroll',
                           DT::dataTableOutput("summaryTable")
                   )
                )
        )
      ),
      uiOutput("drillOut")
)

rawTab <- argonTab(
 tabName = "Raw",
 argonRow(
   argonCard(width = 12, icon = icon("cogs"), status = "success", shadow = TRUE, border_level = 2, hover_shadow = TRUE,
       div(style = 'overflow-x: scroll',
           DT::dataTableOutput("rawTable")
       )
   )
 )
)
 
dataTab <- argonTabItem(
  tabName = "data",
  
  argonRow(
    
    # Horizontal Tabset
    argonColumn(
      width = 12,
      # argonH1("Horizontal Tabset", display = 4),
      argonTabSet(id = "dTabs", card_wrapper = TRUE, horizontal = TRUE, circle = FALSE, size = "sm", width = 12,
       # iconList = lapply(X = 1:3, FUN = argonIcon, name = "atom"),
        summaryTab,
        rawTab
      )
    )
  )
)

