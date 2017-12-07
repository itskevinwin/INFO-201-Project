# ui.R file

source('./weather_data.R')

library(shiny)
library(shinythemes)
library(leaflet)
library(plotly)

shinyUI(navbarPage(
  theme = shinytheme("flatly"),
  "US Current Weather App",
  tabPanel(
    "MAIN CITIES MAP",
    titlePanel("US Main Cities Weather Map"),
    sidebarLayout(
      sidebarPanel(
        selectInput(
          "mainf",
          label = h3("Filter By"), 
          choices = list(
            "Temperature" = "temp",
            "Max Temperature" = "temp.max",
            "Min Temperature" = "temp.min",
            "Pressure" = "pressure",
            "Humidity" = "humidity",
            "Visibility" = "visibility",
            "Wind Speed" = "wind.speed",
            "Cloudiness" = "cloudiness"
          ), 
          selected = "temp"
        ),
        sliderInput(
          "mainr",
          label = "Temperature (°F)",
          min = 0,
          max = 100,
          value = c(30,60)
        )
      ),
      mainPanel(
        leafletOutput("leafmap")
      )
    )
  ),
  tabPanel(
    "COMPARISON",
    titlePanel("Weather Comparison Between 2 Cities"),
    sidebarLayout(
      sidebarPanel(
        selectInput(
          "locate",
          label = "Locate By",
          choices = list(
            "City Name" = 1,
            "Latitude & Longitude" = 2,
            "ZIP Code" = 3
          ),
          selected = 1
        ),
        conditionalPanel(
          condition = "input.locate == 1", 
          uiOutput("cityf1"),
          uiOutput("cityf2")
          ),
        conditionalPanel(
          condition = "input.locate == 2", 
          uiOutput("latf1"),
          uiOutput("lngf1"),
          uiOutput("latf2"),
          uiOutput("lngf2")
        ),
        conditionalPanel(
          condition = "input.locate == 3", 
          uiOutput("zipf1"),
          uiOutput("zipf2")
      )),
      mainPanel(
        htmlOutput("report"),
        conditionalPanel(
          condition = "input.locate == 1", 
          plotlyOutput("CityTempChart"),
          plotlyOutput("CityPressureChart"),
          plotlyOutput("CityCloudinessChart"), 
          plotlyOutput("CityVisibilityChart"),
          plotlyOutput("CityWindChart")
        ),
        conditionalPanel(
          condition = "input.locate == 2", 
          plotlyOutput("CoordinateTempChart"),
          plotlyOutput("CoordinatePressureChart"), 
          plotlyOutput("CoordinateCloudinessChart"),
          plotlyOutput("CoordinateVisibilityChart"), 
          plotlyOutput("CoordinateWindChart")
        ),
        conditionalPanel(
          condition = "input.locate == 3", 
          plotlyOutput("ZipTempChart"),
          plotlyOutput("ZipPressureChart"),
          plotlyOutput("ZipCloudinessChart"), 
          plotlyOutput("ZipVisibilityChart"),
          plotlyOutput("ZipWindChart")
        )
      )
    )
  ),
  tabPanel(
    "REGION",
    titlePanel("Weather Within A Rectangular Zone"),
    sidebarLayout(
      sidebarPanel(
        selectInput(
          "choose",
          label = "Select Measurement",
          choices = list(
            "Temperature" = 1,
            "Humidity" = 2,
            "Wind Speed" = 3
          ),
          selected = 1
        ),
        numericInput("lat", label = "Enter Latitude", value = 47),
        numericInput("lng", label = "Enter Longitude", value = -122)
      ),
      mainPanel(
        conditionalPanel(
          condition = "input.choose == 1",
          plotlyOutput("temp")
        ),
        conditionalPanel(
          condition = "input.choose == 2",
          plotlyOutput("humid")
        ),
        conditionalPanel(
          condition = "input.choose == 3",
          plotlyOutput("wind")
        )
      )
    )
  ),
  tabPanel(
    "DOCUMENTATION",
    titlePanel("Documentation Of Weather App"),
    sidebarLayout(
      sidebarPanel(
        htmlOutput('content')
      ),
      mainPanel(
        htmlOutput('text')
      )
    )
  )
))
