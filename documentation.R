content <- "
<style>
li {
font-family: 'Times', sans-serif;
padding-top: 10px;
padding-bottom: 10px;
}
</style>
<h3>Table Of Contents</h3>
<ol>
  <li>Introduction</li>
  <li>Interactive Map Of Top 50 Cities In U.S.</li>
  <li>Comparison of Two Cities</li>
  <li>Cities Within A Rectangular Zone</li>
  <li>About</li>
</ol>
"

documentation <- "
<link href='https://fonts.googleapis.com/css?family=Abril+Fatface|Lora|Playfair+Display' rel='stylesheet'>
<link href='https://fonts.googleapis.com/icon?family=Material+Icons' rel='stylesheet'>

<style>
@font-face {
font-family: 'Material Icons';
font-style: normal;
font-weight: 400;
src: url(https://example.com/MaterialIcons-Regular.eot); /* For IE6-8 */
src: local('Material Icons'),
local('MaterialIcons-Regular'),
url(https://example.com/MaterialIcons-Regular.woff2) format('woff2'),
url(https://example.com/MaterialIcons-Regular.woff) format('woff'),
url(https://example.com/MaterialIcons-Regular.ttf) format('truetype');
}

.material-icons {
font-family: 'Material Icons';
font-weight: normal;
font-style: normal;
font-size: 24px;  /* Preferred icon size */
display: inline-block;
line-height: 1;
text-transform: none;
letter-spacing: normal;
word-wrap: normal;
white-space: nowrap;
direction: ltr;

/* Support for all WebKit browsers. */
-webkit-font-smoothing: antialiased;
/* Support for Safari and Chrome. */
text-rendering: optimizeLegibility;

/* Support for Firefox. */
-moz-osx-font-smoothing: grayscale;

/* Support for IE. */
font-feature-settings: 'liga';
}

/* Rules for sizing the icon. */
.material-icons.md-18 { font-size: 18px; }
.material-icons.md-24 { font-size: 24px; }
.material-icons.md-36 { font-size: 36px; }
.material-icons.md-48 { font-size: 48px; }

/* Rules for using icons as black on a light background. */
.material-icons.md-dark { color: rgba(0, 0, 0, 0.54); }
.material-icons.md-dark.md-inactive { color: rgba(0, 0, 0, 0.26); }

/* Rules for using icons as white on a dark background. */
.material-icons.md-light { color: rgba(255, 255, 255, 1); }
.material-icons.md-light.md-inactive { color: rgba(255, 255, 255, 0.3); }

h1 {
font-family: 'Abril Fatface', cursive;
}

h2, h3 {
font-family: 'Playfair Display', serif;
}

p, li {
text-indent: 1em;
font-family: 'Lora', serif;
}
</style>

<h1>
Current Weather  App of Cities Worldwide
</h1>

<h2>
<i class='material-icons'>question_answer</i>Introduction
</h2>

<p>
The <b>purpose</b> of our weather application is to achieve a <u>highly 
functional and easy to use platform</u> that can check and compare the 
weather of multiple cities around the world!
</p>

<p>
Our <b>target audience</b> are people who want to know about the current 
weather. The application would enable them to check the weather of any city 
in the world! A real world case would be that, before deciding which of the 
two locations to go for vacation, the family can use our application to 
compare the weather of these two locations to make better decisions.
</p>

<h2>
<i class='material-icons'>language</i>
Interactive Map Of Top 50 Cities In U.S.
</h2>

<p>
Using API <a href='https://openweathermap.org/current'>OpenWeatherApp</a>, 
the interactive map is updated with current weather data every <b>3 hours</b>. 
After processing the information sent back from the API, the map can display 
the key weather information for each of the 50 cities.
</p>

<p>
The map is first presented in a <u>zoomed-out</u> view with colored dots, 
whose colors indicate the number of cities in the corresponding regions. 
For example, orange indicates that there are many cities gathered in a 
specific regions. Zooming-in allows for more accurate color representations 
of the weather in specific cities. The <b>colors</b> on the map represent the 
current weather in the area:
</p>

<ul>
<li><b>Blue</b> represents <u>rain</u></li>
<li><b>Cyan</b> represents <u>a slight drizzle</u></li>
<li><b>Green</b> represents <u>clear skies</u></li>
<li><b>Purple</b> represents <u>a cloudy sky</u></li>
<li><b>Orange</b> represents <u>smokey skies</u></li>
<li><b>Grey</b> represents <u>mist</u></li>
<li><b>White</b> represents <u>snow</u></li>
<li><b>Black</b> represents <u>a thunder storm</u></li>
</ul>

<p>
Hovering over the map, you may <u>choose</u> a dot over a particular area of 
interest and click the dot to <u>zoom in</u> for a closer view of the cities 
within the area. Once you have found a city of interest, click on it and you 
will see a <u>pop up</u> display of the city's current weather information.
</p>

<p>
The information displayed will tell you about the city's:
</p>

<ul>
<li>Name</li>
<li>Weather Status</li>
<li>Description of the Weather</li>
<li>Minimum Temperature for the Day <u>(degrees Fahrenheit)</u></li>
<li>Current Temperature <u>(degrees Fahrenheit)</u></li>
<li>Maximum Temperature for the Day <u>(degrees Fahrenheit)</u></li>
<li>Humidity Percentage</li>
<li>Cloudiness Percentage</li>
<li>Wind Speed <u>(meters per second)</u></li>
<li>Pressure <u>(hPa)</u></li>
<li>Time of Sunrise</li>
<li>Time of Sunset</li>
<li>Time of <b>Last Update</b></li>
</ul>

<p>
Using this map, you can find out current <u>weather updates</u> in a 
particular city. For example, the <u>humidity</u> in the area as well as 
the <u>sunrise or sunset</u> of the city (which you may be visiting soon), 
and the <u>temperature range</u> throughout the day.
</p>

<h2>
<i class='material-icons'>swap_vert</i>
Comparison of Two Cities
</h2>

<p>
This tab allows you to find <b>two cities</b> in the world and compare their 
<b>quantitative</b> weather data. After choosing two cities and one of the 
three available methods, a descriptive <b>paragraph</b> comparing the weather 
information of the two cities will appear.
</p>

<p>
There are <b>5 comparison bar charts</b> including:
</p>

<ol>
<li>Current, Low, and High Temperatures</li>
<li>Air Pressure</li>
<li>Percentage of Cloudiness and Humidity</li>
<li>Visibility</li>
<li>Wind Speed</li>
</ol>

<p>
As to selecting cities, you are able to select by <b>city name</b>, 
<b>coordinates</b> or <b>zip code</b>. Based on the chosen input, the 
paragraph, as well as the charts, will dynamically change to match the 
given city or region.
</p>

<h2>
<i class='material-icons'>landscape</i>
Cities Within A Rectangular Zone
</h2>

<p>
Finally, our last tab allows the user to enter the <b>longitude</b> and 
<b>latitude</b> of a location in addition to selecting 
<b>one weather attribute</b>. The specified longitude and latitude would 
find the most prominent cities within, approximately, a radius of 200 miles. 
It does this by creating a box around the specified point, with each vertical 
side of the box representing the longitude and each horizontal side 
representing the latitude. The user then has an option to choose among three 
weather attributes (Temperature, Humidity, Wind Speed), by which the 
application creates a horizontal bar plot representing the latest 
measurements of the specified weather attribute for each city/town/area 
within the zone.
</p>

<p>
For Example, the entered <u>longitude and latitude is of Seattle</u> and 
the attribute chosen is <u>wind speed</u>. All towns/cities/areas 
<u>closest to Seattle</u> within the rectangular zone are chosen with regard 
to their current wind speeds. Then, a bar chart would show up whose y axis 
represents each location and x axis represents the corresponding measurement 
of the specified weather condition.
</p>

<h2>
<i class='material-icons'>comment</i>
About
</h2>

<h3>
Team Members
</h3>

<p>
Below are the team members for this application and their corresponding 
contributions:
</p>

<ul>
<li>
<b>Zetian Chen</b>:<br>
weather_data.R, panels of server.R and ui.R, html conversion and 
css styling of the documentation
</li>
<li><b>Kevin Nguyen</b>:<br>first tab of weather app</li>
<li><b>Sunny Mishara</b>:<br>second tab of weather app</li>
<li>
<b>Bogdan Tudos</b>:<br>
third tab of weather app, reorganizing the documentation
</li>
<li><b>Benyamin Boujar</b>:<br>draft of documentation</li>
</ul>

<p>
Thank all team members for their hard work!
</p>
"