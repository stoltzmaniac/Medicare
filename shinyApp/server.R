library(RSQLite)
library(ggmap)
library(ggplot2)
library(plotly)

shinyServer(
  function(input, output){
    
    output$chart = renderPlot({
      
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
      tmp <- tmp %>% top_n(input$maxResults)

      print(str(tmp))
      print(tmp$Score)
      p = ggplot(tmp, aes(x=reorder(Hospital.Name, Score), y=Score)) + geom_bar(stat='identity', position='dodge') + 
        coord_flip() + 
        theme(text = element_text(size=16)) + 
        scale_y_sqrt(labels = comma) +
        ggtitle(paste("Scores per hospital for measure:", input$measureFilter)) +
        xlab("Hospital name")
      p 
      # ggplotly(p)
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
      tmp <- tmp %>% top_n(input$maxResults)
      
      tmp %>% arrange(Measure.Name) %>%
        select(Measure.Name,latlon,Hospital.Name,Score,Compared.to.National,Address,Phone.Number)
    })
    
  }
)