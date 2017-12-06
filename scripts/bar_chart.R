source("weather_data.R")
library("plotly")
library("dplyr")


GetCircleInfo <- function(lat, lon, cnt) {
  base.uri <- 'http://api.openweathermap.org/data/2.5/'
  resource <- paste0('find?lat=', lat, '&lon=', lon, '&cnt=', cnt)
  query.params <- list(APPID = weather.key)
  endpoint <- paste0(base.uri, resource)
  response <- FetchResponse(endpoint, query.params)
  return (ProcessResponse(response))
}

makePlot <- function(data){
  
  data.filterd <- filter(data,  )
  
  bar.plot <- plot_ly(data, x = ~program.exp, y = ~(Mac/Students), type = 'bar', name = 'Ratio of INFO 201 students who are Mac users') %>%
    add_trace(y = ~(Windows/Students), name = 'Ratio of INFO 201 students who are Windows users') %>%
    layout(title = 'Mac and Windows Users by Programming Experience in INFO 201', xaxis = list(title = 'Programming Experience'), yaxis = list(title = 'Ratio'), barmode = 'stack')
  ggplotly(bar.plot)
}

