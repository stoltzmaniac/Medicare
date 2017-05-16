shinyUI(fluidPage(
  titlePanel("Medicare Data"),
  
  sidebarLayout(
    
    sidebarPanel(
      helpText("Pick One:"),
      
      selectInput("stateFilter", 
                  label = "State:",
                  choices = stateChoices,
                  selected = ALL_FILTER_NAME),
      
      selectInput("cityFilter",
                  label = 'City:',
                  choices = cityChoices,
                  selected = ALL_FILTER_NAME),
      
      selectInput("measureFilter",
                  label = 'Measure:',
                  choices = measureNameChoices,
                  selected = 'CAUTI: Predicted Cases'),
      
      sliderInput("maxResults", "Maximum results", min = 0, max = 100, value = 20),
      
      submitButton('Submit')
      
    , width = 2),

    mainPanel(
      tabsetPanel(id='main',
                  tabPanel('Measure per hospital plot', 
                    fluidRow(plotOutput("chart",width='100%', height = '800px'))
                  ),
                  tabPanel("Data",       
                    fluidRow(dataTableOutput("dataTable"))
                  )
      )
    )
  )
))