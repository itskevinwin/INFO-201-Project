library(jsonlite)
library(dplyr)
library(httr)

source('api_key.R')

base.url <- 'http://api.openweathermap.org/data/2.5/weather?q=London'
query.params <- list(APPID = weather.key)
response <- GET(base.url, query = query.params)
results <- content(response, "text") %>% fromJSON(body)
