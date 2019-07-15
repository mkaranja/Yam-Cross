

source("server_files/overview.R")
source("server_files/data.R")

shinyServer(function(input, output, session) {
    
    env_serv = environment()
    
    observeEvent(input$nav=='home', {
        shinyjs::reset('nav')
    })
    
    overview(env_serv)
    
    data(env_serv)
    
    ## Home page
    # instruction to make buttons work
    
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
})
