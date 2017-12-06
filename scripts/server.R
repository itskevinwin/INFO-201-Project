current <- GetAttrRange('temp')

shinyServer(function(input, output, clientData, session) {
  output$text <- renderText({
    paste0("hi")
  })
  
  observe({
    choice <- input$mainf
    range <- GetAttrRange(choice)
    
    main.cities.filtered <- main.cities.data %>% 
      filter(as.numeric(choice) > as.numeric(range[1]) & 
               as.numeric(choice) < as.numeric(range[2])
      )
    
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
  
  output$cityf <- renderUI({
    selectInput(
      "cityf",
      label = "Select City",
      choices = main.cities.list,
      selected = "New York"
    )
  })
  
  output$latf <- renderUI({
    numericInput("latf", label = "Enter Latitude", value = 50)
  })
  
  output$lngf <- renderUI({
    numericInput("lngf", label = "Enter Longitude", value = 50)
  })
  
  output$zipf <- renderUI({
    numericInput("zipf", label = "Enter ZIP Code", value = 10008)
  })
  
  output$leafmap <- renderLeaflet({
    
    FetchMap(main.cities.filtered)
  })
})

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

GetAttrRange <- function(col) {
  vtr <- main.cities.data %>% .[[col]]
  return(list(
    min = vtr %>% min() %>% floor(),
    max = vtr %>% max() %>% ceiling()
  ))
}
