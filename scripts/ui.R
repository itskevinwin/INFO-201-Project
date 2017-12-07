# ui.R file

library(shiny)
library(shinythemes)
library(leaflet)

source('./weather_data.R')

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
#<<<<<<< HEAD
        conditionalPanel(condition = "input.locate == 3", uiOutput("zipf"))
      ),
#=======
        conditionalPanel(
          condition = "input.locate == 3", 
          uiOutput("zipf1"),
          uiOutput("zipf2")
      )),
#>>>>>>> d9325b8
      mainPanel(
        htmlOutput('text')
      )
    ),
    tabPanel(
      "REGION",
      titlePanel("Weather Conditions In Rectangle Region"),
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
    )
  )
)
