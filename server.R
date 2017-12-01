library(shiny)
library(dplyr)
library(tidyr)
library(plotly)
source('scripts/weather_data.R')

shinyServer(function(input, output) {
  output$distPlotly <- renderPlotly({
    # give state boundaries a white border
    l <- list(color = toRGB("white"), width = 2)
    # specify some map projection/options
    g <- list(
      scope = 'usa',
      projection = list(type = 'albers usa')
    )
    
    plot_geo(main.cities.data, locationmode = 'USA-states') %>%
      layout(title = 'Weather of 50 of the Most Populated Cities in the US<br>', geo = g) %>%  
      add_markers(x = ~lon, y = ~lat, size = ~temp.max, color = ~weather, colors = "RdGy", hoverinfo = "text",
                  text = ~paste0(cities,"<br />", main.cities.data$temp,", ", main.cities.data$temp.min,"<br /> Temp Min: ", 
                                 main.cities.data$temp.min, "<br /> Weather: ", main.cities.data$weather))
    
  })
  
})
