library(RSQLite)
library(ggmap)
library(ggplot2)

shinyServer(
  function(input, output){
    
    output$chart = renderPlot({
      pMap + geom_point(data=df %>% filter(State==input$stateFilter),
                        aes(x=longitude,
                            y=latitude,
                            col=Score)
                        ) + 
        theme(legend.position='none')
      
    })
  }
)