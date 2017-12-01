# ui.R file

library(shiny)

shinyUI(navbarPage(
  'US Current Weather App',
  tabPanel(
    'Main Cities Map',
    titlePanel('US Main Cities Weather Map'),
    sidebarLayout(
      sidebarPanel(
        selectInput(
          "filter.by",
          label = h3("Filter By"), 
          choices = list(
            "Temperature" = "temp",
            "Max Temperature" = "temp.max",
            "Min Temperature" = "temp.min",
            "Pressure" = "pressure",
            "Humidity" = "humidity",
            "Visibility" = "visibility",
            "Winde Speed" = "wind.speed",
            "Cloudiness" = "cloudiness"
          ), 
          selected = "temp"
        ),
        conditionalPanel(
          "value.range",
          label = h3("output.label"),
          min = min,
          max = max,
          value = c(50,60)
        )
      ),
      mainPanel(
            plotOutput("text")
      )
    )
  ) 
))
