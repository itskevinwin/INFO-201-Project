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
    "REPORT",
    titlePanel("City Weather Report"),
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
        conditionalPanel(condition = "input.locate == 1", uiOutput("cityf")),
        conditionalPanel(
          condition = "input.locate == 2", 
          uiOutput("latf"),
          uiOutput("lngf")
        ),
        conditionalPanel(condition = "input.locate == 3", uiOutput("zipf"))
      ),
      mainPanel()
    )
  )
))
