library(jsonlite)
library(dplyr)
library(httr)

source('api_key.R')

base.url <- 'api.openweathermap.org/data/2.5/weather'
response <-
query.params <- list(query=, api_key = weather.key)
response <- GET(base.url, query = query.params)
body <- content(response, "text")

results <- fromJSON(body)

flattened <- flatten(results$results)