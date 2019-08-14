
#source("helper_funs.R")

overview <- function(env_serv) with(env_serv, local({
  
  
  output$n_plants <- renderValueBox({
    
    box1<-valueBox(value=n_distinct(yamdata$PlantName),
                   color = "teal",
                   href="#",
                   subtitle=HTML("<b>Number of Plants</b><br>", n_distinct(yamdata$`Female Genotype`)," Genotypes")
    )
    box1$children[[1]]$attribs$class<-"action-button"
    box1$children[[1]]$attribs$id<-"button_plants"
    return(box1)
  })
  
  
  observeEvent(input$button_crosses, {
    updateTabsetPanel(session, "nav",
                      selected = "Data Tables")
  })
  
  output$n_crosses <- renderValueBox({
    n = yamdata %>%
      dplyr::filter(FamilyName!='')
    box1<-valueBox(value=n_distinct(na.omit(yamdata$CrossNumber)),
                   color = "teal",
                   href="#",
                   subtitle=HTML("<b>Crosses</b><br>", n_distinct(na.omit(n$FamilyName)!="")," Genotypes")
    )
    box1$children[[1]]$attribs$class<-"action-button"
    box1$children[[1]]$attribs$id<-"button_crosses"
    return(box1)
  })
  
  
  observeEvent(input$button_crosses, {
    updateTabsetPanel(session, "nav",
                      selected = "Data Tables")
  })
  
  
  #----------------------------------------------------------------------------------------------------------------
  availableseedsIn <- reactive({
    familydata %>% dplyr::filter(`Available Seeds`>0)
    
  })
  output$n_availableseeds <- renderValueBox({
    n = familydata %>%
      dplyr::filter(`Available Seeds`>0)
    box1<-valueBox(value=sum(as.integer(na.omit(familydata$`Available Seeds`))),
                   color = "teal",
                   href="#",
                   subtitle=HTML("<b>Available seeds</b><br>", n_distinct(n$FamilyName)," Genotypes")
    )
    box1$children[[1]]$attribs$class<-"action-button"
    box1$children[[1]]$attribs$id<-"button_availableseeds"
    return(box1)
  })
  
  observeEvent(input$button_availableseeds, {
    updateTabsetPanel(session, "nav",
                      selected = "Data Tables")
  })
  #----------------------------------------------------------------------------------------------------------------
  
  output$n_totalseeds <- renderValueBox({
    n = yamdata %>%
      dplyr::filter(`Total Seeds Extracted`>0)
    box1<-valueBox(value=sum(na.omit(as.integer(yamdata$`Total Seeds Extracted`))),
                   color = "teal",
                   href="#",
                   subtitle=HTML("<b>Total seeds</b><br>", n_distinct(n$FamilyName)," Genotypes")
    )
    box1$children[[1]]$attribs$class<-"action-button"
    box1$children[[1]]$attribs$id<-"button_availableseeds"
    return(box1)
  })
  
  observeEvent(input$button_totalseeds, {
    updateTabsetPanel(session, "nav",
                      selected = "Data Tables")
  })
  #---------------------------------------------------------------------------------------------------------------------
  output$n_seedlinggermination <- renderValueBox({
    n = familydata %>%
      dplyr::filter(`Number of Seedlings Germinating`>0)
    box1<-valueBox(value=sum(na.omit(as.integer(familydata$`Number of Seedlings Germinating`))),
                   color = "teal",
                   href="#",
                   subtitle=HTML("<b>Seedlings germinating</b><br>", n_distinct(n$FamilyName)," Genotypes")
    )
    box1$children[[1]]$attribs$class<-"action-button"
    box1$children[[1]]$attribs$id<-"button_seedlinggermination"
    return(box1)
  })
  
  observeEvent(input$button_seedlinggermination, {
    updateTabsetPanel(session, "nav",
                      selected = "Data Tables")
  })
  
  # ----------------------------------------------------------------------------------------------------------------------
  output$n_sproutingtubers <- renderValueBox({
    n = familydata %>%
      dplyr::filter(`Number of Sprouting Tubers`>0)
    box1<-valueBox(value=sum(na.omit(as.integer(familydata$`Number of Sprouting Tubers`))),
                   color = "teal",
                   href="#",
                   subtitle=HTML("<b>Tubers sprouting</b><br>", n_distinct(n$FamilyName)," Genotypes")
    )
    box1$children[[1]]$attribs$class<-"action-button"
    box1$children[[1]]$attribs$id<-"button_sproutingtubers"
    return(box1)
  })
  
  observeEvent(input$button_sproutingtubers, {
    updateTabsetPanel(session, "nav",
                      selected = "Data Tables")
  })
  
  #-------------------------------------------------------------------------------------------------------------------------
  
  # Number of crosses
  
  allcrossesIn <- yamdata %>%
    dplyr::select(CrossNumber, FamilyName,`Pollination Date`) %>%
    dplyr::mutate(day = lubridate::day(`Pollination Date`),
                  month = lubridate::month(`Pollination Date`),
                  year = lubridate::year(`Pollination Date`)) %>%
    .[complete.cases(.),] %>%
    dplyr::group_by(`Pollination Date`) %>% 
    dplyr::tally()  %>%
    collect() %>%
    dplyr::rename(`Number of crosses` = n)
  
  output$numberOfCrossesOut <- renderUI({
    if(nrow(allcrossesIn) > 0){
      div(
        box(width=8,  status = "primary", solidHeader = T,
            highchartOutput("allcrosses", height = 520) %>% withSpinner(color="#0dc5c1")
        )
      )
    }
  })
  
  output$allcrosses <- renderHighchart({
    
    highchart() %>%
      hc_add_series(data = allcrossesIn$`Number of crosses`,type = "column") %>%
      hc_xAxis(categories = allcrossesIn$`Pollination Date`) %>%
      hc_exporting(enabled = TRUE) %>% 
      hc_tooltip(crosshairs = TRUE, backgroundColor = "#FCFFC5", valueDecimals=0,
                 shared = TRUE, borderWidth = 2) %>%
      hc_title(text='Number of crosses') %>%
      hc_add_theme(hc_theme_elementary())
    
  })
  
  # Most Used Genotypes
  
  genotypesIn <- reactive({
    
    result = yamdata %>%
      dplyr::filter(CrossNumber!='') %>%
      dplyr::select(contains("Genotype")) %>%
      tidyr::gather(id, name, contains("Genotype"), na.rm=T) %>%
      dplyr::group_by(name) %>%
      tally() 
    result = result %>%
      dplyr::rename(value=n) %>%
      .[complete.cases(.),]
    result
  })
  output$mostCrossedGenotypes <- renderUI({
    if(nrow(genotypesIn())>0){
      div(
        box(width=4, status = "primary", solidHeader = T,
            
            loadEChartsLibrary(),
            title = "Most crossed genotypes",
            tags$div(id="freq_genotypes", style="width:100%;height:476px;"),  # Specify the div for the chart. Can also be considered as a space holder
            deliverChart(div_id = "freq_genotypes")  # Deliver the plotting
        )
      )
    }
  })
  
  # Radar Chart
  renderWordcloud("freq_genotypes", data = genotypesIn(),
                  grid_size = 10, sizeRange = c(10, 40))
  
  # seeds available
  
  seedsIn <- familydata %>%
    dplyr::filter(`Available Seeds`>0)
  
  output$availableSeedsOut <- renderUI({
    if(nrow(seedsIn)>0){
      div(
        box(width = 4, solidHeader = T, title = "Available seeds by genotypes",
            status = "primary",
            highchartOutput("seeds")
        )
      )
    }
  })
  js_bar_clicked <- JS("function(event) {Shiny.onInputChange('bar_clicked', [event.point.category]);}")
  
  output$seeds <- renderHighchart({
    
    highchart() %>%
      hc_add_series(data = familydata$`Available Seeds`,type = "bar", name = paste("Number of seeds"), events = list(click = js_bar_clicked)) %>%
      hc_xAxis(categories = familydata$FamilyName) %>%
      hc_exporting(enabled = TRUE) %>% 
      hc_tooltip(crosshairs = TRUE, backgroundColor = "#FCFFA5", valueDecimals=0,
                 shared = TRUE, borderWidth = 2) %>%
      hc_title(text="Number of seeds available by genotype") %>%
      hc_add_theme(hc_theme_elementary())
    
  })
  
  
  # on family click, go to 'Data' tab
  observeEvent(input$bar_clicked, {
    updateTabsetPanel(session, "nav",
                      selected = "Data Tables")
  })
  
  
  # germination
  # germinationIn <- familydata %>%
  #   dplyr::select("FamilyName", "Number yet to Germinate", "Number of Seedlings Germinating") %>% #,"Number yet to Germinate","Germination Rate")]
  #   gather(category, 'Number of seeds', contains("Number"), na.rm=T)
  # 
  # output$germinationOut <- renderUI({
  #   if(nrow(germinationIn)>0){
  #   div(
  #     box(width = 7, solidHeader = T, title = "Seedling Germination by genotype",
  #         status = "primary",
  #         plotOutput("germination")
  #     )
  #   )
  #   }
  # })
  # 
  # output$germination <- renderPlot({
  #   ggplot(germinationIn, aes(x = FamilyName, y = `Number of seeds`, fill = category)) +  #Fill column
  #       # geom_bar(subset = .(category == "Number yet to Germinate"), stat = "identity") + 
  #       # geom_bar(subset = .(category == "Number of Seedlings Germinating"), stat = "identity") + 
  #      geom_bar(stat = "identity", width = .6) +   # draw the bars
  #       scale_y_continuous(breaks = seq(-500, 500, 50), 
  #                          labels = paste0(as.character(c(seq(50,0,-5), seq(5,50,5))), "0")) + 
  #     coord_flip() +  # Flip axes
  #     labs(title="Seedling Germination", xaxis="") +
  #     theme_tufte() +  # Tufte theme from ggfortify
  #     theme(plot.title = element_text(hjust = .5), 
  #           axis.ticks = element_blank(),
  #           axis.title.x = element_blank()
  #           ) +   # Centre plot title
  #     #scale_fill_brewer(palette = "Dark2")  # Color palette
  #     scale_fill_brewer(direction = -1)  #theme_dark()
  # })
  
})
)