#

shinyServer(function(input, output, session){
    
    # Get input data for measurement for hospital vs score plot
    getMeasureData <- reactive({
      tmp = df %>% filter(!is.na(Score))
      
      if(input$stateFilter != ALL_FILTER_NAME){
        tmp <- tmp %>% filter(State == input$stateFilter)
      }
      if(input$cityFilter != ALL_FILTER_NAME){
        tmp <- tmp %>% filter(City == input$cityFilter)
      }
      if(input$measureFilter != ALL_FILTER_NAME){
        tmp <- tmp %>% filter(Measure.Name == input$measureFilter)
      }
      return(tmp %>% top_n(input$maxResults))
    })
    
    # create plot
    output$chart = renderPlot({
      df_filtered <- getMeasureData()
      p = ggplot(df_filtered, aes(x=reorder(Hospital.Name, Score), y=Score)) + geom_bar(stat='identity', position='dodge') + 
        coord_flip() + 
        theme(text = element_text(size=16)) + 
        scale_y_sqrt(labels = comma) +
        ggtitle(paste("Scores per hospital for measure:", input$measureFilter)) +
        xlab("Hospital name")
      p
    })
    
    output$dataTable = renderDataTable({
      df_filtered <- getMeasureData()
      result <- df_filtered %>% arrange(Measure.Name, -Score) %>%
        select(Measure.Name,latlon,Hospital.Name,Score,Compared.to.National,Address,Phone.Number)
      
      # Hide some columns
      hideCols <- grep("latlon", colnames(result)) - 1
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
  }
)