

argonSidebar <- argonDashSidebar(
  skin = "light",  vertical = TRUE,

  background = "white",
  size = "md",
  side = "left",
  id = "my_sidebar",
  brand_url = "https://africayam.org/",
  brand_logo = "http://africayam.org/wp-content/uploads/2017/08/iitayam.png",
  
  argonSidebarHeader(title = tags$h1(style = "text-align: center;","YAMCROSS")),
  argonSidebarHeader(title = tags$p(style = "text-align: center;","Dashboard")),
  
  argonSidebarMenu(id="tabs",
    argonSidebarItem(
      tabName = "start",
      icon = icon("app"),
      "Start"
    ),
    argonSidebarItem(
      tabName = "overview",
      icon = icon("chart-bar-32"),
      "Overview"
    ),
    argonSidebarItem(
      tabName = "data",
      icon = argonIcon(name = "tv-1", color = "green"),
      "Data"
    ),
    
    argonSidebarItem(
      tabName = "about",
      icon = argonIcon(name = "bullet-list-67", color = "danger"),
      "About"
    )
  ),
  argonSidebarDivider(),
  actionLink(
    inputId = "sourcecode",size = "xs", label = "code", icon = icon("code", lib="font-awesome"),
    onclick ="window.open('http://google.com', '_blank')")
 
  #actionBttn(inputId = "sourcecode", label = "", no_outline = T, icon = icon("code", lib="font-awesome"), size="sm")
  #argonSidebarHeader(title = "Source code", src = "http://www.google.com")
)