
library(argonR)
library(argonDash)

source("helper_funs.R")

overview <- function(env_serv) with(env_serv, local({
  
  plantsIn <- reactive({
    result = yamdata %>%
      dplyr::group_by(`Female Genotype`) %>%
      tally()
  })
  
  crossesIn <- reactive({
    result = yamdata %>%
      dplyr::group_by(`Female Genotype`, `Male Genotype`) %>%
      tally()
  })
  
  availableseedsIn <- reactive({
    familydata %>% dplyr::filter(`Available Seeds`>0)
    
  })
  
  crossesIn <- reactive({
    result = familydata %>%
      dplyr::filter(Number_of_crosses>0)
  })
  
 output$infoboxOut <- renderUI({
   
   div(
       valueBox(width = 3,
         value = sum(as.integer(na.omit(familydata$`Number of crosses`))),
         subtitle = "Crosses", 
         color = "light-blue"
       ),
       valueBox(width = 3,
         value = sum(na.omit(as.integer(availableseedsIn()$`Available Seeds`))), 
         subtitle = "Available Seeds", 
         color = "light-blue"
       ),
       valueBox(width = 3,
         value = sum(na.omit(as.integer(familydata$`Number of Seedlings Germinating`))), 
         subtitle = "Seedling germination", 
         color = "light-blue"
       ),
       valueBox(width = 3,
         value = sum(na.omit(as.integer(familydata$`Number of Sprouting Tubers`))), 
         subtitle = "Sprouting",  
         color = "light-blue"
       )
   )
 })
 
 output$n_crosses <- renderValueBox({
   
   box1<-valueBox(value=sum(as.integer(na.omit(familydata$`Number of crosses`))),
                  color = "teal",
                  href="#",
                  subtitle=HTML("<b>Crosses</b><br>", n_distinct(familydata$Family)," Unique combinations")
   )
   box1$children[[1]]$attribs$class<-"action-button"
   box1$children[[1]]$attribs$id<-"button_n_crosses"
   return(box1)
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
     geom_bar(stat = "identity", width = .6) +   # draw the bars
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