library(RSQLite)
library(ggmap)
library(ggplot2)

shinyServer(
  function(input, output){
    
    output$chart = renderPlot({
      
      tmp = df %>%
        filter(Score != 'Not Available') %>%
        filter(State == input$stateFilter) %>%
        filter(City == input$cityFilter)

      p = ggplot(tmp,aes(x=reorder(Measure.Name,Score),y=Score,fill=Hospital.Name))
      p + geom_bar(stat='identity',position='dodge') + 
#        facet_wrap(~Hospital.Name,ncol=1) + 
        coord_flip() + 
        theme(legend.position = 'none')
      
      # pMap = ggmap(get_map(location = input$zipcodeFilter,
      #                      zoom=8,
      #                      maptype = 'terrain',
      #                      color = "bw")) 
      # 
      # pMap + geom_point(data=tmp,
      #                   aes(x=longitude,
      #                       y=latitude,
      #                       col=Score)
      #                   ) + 
      #   theme(legend.position='none')
      
    })
    
    output$dataTable = renderDataTable({
      
      df %>%
        filter(Score != 'Not Available') %>%
        filter(State == input$stateFilter) %>%
        filter(City == input$cityFilter) %>%
        arrange(Measure.Name) %>%
        select(Measure.Name,latlon,Hospital.Name,Score,Compared.to.National,Address,Phone.Number)
      
    })
    
  }
)