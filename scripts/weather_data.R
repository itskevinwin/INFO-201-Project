library(jsonlite)
library(dplyr)
library(httr)

source('scripts/api_key.R')

main.cities <- read.csv('data/main_cities.csv')

urlFunction <- function(city){
  base.url <- 'http://api.openweathermap.org/data/2.5/weather?q='
  full.url <- paste0(base.url, city)
  query.params <- list(APPID = weather.key)
  response <- GET(full.url, query = query.params)
  results <- content(response, "text") %>% fromJSON(body)
  results <- data.frame(results)
  return(results)
}

city.data <- data.frame()
all.cities <- urlFunction(main.cities[1,])
for(x in 2:50){
  city.data <- urlFunction(main.cities[x,])
  if(ncol(city.data) == ncol(all.cities)){
    all.cities <- rbind(all.cities, city.data)
  }else{
    all.cities <- full_join(all.cities, city.data)
  }
}

cities.data <- subset(all.cities,select = c('coord.lon', 'coord.lat', 'weather.main', 'weather.description', 'main.temp', 'main.pressure', 'main.humidity',
                           'main.temp_min', 'main.temp_max', 'visibility', 'wind.speed', 'wind.deg', 'all', 'dt', 'sys.sunrise',
                           'sys.sunset', 'name'))
