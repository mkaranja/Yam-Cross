
source("server_files/data.R")
source("server_files/overview.R")

shinyServer(function(input, output, session) {

    env_serv = environment()
    
    overview(env_serv)
    
    data(env_serv)
    
    
})
