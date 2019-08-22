# label file
Labels_pdf<-yamdata[, c("PlantName","Bagging Date", "BagCode", "Day","CrossNumber","Pollination Date")]
bagDates = Labels_pdf$`Bagging Date`
pollinationDates = Labels_pdf$`Pollination Date`


labels <- function(env_serv) with(env_serv, local({
  
  # select variable
  output$selVarOut <- renderUI({
    div(
      column(3,
          selectizeInput('variable', 'Select variable to barcode', c('BagCode', 'CrossNumber'), selected = 'BagCode', width='90%')),
      column(3,
             conditionalPanel("input.variable=='BagCode'",
                              dateInput('bagDate', 'Select Bagging Date', value = max(na.omit(bagDates)), min = max(na.omit(bagDates)), max = max(na.omit(bagDates)))
                              ),
             conditionalPanel("input.variable=='CrossNumber'",
                              dateInput('pollinationDate', 'Select Pollination Date', value = max(na.omit(pollinationDates)), min = max(na.omit(pollinationDates)), max =max(na.omit(pollinationDates)))
                              )
             )
          
    )
  })
 
  # data filtered
  
  dataInput <- reactive({
    req(input$variable)
    
    dt = Labels_pdf
    
    if(input$variable=='BagCode'){
      dt %<>% dplyr::filter(!is.na(BagCode), `Bagging Date` == input$bagDate)
    } else 
      if(input$variable=='CrossNumber'){
        dt %<>% dplyr::filter(!is.na(CrossNumber), `Pollination Date` == input$pollinationDate)
      }
    
    dt = janitor::remove_empty(dt, 'cols')
    dt
  })
  
  
  # Preview labels dimensions
  
  hght <- reactive({
    req(input$page_height); req(input$height_margin); req(input$numrow);
    height = 72 * ((input$page_height - 2 * input$height_margin)/input$numrow)
    paste0(height,'px') 
  })
  
  wdth <- reactive({
    req(input$page_width); req(input$width_margin); req(input$numcol);
    width = 72 * ((input$page_width - 2 * input$width_margin)/input$numcol)
    paste0(width,'px')
  })
  
  # plot preview 
  
  observeEvent(input$make_pdf,{
    output$labels_previewOut <- renderUI({
      div(
        column(6, offset = 3,
          box(width=12, height = hght(), status = 'warning', solidHeader = T,
            plotOutput("label_preview", height = hght(), width = wdth())
            ), br(),br(),br(), hr(),
          column(4, offset=1, paste("Label Height: ", hght())),
          column(4,paste("Label Width: ", wdth()))
          ),
        column(6)
        )
      
    })
  })
  # preview label file
  
  varPos <- reactive({
    if(input$variable=='BagCode'){
      pos = 3
    } else 
      if(input$variable=='CrossNumber'){
        pos = 5
      }
    pos
  })
  
  # data table
  
  output$check_make_labels<-DT::renderDataTable(
    dataInput(), server = FALSE, selection = list(mode = "single", target = "column", selected = varPos())
  )
  
  
 
  # preview barcode
  
  observeEvent(input$make_pdf,{
    output$label_preview <- shiny::renderImage({
      req(input$type); req(input$err_corr);
      if(input$type == "matrix") {
        code_vp <- grid::viewport(x=grid::unit(0.05, "npc"), y=grid::unit(0.8, "npc"), width = grid::unit(0.3 * (input$page_width - 2 * input$width_margin)/input$numcol, "in"), height = grid::unit(0.6 * (input$page_height - 2 * input$height_margin)/input$numrow, "in"), just=c("left", "top"))
        label_vp <- grid::viewport(x=grid::unit((0.4 + 0.6 * input$x_space)* (input$page_width - 2 * input$width_margin)/input$numcol, "in"), y=grid::unit(input$y_space, "npc"), width = grid::unit(0.4, "npc"), height = grid::unit(0.8, "npc"), just=c("left", "center"))
        label_plot <- qrcode_make(Labels = dataInput()[1, input$check_make_labels_columns_selected], ErrCorr = input$err_corr)
      } else 
        if(input$type == "linear"){
          code_vp <- grid::viewport(x=grid::unit(0.05, "npc"), y=grid::unit(0.8, "npc"), width = grid::unit(0.9 * (input$page_width - 2 * input$width_margin)/input$numcol, "in"), height = grid::unit(0.8 * (input$page_height - 2 * input$height_margin)/input$numrow, "in"), just=c("left", "top"))
          # text_height <- ifelse(input$Fsz / 72 > (input$page_height - 2 * input$height_margin)/input$numrow * 0.3, (input$page_height - 2 * input$height_margin)/input$numrow * 0.3, input$Fsz/72)
          label_vp <- grid::viewport(x=grid::unit(0.5, "npc"), y = grid::unit(1, "npc"), width = grid::unit(1, "npc"), height = grid::unit((input$page_height - 2 * input$height_margin)/input$numrow * 0.3, "in"), just = c("centre", "top"))
          label_plot <- code_128_make(Labels = dataInput()[1, input$check_make_labels_columns_selected])
        }
      outputfile <- tempfile(fileext=".png")
      grDevices::png(outputfile, width = (input$page_width - 2 * input$width_margin)/input$numcol, (input$page_height - 2 * input$height_margin)/input$numrow, units = "in", res=100)
      # grid::grid.rect()
      grid::pushViewport(code_vp)
      grid::grid.draw(label_plot)
      grid::popViewport()
      grid::pushViewport(label_vp)
      grid::grid.text(label = dataInput()[1, input$check_make_labels_columns_selected], gp = grid::gpar(fontsize = input$font_size, lineheight = 0.8))
      grDevices::dev.off()
      list(src = outputfile,
           width = 80 * (input$page_width - 2 * input$width_margin)/input$numcol, 
           height = 80 * (input$page_height - 2 * input$height_margin)/input$numrow,
           alt = "Label Preview")
    }, deleteFile = TRUE
    )
  })
  
  # text indicator that pdf finished making
  
  
  observeEvent(input$make_pdf, {
    # When the button is clicked, wrap the code in a call to `withBusyIndicatorServer()`
    withBusyIndicatorServer("make_pdf", {
      Sys.sleep(1)
      baRcodeR::custom_create_PDF(user=FALSE, Labels = dataInput()[, input$check_make_labels_columns_selected], name = 'barcode_labels', 
                                  type = input$type, ErrCorr = input$err_corr, Fsz = input$font_size, Across = input$across, ERows = 0, ECols = 0, 
                                  trunc = input$trunc, numrow = input$numrow, numcol = input$numcol, page_width = input$page_width, 
                                  page_height = input$page_height, height_margin = input$height_margin, width_margin = input$width_margin, 
                                  label_width = input$label_width, label_height = input$label_height, x_space = input$x_space, y_space = input$y_space)
      
    })
  })
  
  
  output$downloadpdf <- downloadHandler(
    filename = function(){
      paste(input$filename,".pdf")
    },
    content = function(file) {
      file.copy("barcode_labels.pdf", file)
    },
    contentType = "application/pdf"
  )
  
  PDF_code_snippet<-shiny::reactive({
    noquote(paste0("custom_create_PDF(user=FALSE, Labels = label_csv[,", input$check_make_labels_columns_selected, "], name = \'", input$filename, "\', type = \'", input$type, "\', ErrCorr = \'", input$err_corr, "\', Fsz = ", input$font_size, ", Across = ", input$across, ", ERows = ", 0, ", ECols = ", 0, ", trunc = ", input$trunc, ", numrow = ", input$numrow, ", numcol = ", input$numcol, ", page_width = ", input$page_width, ", page_height = ", input$page_height, ", width_margin = ", input$width_margin, ", height_margin = ", input$height_margin, ", label_width = ", input$label_width, ", label_height = ", input$label_height,", x_space = ", input$x_space, ", y_space = ", input$y_space, ")"))
  })
  csv_code_snippet<-shiny::reactive({noquote(paste0("label_csv <- read.csv( \'", input$labels$name, "\', header = ", input$header, ", stringsAsFactors = F)"))})
  output$PDF_code_render<-shiny::renderText({
    paste(csv_code_snippet(), PDF_code_snippet(), sep = "\n")
  })
  
  # Listen for the 'done' event. This event will be fired when a user
  # is finished interacting with your application, and clicks the 'done'
  # button.
  shiny::observeEvent(input$done, {
    shiny::stopApp()
  })
  
})
)