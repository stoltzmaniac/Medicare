shinyUI(fluidPage(
  titlePanel("Medicare Data"),
  
  sidebarLayout(
    
    fluidRow(
    
    sidebarPanel(
      helpText("Pick One:"),
      
      selectInput("stateFilter", 
                  label = "State:",
                  choices = stateChoices,
                  selected = 'CO'),
      
      selectInput("cityFilter",
                  label = 'City:',
                choices = cityChoices,
                selected = 'FORT COLLINS'),
      
      submitButton('Submit')
      
    )
      
    ),
    
    mainPanel(
      fluidRow(
      plotOutput("chart",width='100%')
      ),
      
      br(),
      br(),
      
      fluidRow(
      dataTableOutput("dataTable"))
    )
  )
))