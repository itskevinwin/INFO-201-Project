StripUnknown <- function(data, col) {
  return(data[data[[col]] != 'Unknown',])
}

GetAttrRange <- function(col) {
  vtr <- main.cities.data %>% StripUnknown(col) %>% .[[col]] %>% as.numeric()
  return(list(
    min = vtr %>% min() %>% floor(),
    max = vtr %>% max() %>% ceiling()
  ))
}

current <- GetAttrRange('temp')
warning.msg <- "No recorded weather data near specified coordinates."

shinyServer(function(input, output, clientData, session) {
  output$text <- renderText({
    documentation
  })
  
  output$content <- renderText({
    content
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
    GetSimpleUI('numeric', 'latf1', 'Enter 1st Latitude', 47.6062)
  })
  
  output[['latf2']] <- renderUI({
    GetSimpleUI('numeric', 'latf2', 'Enter 2nd Latitude', 34.0522)
  })
  
  output[['lngf1']] <- renderUI({
    GetSimpleUI('numeric', 'lngf1', 'Enter 1st Longitude', -122.3321)
  })
  
  output[['lngf2']] <- renderUI({
    GetSimpleUI('numeric', 'lngf2', 'Enter 2nd Longitude', -118.2437)
  })
  
  output[['zipf1']] <- renderUI({
    GetSimpleUI('numeric', 'zipf1', 'Enter 1st ZIP Code', 98105)
  })
  
  output[['zipf2']] <- renderUI({
    GetSimpleUI('numeric', 'zipf2', 'Enter 2nd ZIP Code', 10008)
  })
  
  output$leafmap <- renderLeaflet({
    col <- input$mainf
    filtered <- StripUnknown(main.cities.data, col)
    filtered[[col]] <- as.numeric(as.character(filtered[[col]]))
    filtered <- filtered[
      filtered[[col]] >= input$mainr[1],
    ]
    filtered <- filtered[
      filtered[[col]] <= input$mainr[2],
    ]
    FetchMap(filtered)
  })
  
  # Comparison report used for writing a dynamic paragraph that compares the
  # weather in two cities
  output$report <- renderText({
    city.one <- NULL
    city.two <- NULL
    if (input$locate == 1) {
      city.one <- GetCityInfo(q = input$cityf1)
      city.two <- GetCityInfo(q = input$cityf2)
    } else if (input$locate == 2) {
      city.one <- GetCityInfo(lat = input$latf1, lon = input$lngf1)
      city.two <- GetCityInfo(lat = input$latf2, lon = input$lngf2)
    } else {
      city.one <- GetCityInfo(zip = input$zipf1)
      city.two <- GetCityInfo(zip = input$zipf2)
    }
    MakeReport(city.one, city.two)
  })
  
  # Search by city: Temperature chart
  output$CityTempChart <- renderPlotly({
    cities.data <- CreateMultiChartDF(
      q1 = input$cityf1,
      q2 = input$cityf2,
      type = c("Low", "Current", "High"),
      cols = c("temp.min", "temp", "temp.max")
    )
    MakeMultiGraph(
      cities.data,
      "#385d8b",
      "#9ad044",
      "Temperature Type By City", 
      "Temperature (Degrees)",
      input$cityf1,
      input$cityf2
    )
  })
  
  # shiny::validate( need(!is.null(cities.data), 'No recorded weather data near
  # specified coordinates.') )
  
  # Pressure Chart
  output$CityPressureChart <- renderPlotly({
    cities.data <- CreateSinChartDF(
      q1 = input$cityf1,
      q2 = input$cityf2,
      col = c("pressure")
    )
    shiny::validate(
      need(!is.null(cities.data),
           "No recorded weather data near specified coordinates.")
    )
    colnames(cities.data) <- c("Cities", "Pressure")
    MakeSinGraph(
      cities.data,
      "#385d8b",
      "#9ad044",
      "Compared Cities",
      "Air Pressure (hPa)"
    )  
  })
  
  # Humidity vs cloudity
  output$CityCloudinessChart <- renderPlotly({
    cities.data <- CreateMultiChartDF(
      q1 = input$cityf1,
      q2 = input$cityf2,
      type = c("Humidity", "Cloudiness"),
      cols = c("humidity", "cloudiness")
    )
    shiny::validate(
      need(!is.null(cities.data),
           "No recorded weather data near specified coordinates.")
    )
    MakeMultiGraph(
      cities.data,
      "#385d8b",
      "#9ad044",
      "Humidity/Cloudiness",
      "Percentage",
      input$cityf1,
      input$cityf2
    )  
  })
  
  # Visibility Chart
  output$CityVisibilityChart <- renderPlotly({
    cities.data <- CreateSinChartDF(
      q1 = input$cityf1,
      q2 = input$cityf2,
      col = c("visibility")
    )
    shiny::validate(
      need(!is.null(cities.data),
           "No recorded weather data near specified coordinates.")
    )
    colnames(cities.data) <- c("Cities", "Visibility")
    MakeSinGraph(
      cities.data,
      "#385d8b",
      "#9ad044",
      "Compared Cities",
      "Visibility (m)"
    )  
  })
  
  # Wind speed Chart
  output$CityWindChart <- renderPlotly({
    cities.data <- CreateSinChartDF(
      q1 = input$cityf1,
      q2 = input$cityf2,
      col = c("wind.speed")
    )
    shiny::validate(
      need(!is.null(cities.data),
           "No recorded weather data near specified coordinates.")
    )
    colnames(cities.data) <- c("Cities", "Wind Speed")
    MakeSinGraph(
      cities.data,
      "#385d8b",
      "#9ad044",
      "Compared Cities",
      "Wind Speed (mps)"
    )  
  })
  
  # Search by coordinates: Temperature chart
  output$CoordinateTempChart <- renderPlotly({
    cities.data <- CreateMultiChartDF(
      lat1 = input$latf1,
      lat2 = input$latf2,
      lon1 = input$lngf1, 
      lon2 = input$lngf2,
      type = c("Low", "Current", "High"),
      cols = c("temp.min", "temp", "temp.max")
    )
    shiny::validate(
      need(!is.null(cities.data),
           "No recorded weather data near specified coordinates.")
    )
    coord.col.names <- colnames(cities.data)
    MakeMultiGraph(
      cities.data,
      "#385d8b",
      "#9ad044",
      "Temperature Type By City",
      "Temperature (Degrees)",
      coord.col.names[2],
      coord.col.names[3]
    )  
  })
  
  # Pressure Chart
  output$CoordinatePressureChart <- renderPlotly({
    cities.data <- CreateSinChartDF(
      lat1 = input$latf1,
      lat2 = input$latf2,
      lon1 = input$lngf1, 
      lon2 = input$lngf2,
      col = c("pressure")
    )
    shiny::validate(
      need(!is.null(cities.data),
           "No recorded weather data near specified coordinates.")
    )
    colnames(cities.data) <- c("Cities", "Pressure")
    MakeSinGraph(
      cities.data,
      "#385d8b",
      "#9ad044",
      "Compared Cities",
      "Air Pressure (hPa)"
    )  
  })
  
  # Humidity vs Cloudiness
  output$CoordinateCloudinessChart <- renderPlotly({
    cities.data <- CreateMultiChartDF(
      lat1 = input$latf1,
      lat2 = input$latf2,
      lon1 = input$lngf1, 
      lon2 = input$lngf2,
      type = c("Humidity", "Cloudiness"),
      cols = c("humidity", "cloudiness")
    )
    shiny::validate(
      need(!is.null(cities.data),
           "No recorded weather data near specified coordinates.")
    )
    coord.col.names <- colnames(cities.data)
    MakeMultiGraph(
      cities.data,
      "#385d8b",
      "#9ad044",
      "Humidity/Cloudiness",
      "Percentage", 
      coord.col.names[2],
      coord.col.names[3]
    )  
  })
  
  # Visibility Chart
  output$CoordinateVisibilityChart <- renderPlotly({
    cities.data <- CreateSinChartDF(
      lat1 = input$latf1,
      lat2 = input$latf2,
      lon1 = input$lngf1, 
      lon2 = input$lngf2,
      col = c("visibility")
    )
    shiny::validate(
      need(!is.null(cities.data),
           "No recorded weather data near specified coordinates.")
    )
    colnames(cities.data) <- c("Cities", "Visibility")
    MakeSinGraph(
      cities.data,
      "#385d8b",
      "#9ad044",
      "Compared Cities",
      "Visibility (m)"
    )
  })
  
  # Wind Speed Chart
  output$CoordinateWindChart <- renderPlotly({
    cities.data <- CreateSinChartDF(
      lat1 = input$latf1,
      lat2 = input$latf2,
      lon1 = input$lngf1, 
      lon2 = input$lngf2,
      col = c("wind.speed")
    )
    shiny::validate(
      need(!is.null(cities.data),
           "No recorded weather data near specified coordinates.")
    )
    colnames(cities.data) <- c("Cities", "Wind Speed")
    MakeSinGraph(
      cities.data,
      "#385d8b",
      "#9ad044",
      "Compared Cities",
      "Wind Speed (mps)"
    )  
  })
  
  # Search by Zip Temperature chart
  output$ZipTempChart <- renderPlotly({
    cities.data <- CreateMultiChartDF(
      zip1 = input$zipf1,
      zip2 = input$zipf2,
      type = c("Low", "Current", "High"),
      cols = c("temp.min", "temp", "temp.max")
    )
    shiny::validate(
      need(!is.null(cities.data),
           "No recorded weather data near specified coordinates.")
    )
    zip.col.names <- colnames(cities.data)
    MakeMultiGraph(
      cities.data,
      "#385d8b",
      "#9ad044",
      "Temperature Type By City", 
      "Temperature (Degrees)",
      zip.col.names[2],
      zip.col.names[3]
    )  
  })
  
  # Pressure chart
  output$ZipPressureChart <- renderPlotly({
    cities.data <- CreateSinChartDF(
      zip1 = input$zipf1,
      zip2 = input$zipf2,
      col = c("pressure")
    )
    shiny::validate(
      need(!is.null(cities.data),
           "No recorded weather data near specified coordinates.")
    )
    colnames(cities.data) <- c("Cities", "Air Pressure")
    MakeSinGraph(
      cities.data,
      "#385d8b",
      "#9ad044",
      "Compared Cities",
      "Air Pressure (hPa)"
    )  
  })
  
  # Humidity vs Cloudiness chart
  output$ZipCloudinessChart <- renderPlotly({
    cities.data <- CreateMultiChartDF(
      zip1 = input$zipf1,
      zip2 = input$zipf2,
      type = c("Humidity", "Cloudiness"),
      cols = c("humidity", "cloudiness")
    )
    shiny::validate(
      need(!is.null(cities.data),
           "No recorded weather data near specified coordinates.")
    )
    zip.col.names <- colnames(cities.data)
    MakeMultiGraph(
      cities.data,
      "#385d8b",
      "#9ad044",
      "Humidity/Cloudiness",
      "Percentage",
      zip.col.names[2],
      zip.col.names[3]
    )  
  })
  
  # Visisbility chart
  output$ZipVisibilityChart <- renderPlotly({
    cities.data <- CreateSinChartDF(
      zip1 = input$zipf1,
      zip2 = input$zipf2,
      col = c("visibility")
    )
    shiny::validate(
      need(!is.null(cities.data),
           "No recorded weather data near specified coordinates.")
    )
    colnames(cities.data) <- c("Cities", "Visibility")
    MakeSinGraph(
      cities.data,
      "#385d8b",
      "#9ad044",
      "Compared Cities",
      "Visibility (m)"
    )  
  })
  
  # Wind Speed chart
  output$ZipWindChart <- renderPlotly({
    cities.data <- CreateSinChartDF(
      zip1 = input$zipf1,
      zip2 = input$zipf2,
      col = c("wind.speed")
    )
    shiny::validate(
      need(!is.null(cities.data),
           "No recorded weather data near specified coordinates.")
    )
    colnames(cities.data) <- c("Cities", "Wind Speed")
    MakeSinGraph(
      cities.data,
      "#385d8b",
      "#9ad044",
      "Compared Cities",
      "Wind Speed (mps)"
    )
  })
  
  output$temp <- renderPlotly({
    result.data <- GetRegionInfo(input$lat, input$lng)
    shiny::validate(
      need(!is.null(result.data), warning.msg)
    )
    MakeTempPlot(result.data)
  })
  
  output$humid <- renderPlotly({
    result.data <- GetRegionInfo(input$lat, input$lng)
    shiny::validate(
      need(!is.null(result.data), warning.msg)
    )
    MakeHumidPlot(result.data)
  })
  
  output$wind <- renderPlotly({
    result.data <- GetRegionInfo(input$lat, input$lng)
    shiny::validate(
      need(!is.null(result.data), warning.msg)
    )
    MakeWindPlot(result.data)
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
          "<br />Temperature: ", data$temp,
          " °F<br />Minimum Temperature: ", data$temp.min,
          " °F<br />Maximum Temperature: ", data$temp.max,
          " °F<br />Humidity: ", data$humidity,
          " %<br />Visibility: ", data$visibility,
          " m<br />Cloudiness: ", data$cloudiness,
          " %<br />Wind Speed: ", data$wind.speed,
          " mps<br />Pressure: ", data$pressure,
          " hPa<br />Sunrise: ", data$sunrise,
          " GMT<br />Sunset: ", data$sunset,
          " GMT<br />Last Updated: ", data$time,
          " GMT"
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

MakeTempPlot <- function(data) {
  bar.plot <- plot_ly(
    data,
    x = ~temp,
    y = ~city,
    type = 'bar',
    name = 'Current Temperature',
    marker = list(color = '#b1de00 ')
  ) %>% add_trace(
    x = ~min.temp,
    name = 'Minimum Temperature of the Day',
    marker = list(color = '#468902 ')
  ) %>% add_trace(
    x = ~max.temp,
    name = 'Maximum Temperature of the Day',
    marker = list(color = '#133954 ')
  ) %>% layout(
    height = 1000,
    width = 800,
    title = "Temperature Of Locations Within Region",
    xaxis = list(title = "Temperature (Fahrenheit)"),
    yaxis = list(title = "Cities/Districts/Areas"),
    margin = list(l = 140, t = 50, b = 50),
    barmode = 'group'
  )
  ggplotly(bar.plot)
}

MakeHumidPlot <- function(data) {
  wind.plot <- plot_ly(
    data,
    x = ~humidity,
    y = ~city,
    type = 'bar',
    name = 'Current Humidity',
    marker = list(color = '#60ccd9 ')
  ) %>% layout(
    height = 1000,
    width = 800,
    title = "Humidity Of Locations Within Region",
    xaxis = list(title = "Current Humidity (%)"),
    yaxis = list(title = "Cities/Districts/Areas"),
    margin = list(l = 140, t = 50, b = 50)
  )
  ggplotly(wind.plot)
}

MakeWindPlot <- function(data) {
  wind.plot <- plot_ly(
    data,
    x = ~wind.speed,
    y = ~city,
    type = 'bar',
    name = 'Current Wind Speed',
    marker = list(color = '#17d39e ')
  ) %>% layout(
    height = 1000,
    width = 800,
    title = "Wind Speed Of Locations Within Region",
    xaxis = list(title = "Wind Speed (miles/second)"),
    yaxis = list(title = "Cities/Districts/Areas"),
    margin = list(l = 140, t = 50, b = 50)
  )
  ggplotly(wind.plot)
}

MakeReport <- function(city.one, city.two) {
  if (is.null(city.one) | is.null(city.two)) {
    return(NULL)
  } else {
    paste0(
      "<style>
      body {
      font-family: 'Times', sans-serif;
      }
      </style>
      ", 
      "<h3>Summary Of Comparison</h3>",
      "Comparing the two locations of ", 
      city.one[1, 1],
      " and ",
      city.two[1, 1],
      ", found within their respective countries of ", 
      city.one$country,
      " and ",
      city.two$country,
      ", shows us that the current weather within the first location is ",
      city.one$description,
      " while ",
      city.two$description,
      " in city two. The time is currently ", 
      city.one$time,
      " in ",
      city.one[1, 1],
      " and the temperature within the location is currently ", 
      round(city.one$temp),
      " degrees Fahrenheit. In ",
      city.two[1, 1],
      " it is currently showing ", 
      city.two$time,
      " on the clock, with an outside temperature of ",
      round(city.two$temp), 
      " degrees. A high of ",
      round(city.one$temp.max),
      " degrees and a low of ", 
      round(city.one$temp.min),
      " will fall over ",
      city.one[1, 1],
      " today, compared to ", 
      city.two[1, 1],
      " which has a high of ",
      round(city.two$temp.max),
      " and a low of ", 
      round(city.two$temp.min),
      " degrees Farenheit. A current wind speed of ", 
      city.one$wind.speed,
      " meters per second is repored in the first location and a wind speed of ", 
      city.two$wind.speed,
      " meters per second in the other. Sunrise will be at ", 
      city.two$sunrise,
      " tomorrow morning and sunset is reported to be at ", 
      city.two$sunset,
      " tomorrow night. ",
      city.one[1, 1],
      " will have a sunrise at ", 
      city.one$sunrise,
      " and a sunset at ",
      city.one$sunset,
      ". Current air pressure is sitting at about ", 
      city.one$pressure,
      " hPa in ",
      city.one[1, 1],
      " along with ",
      city.two[1, 1],
      "'s ",
      city.two$pressure,
      " hPa. The humidtiy is about ",
      city.one$humidity, 
      "% in ",
      city.one[1, 1],
      " and ",
      city.two$humidity,
      "% in ",
      city.two[1, 1],
      "."
    )
}
  }

MakeSinGraph <- function(cities.data, color1, color2, y.title, x.title) {
  city.graph <- plot_ly(
    cities.data,
    y = ~cities.data[, 1],
    x = ~cities.data[, 2],
    type = "bar",
    color = ~cities.data[, 1],
    orientation = "h",
    marker = list(color = c(color1, color2))) %>% layout(
      yaxis = list(title = y.title),
      xaxis = list(title = x.title), 
      margin = list(l = 150), barmode = "group"
    )
  return(city.graph)
}

MakeMultiGraph <- function(
  cities.data,
  color1,
  color2,
  y.title,
  x.title,
  city1,
  city2
) {
  graph <- plot_ly(
    cities.data,
    y = ~cities.data[, 1],
    x = ~cities.data[, 2],
    type = "bar", 
    name = city1,
    orientation = "h",
    marker = list(color = color1)) %>% add_trace(
      x = ~cities.data[, 3],
      name = city2,
      marker = list(color = color2)) %>% layout(
        yaxis = list(title = y.title), 
        xaxis = list(title = x.title),
        margin = list(l = 150),
        barmode = "group"
      )
}

CreateSinChartDF <- function(
  q1 = NULL,
  q2 = NULL,
  lat1 = NULL,
  lat2 = NULL,
  lon1 = NULL, 
  lon2 = NULL,
  zip1 = NULL,
  zip2 = NULL,
  col
) {
  val.1 <- FetchRowCity(q = q1, lat = lat1, lon = lon1, zip = zip1, cols = c(col))
  val.2 <- FetchRowCity(q = q2, lat = lat2, lon = lon2, zip = zip2, cols = c(col))
  cities <- c(val.1$city, val.2$city)
  attr <- c(val.1$row, val.2$row)
  df <- data.frame(cities, attr, stringsAsFactors = FALSE)
  if (nrow(df) == 0) {
    return(NULL)
  } else {
    return(df)
  }
}

CreateMultiChartDF <- function(
  q1 = NULL,
  q2 = NULL,
  lat1 = NULL,
  lat2 = NULL,
  lon1 = NULL, 
  lon2 = NULL,
  zip1 = NULL,
  zip2 = NULL,
  type,
  cols
) {
  row.1.df <- FetchRowCity(q = q1, lat = lat1, lon = lon1, zip = zip1, cols = cols)
  row.2.df <- FetchRowCity(q = q2, lat = lat2, lon = lon2, zip = zip2, cols = cols)
  row.1 <- row.1.df$row
  row.2 <- row.2.df$row
  city.1 <- row.1.df$city
  city.2 <- row.2.df$city
  if (is.null(row.1) | is.null(row.2) | is.null(city.1) | is.null(city.2)) {
    return(NULL)
  } else {
    df <- data.frame(type, row.1, row.2, stringsAsFactors = FALSE)
    colnames(df) <- c("type", city.1, city.2)
    return(df)
  }
}