# file weather_data.R

library(jsonlite)
library(dplyr)
library(httr)

# Source api key
source('./api_key.R')

# Read in main_cities.csv file
main.cities <- read.csv(
  '../data/main_cities.csv',
  stringsAsFactors = FALSE
) %>% .[['main.cities']]

len <- length(main.cities)

AdjustTime <- function(str) {
  date <- as.POSIXct(str, origin="1970-01-01", tz="GMT") 
  return(strftime(date, format="%H:%M:%S"))
}

ConvertTemp <- function(tmp) {
  return(1.8 * (tmp - 273) + 32)
}

CreateMainCitiesDF <- function(cities) {
  cities.df <- GetCityInfo(q = cities[1])
  for (i in 2:len) {
    city = cities[i]
    cities.df <- rbind(cities.df, GetCityInfo(q = city))
  }
  return(cbind(cities, cities.df))
}

FetchResponse <- function(full.uri, params) {
  return(
    GET(full.uri, query = params) %>% content('text') %>% fromJSON()
  )
}

FetchValue <- function(val) {
  return(ifelse(is.null(val), "Unknown", val))
}

GetCityInfo <- function(q = NULL, lat = NULL, lon = NULL, zip = NULL) {
  base.uri <- 'http://api.openweathermap.org/data/2.5/weather?'
  query.params <- list(APPID = weather.key)
  response <- NULL
  if (is.null(q) & (is.null(lat) | is.null(lon)) & is.null(zip)) {
    return('Invalid query parameters')
  } else {
    if (!is.null(q)) {
      response <- FetchResponse(paste0(base.uri, 'q=', q), query.params)
    } else if (!is.null(lon) & !is.null(lat)) {
      response <- FetchResponse(
        paste0(base.uri, 'lat=', lat, '&lon=', lon),
        query.params
      )
    } else if (!is.null(zip)) {
      response <- FetchResponse(
        paste0(base.uri, 'zip=', zip),
        query.params
      )
    }
    return(ProcessResponse(response))
  }
}

ProcessResponse <- function(response) {
  return(data.frame(
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
    sunset = AdjustTime(response$sys$sunset)
  ))
}

main.cities.data <- CreateMainCitiesDF(main.cities)
main.cities.list <- list()
for (i in 1:len) {
  name <- main.cities[i]
  main.cities.list[name] = name
}

