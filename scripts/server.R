current <- GetAttrRange('temp')

shinyServer(function(input, output, clientData, session) {
  output$text <- renderText({
    paste0("hi")
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
    main.cities.filtered <- main.cities.data 
    
    main.cities.filtered <- main.cities.filtered[main.cities.filtered[[input$mainf]] > input$mainr[1],]
    main.cities.filtered <- main.cities.filtered[main.cities.filtered[[input$mainf]] < input$mainr[2],]
    
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

GetAttrRange <- function(col) {
  vtr <- main.cities.data %>% .[[col]]
  return(list(
    min = vtr %>% min() %>% floor(),
    max = vtr %>% max() %>% ceiling()
  ))
}

