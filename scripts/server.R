library(dplyr)
library(plotly)
library(shiny)
source('./weather_data.R')


GetAttrRange <- function(col) {
  vtr <- main.cities.data %>% .[[col]]
  return(list(
    min = vtr %>% min() %>% floor(),
    max = vtr %>% max() %>% ceiling()
  ))
}

current <- GetAttrRange('temp')

shinyServer(function(input, output, clientData, session) {

  output$temp <- renderPlotly({
    result.data <- GetRegionInfo(input$lat, input$lng)
    validate(
      need(!is.null(result.data), "No recorded weather data near specified coordinates.")
    )
      MakeTempPlot(result.data)
  })
  
  output$humid <- renderPlotly({
    result.data <- GetRegionInfo(input$lat, input$lng)
    validate(
      need(!is.null(result.data), "No recorded weather data near specified coordinates.")
    )
    MakeHumidPlot(result.data)
  })
  
  output$wind <- renderPlotly({
    result.data <- GetRegionInfo(input$lat, input$lng)
    validate(
      need(!is.null(result.data), "No recorded weather data near specified coordinates.")
    )
    MakeWindPlot(result.data)
  })
  
  output$text <- renderText({
    paste0("
    <link rel='stylesheet' href='https://fonts.googleapis.com/css?family=Tangerine'>
    <style>
    h1 {
      color: red;
      font-family: 'Tangerine', monospace;
    }
    </style>
    <h1>Documentation</h1>
    ")
  })
  
  observe({
    choice <- input$mainf
    range <- GetAttrRange(choice)
    updateSliderInput(
      session,
      "mainr",
      label = GetLabel(choice),
      min = range$min,
      max = range$max,
      value = c(range$min, range$max)
    )
  })
  
  updateSliderInput(
    session,
    "mainr",
    min = current$min,
    max = current$max,
    value = c(current$min, current$max)
  )
  
  output[['cityf1']] <- renderUI({
    GetSimpleUI('text', 'cityf1', 'Enter 1st City', 'New York')
  })
  
  output[['cityf2']] <- renderUI({
    GetSimpleUI('text', 'cityf2', 'Enter 2nd City', 'Seattle')
  })
  
  output[['latf1']] <- renderUI({
    GetSimpleUI('numeric', 'latf1', 'Enter 1st Latitude', 50)
  })
  
  output[['latf2']] <- renderUI({
    GetSimpleUI('numeric', 'latf2', 'Enter 2nd Latitude', 50)
  })
  
  output[['lngf1']] <- renderUI({
    GetSimpleUI('numeric', 'lngf1', 'Enter 1st Longitude', 50)
  })
  
  output[['lngf2']] <- renderUI({
    GetSimpleUI('numeric', 'lngf2', 'Enter 2nd Longitude', 50)
  })
  
  output[['zipf1']] <- renderUI({
    GetSimpleUI('numeric', 'zipf1', 'Enter 1st ZIP Code', 10008)
  })
  
  output[['zipf2']] <- renderUI({
    GetSimpleUI('numeric', 'zipf2', 'Enter 2nd ZIP Code', 10008)
  })
  
  output$leafmap <- renderLeaflet({
#<<<<<<< HEAD
    FetchMap(main.cities.data)
#=======
    main.cities.filtered <- main.cities.data 
    main.cities.filtered <- main.cities.filtered[
      main.cities.filtered[[input$mainf]] > input$mainr[1],
    ]
    main.cities.filtered <- main.cities.filtered[
      main.cities.filtered[[input$mainf]] < input$mainr[2],
    ]
    FetchMap(main.cities.filtered)

#>>>>>>> d9325b8
  })
})

MakeTempPlot <- function(data) {
  bar.plot <- plot_ly(data, x = ~temp, y = ~city, type = 'bar', name = 'Current Temperature',
                      marker = list(color = '#b1de00')) %>%
    add_trace(x = ~min.temp, name = 'Minimum Temperature of the Day', marker = list(color = '#468902')) %>%
    add_trace(x = ~max.temp, name = 'Maximum Temperature of the Day', marker = list(color = '#133954')) %>%
    layout(
      height = 1000,
      width = 800,
      title = "Current Temperature of Surrounding Areas",
      xaxis = list(title = "Temperature (Fahrenheit)"),
      yaxis = list(title = "Cities/Districts/Areas"),
      margin = list(l = 140, t=50, b=20), 
      barmode = 'group')
  ggplotly(bar.plot)
}

MakeHumidPlot <- function(data) {
  wind.plot <- plot_ly(data, x = ~humidity, y = ~city, type = 'bar', name = 'Current Humidity',
                       marker = list(color = '#60ccd9')) %>%
    layout(
      height = 1000,
      width = 800,
      title = "Current Humidity for Surrounding Areas",
      xaxis = list(title = "Current Humidity (%)"),
      yaxis = list(title = "Cities/Districts/Areas"),
      margin = list(l = 140, t=50, b=20) 
      )
  ggplotly(wind.plot)
}

MakeWindPlot <- function(data) {
  wind.plot <- plot_ly(data, x = ~wind.speed, y = ~city, type = 'bar', name = 'Current Wind Speed',
                       marker = list(color = '#17d39e')) %>%
    layout(
      height = 1000,
      width = 800,
      title = "Current Wind Speed for Surrounding Areas",
      xaxis = list(title = "Wind Speed (miles/second)"),
      yaxis = list(title = "Cities/Districts/Areas"),
      margin = list(l = 140, t=50, b=20)
      )
  ggplotly(wind.plot)
}

GetLabel <- function(lab) {
  lab <- case_when(
    lab == 'temp' ~ 'Temperature',
    lab == 'temp.max' ~ 'Maximum Temperature',
    lab == 'temp.min' ~ 'Minimum Temperature',
    TRUE ~ Cap(lab)
  )
  unit <- case_when(
    grepl('Temperature', lab) ~ '°F',
    lab == 'Pressure' ~ 'hPa',
    lab == 'Humidity' || lab == 'Cloudiness' ~ '%',
    lab == 'Visibility' ~ 'meter',
    grepl('Speed', lab) ~ 'mps',
    TRUE ~ ''
  )
  return(
    paste0(lab, ' (', unit, ')')
  )
}

Cap <- function(str) {
  str <- str %>% gsub('[.]', ' ', .) %>% strsplit(' ') %>% .[[1]]
  paste(
    toupper(substring(str, 1, 1)),
    substring(str, 2),
    sep = "",
    collapse = " "
  )
}

GetColor <- function(data) {
  sapply(data$weather, function(weather) {
    return(case_when(
      weather == 'Rain' ~ "blue",
      weather == 'Clouds' ~ "purple",
      weather == 'Clear' ~ "green",
      weather == 'Smoke' ~ "orange",
      weather == 'Drizzle' ~ "cyan",
      weather == "Mist" ~ "grey",
      weather == "Snow" ~ "white",
      weather == "Thunderstorm" ~ "black",
      TRUE ~ "yellow"
    ))
  })
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
          "City: ", data$cities,
          "<br />Weather: ", data$weather,
          "<br />Description: ", data$description,
          "<br />Min Temp: ", data$temp.min,
          " F°<br />Temp: ", data$temp,
          " F°<br />Max Temp: ", data$temp.max,
          " F°<br />Humidity: ", data$humidity,
          "%<br />Cloudiness: ", data$cloudiness,
          "%<br />Wind Speed: ", data$wind.speed,
          " mps<br />Pressure: ", data$pressure,
          " hPa", "<br />Sunrise: ", data$sunrise,
          " GMT<br />Sunset: ", data$sunset, " GMT",
          "<br /> Last Updated: ", data$time, " GMT"
        )
      )
  )
}

GetSimpleUI <- function(ui.name, obj.name, label, value) {
  if (ui.name == 'numeric') {
    return(numericInput(obj.name, label = label, value = value))
  } else {
    return(textInput(obj.name, label = label, value = value))
  }
}
