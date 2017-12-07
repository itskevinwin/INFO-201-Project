# File weather_data.R

library(jsonlite)
library(dplyr)
library(httr)

# Source api key
source('./api_key.R')

source('./documentation.R')

# Read in main_cities.csv file
main.cities <- read.csv(
  './data/main_cities.csv',
  stringsAsFactors = FALSE
) %>% .[['main.cities']]

len <- length(main.cities)

# Takes in a string as a parameter and returns the  
# date in the proper format
AdjustTime <- function(str) {
  date <- as.POSIXct(str, origin="1970-01-01", tz="GMT") 
  return(strftime(date, format="%H:%M:%S"))
}

# Converts the temperature from kelvin to fahrenheit
ConvertTemp <- function(tmp) {
  return(1.8 * (tmp - 273) + 32)
}

# Converts the temperature from celsiu to fahrenheit
ConvertTempFromCelsius <- function(tmp) {
  return(1.8 * tmp + 32)
}

# Creates a data frame for the biggest fifty cities in
# the United States, including multiple columns showing
# current weather conditions
CreateMainCitiesDF <- function(cities) {
  cities.df <- GetCityInfo(q = cities[1])
  for (i in 2:len) {
    city = cities[i]
    cities.df <- rbind(cities.df, GetCityInfo(q = city))
  }
  return(cbind(cities, cities.df))
}

# Makes a GET request to the API and returns a
# parsed object
FetchResponse <- function(full.uri, params) {
  return(
    GET(full.uri, query = params) %>% content('text') %>% fromJSON()
  )
}

# Turns any NULL values in the data frame to "Unknown"
FetchValue <- function(val) {
  return(ifelse(is.null(val), "Unknown", val))
}

# Uses the FetchResponse and ProcessResponse functions to create a 
# data frame using the URL of the weather API. Contains multiple parameters
# and users can use any one of the parameters to find the desires location.
GetCityInfo <- function(q = NULL, lat = NULL, lon = NULL, zip = NULL) {
  base.uri <- "http://api.openweathermap.org/data/2.5/weather?"
  query.params <- list(APPID = weather.key)
  response <- NULL
  if (is.null(q) & (is.null(lat) | is.null(lon)) & is.null(zip)) {
    return("Invalid query parameters")
  } else {
    if (!is.null(q)) {
      response <- FetchResponse(paste0(base.uri, "q=", q), query.params)
    } else if (!is.null(lon) & !is.null(lat)) {
      response <- FetchResponse(
        paste0(base.uri, "lat=", lat, "&lon=", lon),
        query.params
      )
    } else if (!is.null(zip)) {
      response <- FetchResponse(paste0(base.uri, "zip=", zip), query.params)
    }
    if (response$cod == "404" | response$cod == "400") {
      return(NULL)
    } else {
      return(ProcessResponse(response))
    }
  }
}


# Takes in a JSON response and returns a data frame
ProcessResponse <- function(response) {
  return(data.frame(
    city = FetchValue(response$name),
    lon = FetchValue(response$coord$lon),
    lat = FetchValue(response$coor$lat),
    weather = FetchValue(response$weather$main[1]),
    description = FetchValue(response$weather$description[1]),
    temp = FetchValue(ConvertTemp(response$main$temp)),
    temp.min = FetchValue(ConvertTemp(response$main$temp_min)),
    temp.max = FetchValue(ConvertTemp(response$main$temp_max)),
    pressure = FetchValue(response$main$pressure),
    humidity = FetchValue(response$main$humidity),
    visibility = FetchValue(response$visibility),
    wind.speed = FetchValue(response$wind$speed),
    wind.degree = FetchValue(response$wind$deg),
    rain = FetchValue(response$rain$rain.3h),
    snow = FetchValue(response$snow$snow.3h),
    cloudiness = FetchValue(response$clouds$all),
    time = AdjustTime(response$dt),
    country = FetchValue(response$sys$country),
    sunrise = AdjustTime(response$sys$sunrise),
    sunset = AdjustTime(response$sys$sunset),
    stringsAsFactors = FALSE
  ))
}

# Returns a data frame of the relevent information for the two inputed locations
# that is used in the server to make the plots while comparing those cities. 
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
  return(data.frame(cities, attr, stringsAsFactors = FALSE))
}

# Returns a data frame of the relevent information for the two inputed locations
# that is used in the server to make the plots while comparing those cities. 
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
  df <- data.frame(type, row.1, row.2, stringsAsFactors = FALSE)
  colnames(df) <- c("type", city.1, city.2)
  return(df)
}

# Uses the API request function to return a list of the weather attributes for a 
# particular location.
FetchRowCity <- function(q = NULL, lat = NULL, lon = NULL, zip = NULL, cols) {
  row <- GetCityInfo(q = q, lat = lat, lon = lon, zip = zip)
  city <- row$city
  row <- SelectCols(row, cols) %>% unlist(use.names = FALSE)
  return(list(row = row, city = city))
}

# Takes in the data frame and a vector of column names as parameters 
# and returns a final data frame created by adding the column names to
# the data frame
SelectCols <- function(data, cols) {
  df <- data[cols[1]]
  len <- length(cols)
  if (len > 1) {
    for (i in 2:len) {
      df <- cbind(df, data[cols[i]])
    }
  }
  return(df)
}

# Uses the latitude and longitude inputted by the user in order to 
# make a GET request to the API. Returns NULL if the latitude/longitude
# entered is invalid.
GetRegionInfo <- function(lat = NULL, lon = NULL) {
  base.url <- 'http://api.openweathermap.org/data/2.5/box/city?'
  range <- 3
  count <- 8
  resource <- paste0(
    'bbox=',
    lon - range,
    ",",
    lat - range,
    ",",
    lon + range,
    ",",
    lat + range,
    ",8"
  )
  endpoint <- paste0(base.url, resource)
  query.params <- list(APPID = weather.key)
  response <- FetchResponse(endpoint, query.params) %>% .[['list']]
  if (is.null(response)) {
    return(NULL)
  } else {
    return(data.frame(
      city = response$name,
      temp = ConvertTempFromCelsius(response$main$temp),
      min.temp = ConvertTempFromCelsius(response$main$temp_min),
      max.temp = ConvertTempFromCelsius(response$main$temp_max),
      humidity = response$main$humidity,
      wind.speed = response$wind$speed
    ))
  }
}

# Uses the CreateMaiCitiesDF function to create a data frame
# Creates a list to check if the value is actually equal to the 
# desired value
main.cities.data <- CreateMainCitiesDF(main.cities)
main.cities.list <- list()
for (i in 1:len) {
  name <- main.cities[i]
  main.cities.list[name] = name
}
