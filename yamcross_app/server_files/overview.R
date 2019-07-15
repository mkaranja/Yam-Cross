
library(argonR)
library(argonDash)

source("helper_funs.R")

overview <- function(env_serv) with(env_serv, local({
  
  plantsIn <- reactive({
    result = yamdata %>%
      dplyr::group_by(`Female Genotype`) %>%
      tally()
  })
  
 output$n_crosses <- renderValueBox({
   
   box1<-valueBox(value=sum(as.integer(na.omit(familydata$`Number of crosses`))),
                  color = "teal",
                  href="#",
                  subtitle=HTML("<b>Crosses</b><br>", n_distinct(familydata$Family)," Genotypes")
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
                   subtitle=HTML("<b>Available seeds</b><br>", n_distinct(n$Family)," Genotypes")
    )
    box1$children[[1]]$attribs$class<-"action-button"
    box1$children[[1]]$attribs$id<-"button_availableseeds"
    return(box1)
 })
 
 observeEvent(input$button_availableseeds, {
   updateTabsetPanel(session, "nav",
                     selected = "Data Tables")
 })
 #---------------------------------------------------------------------------------------------------------------------
 output$n_seedlinggermination <- renderValueBox({
    n = familydata %>%
       dplyr::filter(`Number of Seedlings Germinating`>0)
    box1<-valueBox(value=sum(as.integer(na.omit(familydata$`Number of Seedlings Germinating`))),
                   color = "teal",
                   href="#",
                   subtitle=HTML("<b>Number of seedlings germinating</b><br>", n_distinct(n$Family)," Genotypes")
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
    box1<-valueBox(value=sum(as.integer(na.omit(familydata$`Number of Sprouting Tubers`))),
                   color = "teal",
                   href="#",
                   subtitle=HTML("<b>Number of tubers sprouting</b><br>", n_distinct(n$Family)," Genotypes")
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
 
 # Radar Chart
 renderWordcloud("freq_genotypes", data = genotypesIn(),
                 grid_size = 10, sizeRange = c(10, 40))
 
 # seeds available
 
 seedsIn <- familydata %>%
     dplyr::filter(`Available Seeds`>0)
 
 
 js_bar_clicked <- JS("function(event) {Shiny.onInputChange('bar_clicked', [event.point.category]);}")
 
 output$seeds <- renderHighchart({
   
     highchart() %>%
       hc_add_series(data = familydata$`Available Seeds`,type = "bar", name = paste("Number of seeds"), events = list(click = js_bar_clicked)) %>%
       hc_xAxis(categories = familydata$Family) %>%
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
 germinationIn <- familydata %>%
   dplyr::select("Family", "Number yet to Germinate", "Number of Seedlings Germinating") %>% #,"Number yet to Germinate","Germination Rate")]
   gather(category, 'Number of seeds', contains("Number"), na.rm=T)
 
 
 output$germination <- renderPlot({
   ggplot(germinationIn, aes(x = Family, y = `Number of seeds`, fill = category)) +   # Fill column
       # geom_bar(subset = .(category == "Number yet to Germinate"), stat = "identity") + 
       # geom_bar(subset = .(category == "Number of Seedlings Germinating"), stat = "identity") + 
      geom_bar(stat = "identity", width = .6) +   # draw the bars
       scale_y_continuous(breaks = seq(-500, 500, 50), 
                          labels = paste0(as.character(c(seq(50,0,-5), seq(5,50,5))), "0")) + 
     coord_flip() +  # Flip axes
     labs(title="Seedling Germination", xaxis="") +
     theme_tufte() +  # Tufte theme from ggfortify
     theme(plot.title = element_text(hjust = .5), 
           axis.ticks = element_blank(),
           axis.title.x = element_blank()
           ) +   # Centre plot title
     #scale_fill_brewer(palette = "Dark2")  # Color palette
     scale_fill_brewer(direction = -1)  #theme_dark()
 })
 
})
)