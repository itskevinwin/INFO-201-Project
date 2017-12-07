# server.R file 

# If the column of a specifc row is unknown, then strip that row from the data frame
StripUnknown <- function(data, col) {
  return(data[data[[col]] != 'Unknown',])
}

# Get the min and max of the differnt attribues used in the slider for the interactive
# map on tab 1
GetAttrRange <- function(col) {
  vtr <- main.cities.data %>% StripUnknown(col) %>% .[[col]] %>% as.numeric()
  return(list(
    min = vtr %>% min() %>% floor(),
    max = vtr %>% max() %>% ceiling()
  ))
}

# Get the current range of the temperature used for the interactive map
current <- GetAttrRange('temp')
warning.msg <- "No recorded weather data near specified coordinates."

# Creates Shiny Server to use with UI. Sets all outputs used in UI 
# to display to the user
shinyServer(function(input, output, clientData, session) {
  
  # Sets output text used for documentation
  output$text <- renderText({
    documentation
  })
  
  # Sets output content for the content table used in the documentation
  output$content <- renderText({
    content
  })
  
  # Creates slider that changes its range based on user choice of weather 
  # information they would like to see on the map
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
  
  # Create slider input that adjusts its values based on min and max of user 
  # chosen attribute
  updateSliderInput(
    session,
    "mainr",
    min = current$min,
    max = current$max,
    value = c(current$min, current$max)
  )
  
  #### User Input For Tab 2 (Comparison) ####
  
  # User input city one
  output[['cityf1']] <- renderUI({
    GetSimpleUI('text', 'cityf1', 'Enter 1st City', 'New York')
  })
  
  # User input city two
  output[['cityf2']] <- renderUI({
    GetSimpleUI('text', 'cityf2', 'Enter 2nd City', 'Seattle')
  })
  
  # User input latitude one
  output[['latf1']] <- renderUI({
    GetSimpleUI('numeric', 'latf1', 'Enter 1st Latitude', 47.6062)
  })
  
  # User input latitude two
  output[['latf2']] <- renderUI({
    GetSimpleUI('numeric', 'latf2', 'Enter 2nd Latitude', 34.0522)
  })
  
  # User input longitude one
  output[['lngf1']] <- renderUI({
    GetSimpleUI('numeric', 'lngf1', 'Enter 1st Longitude', -122.3321)
  })
  
  # User input longitude two
  output[['lngf2']] <- renderUI({
    GetSimpleUI('numeric', 'lngf2', 'Enter 2nd Longitude', -118.2437)
  })
  
  # User input zip code one
  output[['zipf1']] <- renderUI({
    GetSimpleUI('numeric', 'zipf1', 'Enter 1st ZIP Code', 98105)
  })
  
  # User input zip code two
  output[['zipf2']] <- renderUI({
    GetSimpleUI('numeric', 'zipf2', 'Enter 2nd ZIP Code', 10008)
  })
  
  # Set output for the interactive map displayed on tab 1
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
  # weather in user input locations
  output$report <- renderText({
    city.one <- NULL
    city.two <- NULL
    if (input$locate == 1) { # User inpt cities
      city.one <- GetCityInfo(q = input$cityf1)
      city.two <- GetCityInfo(q = input$cityf2)
    } else if (input$locate == 2) { # User input coordinates
      city.one <- GetCityInfo(lat = input$latf1, lon = input$lngf1)
      city.two <- GetCityInfo(lat = input$latf2, lon = input$lngf2)
    } else { # User input zip codes
      city.one <- GetCityInfo(zip = input$zipf1)
      city.two <- GetCityInfo(zip = input$zipf2)
    }
    
    # Use MakeReport function to create dynamically changing paragraph
    MakeReport(city.one, city.two) 
  })
  
  ##### Search by city: #####
  
  # Charts created with user input of two different (or the same) cities to compare
  # quantitative information
  
  # Temperature chart comparing two cities by current, min, and max temperature
  output$CityTempChart <- renderPlotly({
    
    # Use CreateMultiChartDF function to get a data frame of information
    # which is used to make a bar graph with peices of data to compare
    cities.data <- CreateMultiChartDF(
      q1 = input$cityf1,
      q2 = input$cityf2,
      type = c("Low", "Current", "High"),
      cols = c("temp.min", "temp", "temp.max")
    )
    
    # Use MakeMultiGraph function to create a bar graph comparing 
    # two cities by current temperature, minimum temperature, and maximum
    # temperature for the day
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
  
  # Pressure Chart comparing air pressure in two cities
  output$CityPressureChart <- renderPlotly({
    
    # Use CreateSinChart to create a data frame needed for a graph with one
    # piece of data to compare between two cities
    cities.data <- CreateSinChartDF(
      q1 = input$cityf1,
      q2 = input$cityf2,
      col = c("pressure")
    )
    
    # Use shiny validate to make sure that when errors are thrown, our own response 
    # will be generated to guide the user to fixing his input
    shiny::validate(
      need(!is.null(cities.data),
           warning.msg)
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
  
  # Humidity vs cloudiness chart comparing percentage of humidity and cloudiness in both cities
  output$CityCloudinessChart <- renderPlotly({
    cities.data <- CreateMultiChartDF(
      q1 = input$cityf1,
      q2 = input$cityf2,
      type = c("Humidity", "Cloudiness"),
      cols = c("humidity", "cloudiness")
    )
    shiny::validate(
      need(!is.null(cities.data),
           warning.msg)
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
  
  # Visibility Chart comparing the visibility in meters within two different cities 
  # (aka fog can make visibility worse for example)
  output$CityVisibilityChart <- renderPlotly({
    cities.data <- CreateSinChartDF(
      q1 = input$cityf1,
      q2 = input$cityf2,
      col = c("visibility")
    )
    shiny::validate(
      need(!is.null(cities.data),
           warning.msg)
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
  
  # Wind Speed Chart shows the wind speed in two cities in meters per second
  output$CityWindChart <- renderPlotly({
    cities.data <- CreateSinChartDF(
      q1 = input$cityf1,
      q2 = input$cityf2,
      col = c("wind.speed")
    )
    shiny::validate(
      need(!is.null(cities.data),
           warning.msg)
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
  
  #### Search by coordinates: ####
  
  # Same Charts as above, just using different user input. This time they are made by 
  # user input coordinates of longitude and latitude.
  
  # Temperature chart
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
           warning.msg)
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
           warning.msg)
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
           warning.msg)
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
           warning.msg)
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
           warning.msg)
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
  
  #### Search by Zip Code: ####
  
  # Create comparison charts by using user input of two differnt zip codes.
  
  # Temperature chart
  output$ZipTempChart <- renderPlotly({
    cities.data <- CreateMultiChartDF(
      zip1 = input$zipf1,
      zip2 = input$zipf2,
      type = c("Low", "Current", "High"),
      cols = c("temp.min", "temp", "temp.max")
    )
    shiny::validate(
      need(!is.null(cities.data),
           warning.msg)
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
           warning.msg)
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
           warning.msg)
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
           warning.msg)
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
           warning.msg)
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
  
  # Constantly checks if the user has selected the "Wind Speed"
  # option. Calls the API requst function in order to create the 
  # Temperature graph.
  output$temp <- renderPlotly({
    result.data <- GetRegionInfo(input$lat, input$lng)
    shiny::validate(
      need(!is.null(result.data), warning.msg)
    )
    MakeTempPlot(result.data)
  })
  
  # Constantly checks if the user has selected the "Humidity"
  # option. Calls the API requst function in order to create the 
  # humidity graph.
  output$humid <- renderPlotly({
    result.data <- GetRegionInfo(input$lat, input$lng)
    shiny::validate(
      need(!is.null(result.data), warning.msg)
    )
    MakeHumidPlot(result.data)
  })
  
  # Constantly checks if the user has selected the "Wind Speed"
  # option. Calls the API requst function in order to create the 
  # wind speed graph.
  output$wind <- renderPlotly({
    result.data <- GetRegionInfo(input$lat, input$lng)
    shiny::validate(
      need(!is.null(result.data), warning.msg)
    )
    MakeWindPlot(result.data)
  })
})

# Takes a column name and returns a normalized name and also adds the 
# corresponding unit to it. (Ex: "temp" becomes "Temperature (°F)")
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

# Capitalizes the first letter in a string
Cap <- function(str) {
  str <- str %>% gsub('[.]', ' ', .) %>% strsplit(' ') %>% .[[1]]
  paste(
    toupper(substring(str, 1, 1)),
    substring(str, 2),
    sep = "",
    collapse = " "
  )
}

# Sets the color of different weather types for use on map points
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

# Creates an interactive map to use for tab 1
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

# Simplifies the process of creating widgets in tab 2 (Comparison)
GetSimpleUI <- function(ui.name, obj.name, label, value) {
  if (ui.name == 'numeric') {
    return(numericInput(obj.name, label = label, value = value))
  } else {
    return(textInput(obj.name, label = label, value = value))
  }
}

# Takes a data frame containing the desired data and uses it to make
# a plot of the Temperature for each nearby area.
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

# Takes a data frame containing the desired data and uses it to make
# a plot of the Humidity for each nearby area.
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

# Takes a data frame containing the desired data and uses it to make
# a plot of the Wind Speed for each nearby area.
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

# Creates a summary comparison paragraph if inputs aren't NULL based
# on user inputs (cities, coordinates, zip codes)
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

# Makes a bar graph with a single point of comparison used to compare the
# two cities of interest
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

# Makes a bar graph with multiples points of comparison used to compare the
# two cities of interset
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

# Creates a data frame for use on a bar graph with a single point of comparison
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

# Creates a data frame for use on a bar graph with multiple points of comparison
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