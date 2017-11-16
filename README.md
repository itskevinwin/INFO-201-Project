#Info 201 Project Proposal

By: Bogdan Tudos, Kevin Nguyen, Zetian Chan, Sunny Mishara, Benyamin Boujari

##Summary
We plan to use the Current Weather API provided by OpenWeatherApp.org to find information on the weather of different locations. This API would allow us to work with small scale or large scale areas of interest which lets us gather multiple different types of data from each area. The overall purpose is to make an interactive website using Shiny that allows users to check the weather within their location of choice.

##Project Description

**Background on dataset**
OpenWeatherApp.org has created an API that tracks the current weather of 200,000 cities based on 40,000 weather stations. The API is constantly updated so that the information is accurate every day. The Current Weather API also allows for tracking of weather cities by name, ZIP code, and coordinates. This API hasy many features for checking weather in an area including: the wind, rain, clouds, snow, temperature, humidity, pressure, sunrise, and sunset times.

**Target audience**
People interested in the weather of a specific city or location
Weather analysts interested in analyzing weather over a large region (e.g., U.S.).
Logistics companies caring about the weather over a specific ZIP code area for dispatching reasons.

**Questions we are interested in**
What cities have the most rain volume in the past 3 hours?
What cities are currently the coldest/hottest?
What are cities’ current average temperatures?
What are the average wind speeds/direction in each city?
Are there any cities starting to snow yet?
What time does the sun start rising/setting by city?
What cities are currently the most/least humid?

##Technical Description

**Final Project Format**
We’ll be using the shiny framework to create an interactive app as that gives us more flexibility in terms of data visualization.

**Reading in Data**
We send GET requests and get weather data from a weather API, which is updated every 3 hours.

**Data-wrangling**
Data wrangling will consist of selecting and filtering all of the API’s given data in order to make it easy to use for specific plots or tables. Mutations may be used to create new columns necessary for a plot or table. There are a lot of different types of data (temp, humidity, rain, snow, etc.) to be pulled from the API, re-formatted properly, and put into data frames.

**Needed Libraries**
1. ggplot2
2. plotly
3. shiny
4. httr
5. jsonlite
6. dplyr

**Technical Obstacles**
*Formatting plots and getting interactive features to work properly (specifically when using plotly)
*Learning how to use the API, and what commands are available 
*Pulling the data out and putting them into data frames
*Implementing code into shiny and getting interactive features to work properly
