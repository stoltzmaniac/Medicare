# Medicare server part

shinyServer(function(input, output, session){
  
  # get data to update cities based on state
  getStateData <- reactive({
    result <- df
    if(input$stateFilter != ALL_FILTER_NAME){
      result <- result %>% filter(State == input$stateFilter)
    }
    return(result)
  })
  
  # get data to update metrics based on infection
  getInfectionData <- reactive({
    return(df %>% filter(Infection == input$infectionFilter))
  })
  
  # Get input data for measurement for hospital vs score
  getMeasureData <- reactive({
    tmp = df %>% filter(!is.na(Score))
    
    if(input$stateFilter != ALL_FILTER_NAME){
      tmp <- tmp %>% filter(State == input$stateFilter)
    }
    if(input$cityFilter != ALL_FILTER_NAME){
      tmp <- tmp %>% filter(City == input$cityFilter)
    }
    if(input$infectionFilter != ALL_FILTER_NAME){
      tmp <- tmp %>% filter(Infection == input$infectionFilter)
    }
    if(input$metricFilter != ALL_FILTER_NAME){
      tmp <- tmp %>% filter(Metric == input$metricFilter)
    }
    
    tmp <- tmp %>% arrange(-Score)
    return(tmp %>% head(input$maxResults))
  })
  
  # interactive plot
  output$chart = renderPlotly({
    df_filtered <- getMeasureData()
    req(nrow(df_filtered) > 0)
    
    # change to factor otherwise plotly doesn't display it in right order
    df_filtered$Hospital.Name <- factor(df_filtered$Hospital.Name, levels = rev(df_filtered$Hospital.Name))
    
    #margin and plot
    m <- list(l = 300, r = 0, b = 40, t = 40, pad = 4)
    plot_ly(df_filtered, x = ~Score, y = ~Hospital.Name, 
            type = "bar", color = ~Compared.to.National, colors = c('lightblue','darkgrey','darkred'), 
            hoverinfo = 'text', text = ~paste('State: ', State, 
                                              '</br> City: ', City,
                                              '</br> Score: ', Score)) %>% 
      layout(title = paste("Metric value per hospital:", input$infectionFilter, input$metricFilter), xaxis = list(title = "Value"), yaxis = list(title = ""), margin = m) %>%
      config(displayModeBar = F) 
  })
  
  output$dataTable = renderDataTable({
    df_filtered <- getMeasureData()
    result <- df_filtered %>% arrange(Measure.Name, -Score) %>%
      select(Measure.Name,latlon,Hospital.Name,Score,Compared.to.National,State,City,Address,Phone.Number)
    
    # Hide some columns
    hideCols <- grep("latlon|State|City", colnames(result)) - 1
    datatable(result, rownames = FALSE, extensions = 'Buttons', class = "compact",
              options = list(pageLength = MAX_ITEMS_PER_PAGE, 
                             lengthMenu = LENGTH_MENU,
                             paging = TABLE_PAGING,
                             pagingType='simple',
                             dom = 'Blfrtip',
                             columnDefs = list(list(visible = FALSE, targets = hideCols)), # hide columns
                             buttons = list(list(extend = 'csv', exportOptions = list(columns = ':visible')), list(extend = 'pdf', exportOptions = list(columns = ':visible')),
                                            list(extend = 'colvis', text='Show/Hide Columns', collectionLayout='fixed two-column'))
              )
    ) %>%
      formatStyle(FORMAT_COLUMN, target = 'row',
                  backgroundColor = styleEqual(c(FORMAT_COLUMN_VALUE, FORMAT_COLUMN_VALUE_WARN), c(FORMAT_COLUMN_COLOR, FORMAT_COLUMN_COLOR_WARN)))
    
  })
  
  # map with all locations 
  output$map <- renderLeaflet({
    df_filtered <- getMeasureData()
    df_filtered$ScoreRel <- sqrt(df_filtered$Score / max(df_filtered$Score, na.rm = TRUE))
    leaflet()  %>%
      setView(lng = df_filtered[1,]$longitude, lat = df_filtered[1,]$latitude, zoom = 6) %>%
      addProviderTiles("Stamen.TonerLite", options = providerTileOptions(noWrap = TRUE)) %>% 
      addCircleMarkers(data = df_filtered, lat = ~latitude, lng = ~longitude, radius = ~ScoreRel*20, color = "#FF4742")
  })
  
  # Show a popup at the given location
  showPopup <- function(id, lat, lng) {
    df_filtered <- getMeasureData()
    row <- df_filtered[df_filtered$latitude == lat & df_filtered$longitude == lng,]
    content <- paste(
      "Hospital:", row$Hospital.Name, "<br>",
      "Score:", row$Score, "<br>")
    leafletProxy("map") %>% addPopups(lng, lat, content, layerId = id)
  }
  
  # When map is clicked, show a popup
  observeEvent(input$map_marker_click, {
    leafletProxy("map") %>% clearPopups()
    event <- input$map_marker_click
    if (is.null(event))
      return()
    
    isolate({
      showPopup(event$id, event$lat, event$lng)
    })
  })
  
  # Update cities when selecting state
  observeEvent(input$stateFilter, {
    df_filtered <- getStateData()
    updateSelectInput(session, "cityFilter", label = "City:", choices = append(ALL_FILTER_NAME, unique(df_filtered$City)))
  }, ignoreInit = TRUE)
  
  # Update metrics when selecting infection
  observeEvent(input$infectionFilter, {
    df_filtered <- getInfectionData()
    updateSelectInput(session, "metricFilter", label = "Metric:", choices = unique(df_filtered$Metric))
  }, ignoreInit = TRUE)
  
}
)