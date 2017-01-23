shinyUI(fluidPage(
  titlePanel("Medicare Data"),
  
  sidebarLayout(
    sidebarPanel(
      helpText("Pick One:"),
      
      selectInput("stateFilter", 
                  label = "pick one",
                  choices = stateChoices,
                  selected=stateChoices[1])
    ),
    
    mainPanel(plotOutput("chart"))
  )
))