library(plotly)
source('scripts/weather_data.R')

# give state boundaries a white border
l <- list(color = toRGB("white"), width = 2)
# specify some map projection/options
g <- list(
  scope = 'usa',
  projection = list(type = 'albers usa')
)
map <- plot_geo(main.cities.data, locationmode = 'USA-states') %>%
  layout(title = 'Weather of 50 of the Most Populated Cities in the US<br>', geo = g) %>%  
  add_markers(x = ~lon, y = ~lat, size = ~temp, color = ~weather, colors = "Paired", hoverinfo = "text",
              text = ~paste0(cities,"<br />Temp: ", main.cities.data$temp,"<br />Min Temp: ", main.cities.data$temp.min,"<br />Temp Max: ", 
                             main.cities.data$temp.max, "<br />Weather: ", main.cities.data$weather))
