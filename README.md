<style>
	body {
		color: #333;
		font-family: "Times", sans-serif;
		font-size: 12pt;
	}
	h1 {
		font-size: 18pt;
	}
	h2 {
		font-size: 16pt;
	}
	a {
		text-decoration: none;
		color: rgb(28, 164, 252);
	}
	p {
		text-indent: 2em;
	}
	ul > li {
		font-family: "Roboto", serif;
	}
	ul {
		list-style-type: none;
	}
	.right {
		margin-top: 50px;
		text-align: right;
	}
	.right, .it {
		font-style: italic;
	}
</style>

<body>

<h1>INFO 201 PROJECT PROPOSAL</h1>

<ul>
<li>Benyamin Boujari</li>
<li>Bogdan Tudos</li>
<li>Kevin Nguyen</li>
<li>Sunny Mishara</li>
<li>Zetian Chan</li>
</ul>

<h2>Project Github URL</h2>

<a>https://github.com/itskevinwin/INFO-201-Project</a>

<h2>Project Description</h2>

<h3>Summary</h3>

<p>
We plan to use <span class="it">Current Weather API</span> provided by <a href="http://openweathermap.org/">OpenWeatherApp.org</a> to find weather information of different locations. This API allows us to work with either small or large scale areas of interest by offering multiple types of data from each area. Our final goal is to make an interactive website using Shiny that allows users to check the weather of a specific location or area of their choice.
</p>

<h3>Dataset Background</h3>

<p>
<a href="http://openweathermap.org/">OpenWeatherApp.org</a> has created an API that tracks the current weather of 200,000 cities based on 40,000 weather stations. The data of API are updated every 3 hours so that the information is always up-to-date. <span class="it">Current Weather API</span> also allows for tracking the weather of cities by name, ZIP code, and coordinates, etc. The returned weather information is multi-dimensional, which covers data about temperature, humidity, pressure, wind, rain, clouds, snow, sunrise and sunset times.
</p>

<h3>Target Audience</h3>

<ol>
<li>
People interested in the weather of a specific location (e.g. Seattle)
</li>
<li>
Weather analysts interested in analyzing weather over a large region (e.g., U.S.)
For example, a weather analyst may select the weather of the whole California. Since California is a large state and different cities within CA may different weather conditions at a time, the analyst may analyze what caused the variations in weather conditions. For example, he/she may relates the weather of a city to its geographical conditions, etc.
</li>
<li>Logistics companies caring about the weather over a specific ZIP code area for dispatching reasons</li>
</ol>

<h3>Questions Of Interest</h3>
<ol>
<li>
Which cities have the most rain volumes in the past 3 hours?
</li>
<li>
Which cities are currently the coldest/hottest?
</li>
<li>
Which cities are currently the most/least humid?
</li>
<li>
What are the current average temperatures of some cities?
</li>
<li>
What is the average wind speed/direction in a specific city?
</li>
<li>
Are there any cities that begins to snow yet?
</li>
<li>
Of what time does the sun start rises/sets in a specific city?
</li>
</ol>

<h2>Technical Description</h2>

<h3>Final Project Format</h3>

<p>
Our final project would be an interactive Shiny Application based on shiny library, which allows for more flexibility in terms of data visualization.
</p>

<h3>Read In Data</h3>

We send GET requests and get weather data from a weather API, which is updated every 3 hours.


<h3>Data-wrangling</h3>

In order to make it easy for specific plots or tables to use, data wrangling will consist of selecting and filtering all data sent back from the API. In addition, mutations may be used to create new columns. Since the data pulled from the API are of a variety of types(temperature, humidity, rain, snow, etc.), we need to put the data into data frames after properly re-formatting them.


<h3>Major Libraries</h3>
<ul>
<li>shiny</li>
<li>ggplot2</li>
<li>plotly</li>
<li>httr</li>
<li>jsonlite</li> </ul>

<h3>Technical Obstacles</h3>

<ol>
<li>
Formatting plots and getting interactive features to work properly (specifically when using plotly)
</li>
<li>
Learning how to use the API, and what commands are available
</li>
<li>
Pulling the data out and putting them into data frames
</li>
<li>
Implementing code into shiny and getting interactive features to work properly
</li>
</ol>


<p class="right">
Formatter: Zetian Chen<br/>
Date:  2017-11-17
</p>
</body>
