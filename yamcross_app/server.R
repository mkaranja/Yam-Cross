
source("server_files/overview.R")
source("server_files/data.R")
source("server_files/labels.R")

shinyServer(function(input, output, session) {
 # ----------------------------------------------------------------------------------- 
  # user login/ logout
  
  user <- reactive({
    session$user
  })
  
  output$userpanel <- renderUI({
    
    if (!is.null(user())) {
      span(
        paste(stringr::str_to_sentence(user()),"|"),
         a(icon("sign-out"), "Logout", href="__logout__")
        )
    }
   
  })
  
# ----------------------------------------------------------------------------------------

  ## Home page
  # instruction to make buttons work
  
  observe({
    if(input$goOverview){
      updateTabsetPanel(session, "nav", selected = "Overview")
    }
  })
  
  observe({
    if(input$goTables){
      updateTabsetPanel(session, "nav", selected = "Data Tables")
    }
  })
  
  observe({
    if(input$goHelp){
      updateTabsetPanel(session, "nav", selected = "About")
    }
  })
# -----------------------------------------------------------------------------------------  
  ## Server pages logic
  
  observeEvent(input$nav=='home', {
    shinyjs::reset('nav')
  })
  
  env_serv = environment()
  
  overview(env_serv)
  
  data(env_serv)
  
  labels(env_serv)
  
})
