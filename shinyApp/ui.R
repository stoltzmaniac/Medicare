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
      
      selectInput("infectionFilter",
                  label = 'Infection:',
                  choices = infectionChoices,
                  selected = 'CAUTI'),

      selectInput("metricFilter",
                  label = 'Metric:',
                  choices = metricChoices,
                  selected = 'Predicted Cases'),
      
      sliderInput("maxResults", "Maximum results", min = SLIDER_MIN_VALUE, max = SLIDER_MAX_VALUE, value = SLIDER_INIT_VALUE)
      
    , width = 2),

    mainPanel(
      tabsetPanel(id='main',
                  tabPanel('Measure per hospital plot', p(),
                    fluidRow(plotlyOutput("chart",width='100%', height = '800px'))
                  ),
                  tabPanel('Measure per hospital map', p(),
                    fluidRow(leafletOutput("map", height = "800px"))
                  ),
                  tabPanel("Measure per hospital data", p(),      
                    fluidRow(dataTableOutput("dataTable"))
                  )
      )
    )
  )
))