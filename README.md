# INFO 201 PROJECT PROPOSAL

Bogdan Tudos<br>
Kevin Nguyen<br>
Zetian Chan<br>
Sunny Mishara<br>
Benyamin Boujari

## Project Description

### Summary

We plan to use Current Weather API provided by OpenWeatherApp.org to find weather information of different locations. This API allows us to work with either small or large scale areas of interest by offering multiple types of data from each area. Our final goal is to make an interactive website using Shiny that allows users to check the weather of a specific location or area of their choice.

### Dataset Background

OpenWeatherApp.org has created an API that tracks the current weather of 200,000 cities based on 40,000 weather stations. The data of API are updated every 3 hours so that the information is always up-to-date. Current Weather API also allows for tracking the weather of cities by name, ZIP code, and coordinates, etc. The returned weather information is multi-dimensional, which covers data about temperature, humidity, pressure, wind, rain, clouds, snow, sunrise and sunset times.


### Target Audience

1.	People interested in the weather of a specific location (e.g. Seattle)
2.	Weather analysts interested in analyzing weather over a large region (e.g., U.S.) For example, a weather analyst may select the weather of the whole California. Since California is a large state and different cities within CA may different weather conditions at a time, the analyst may analyze what caused the variations in weather conditions. For example, he/she may relates the weather of a city to its geographical conditions, etc.
3.	Logistics companies caring about the weather over a specific ZIP code area for dispatching reasons

### Questions Of Interest
1.	Which cities have the most rain volumes in the past 3 hours?
2.	Which cities are currently the coldest/hottest?
3.	Which cities are currently the most/least humid?
4.	What are the current average temperatures of some cities?
5.	What is the average wind speed/direction in a specific city?
6.	Are there any cities that begins to snow yet?
7.	Of what time does the sun start rises/sets in a specific city?

## Technical Description

### Final Project Format

Our final project would be an interactive Shiny Application based on shiny library, which allows for more flexibility in terms of data visualization.

### Read In Data

We send GET requests and get weather data from a weather API, which is updated every 3 hours.

### Data-wrangling

In order to make it easy for specific plots or tables to use, data wrangling will consist of selecting and filtering all data sent back from the API. In addition, mutations may be used to create new columns. Since the data pulled from the API are of a variety of types(temperature, humidity, rain, snow, etc.), we need to put the data into data frames after properly re-formatting them.

### Major Libraries

- shiny
- ggplot2
- plotly
- httr
- jsonlite 

### Technical Obstacles
-	Formatting plots and getting interactive features to work properly (specifically when using plotly)
-	Learning how to use the API, and what commands are available
-	Pulling the data out and putting them into data frames
-	Implementing code into shiny and getting interactive features to work properly
