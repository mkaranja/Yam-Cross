
library(shinydashboard)
library(shinybulma)

# template
source("ui_files/sidebar.R")
source("ui_files/header.R")
source("ui_files/footer.R")


# elements
source("ui_files/tabs.R")

shinyUI(
    argonDashPage(
        title = "yamcross",
        description = "Yam crosses management",
        sidebar = argonSidebar,
        body = argonDashBody(
            
            argonTabItems(
                startTab,
                overviewTab,
                dataTab,
                aboutTab
            )
            
        ),
        footer = "IITA"
    )
)