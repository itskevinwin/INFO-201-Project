library(plotly)
library(leaflet)
source('scripts/weather_data.R')

GetColor <- function(data) {
  sapply(data$weather, function(weather) {
    if(weather == 'Rain') {
      "blue"
    } else if(weather == 'Clouds'){
      "gray"
    }else if(weather == 'Clear'){
      "red"
    }else if(weather == 'Smoke'){
      "black"
    }else if(weather == 'Drizzle'){
      "green"
    }else if(weather == "Mist"){
      "purple"
    }else if(weather == "Snow"){
      "white"
    }else if(weather == "Thunderstorm"){
      "yellow"
    }else(
      "orange"
    ) })
}

FetchMap <- function(data) {
  icons <- awesomeIcons(
    icon = 'ios-close',
    iconColor = 'black',
    library = 'ion',
    markerColor = GetColor(data)
  )
  return(
    leaflet(data) %>%
      addTiles() %>%
      addAwesomeMarkers(
        ~lon, ~lat,
        icon = icons,
        label = paste0("City: ", data$cities),
        clusterOptions = markerClusterOptions(),
        popup = paste0(
          "City: ", main.cities.data$cities,
          "<br />Weather: ", main.cities.data$weather, 
          "<br />Description: ", main.cities.data$description,
          "<br />Min Temp: ", main.cities.data$temp.min, 
          " F°<br />Temp: ", main.cities.data$temp, 
          " F°<br />Max Temp: ", main.cities.data$temp.max, 
          " F°<br />Humidity: ", main.cities.data$humidity,
          "%<br />Cloudiness: ", main.cities.data$cloudiness,
          "%<br />Wind Speed: ", main.cities.data$wind.speed,
          " mps<br />Pressure: ", main.cities.data$pressure, 
          " hPa", "<br />Sunrise: ", main.cities.data$sunrise, 
          " GMT<br />Sunset: ", main.cities.data$sunset, " GMT",
          "<br /> Last Updated: ", main.cities.data$time, " GMT"
        )
      ) 
  )
}

leaf.map <- FetchMap(main.cities.data)
