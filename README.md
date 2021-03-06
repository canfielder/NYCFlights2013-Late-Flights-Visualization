# NYCFlights13-Late-Flights-Visualization
An analysis of the NYCFligths13 Dataset visualizing late flights through a Shiny app.

![Screenshot](https://user-images.githubusercontent.com/38056064/55563972-e8279e00-56c4-11e9-8a17-87a40ae0093b.png)

This project was completed for the Spring 2019 session of UNC Charlotte’s DSBA 5122: Visual Analytics class. The project was a group project completed with Rommel Badilla and Chandra Reddy. Some small updates have been made since the project submittal.

## Data Inputs
In order to create the visualization the following data manipulations were performed on the NYCFlights13 dataset:
* Airports were restricted to being within the Continental US and being within the top 20 airports by total flights. This was done to simplify the output plots which showed late flights by destination. 
*	A late flight was defined as any flight arriving 15 minutes late or greater. This corresponds to FAAs definition of a Medium Delay. A binary column was created identifying if a flight qualified as late (1) or not (0). (https://en.wikipedia.org/wiki/Flight_cancellation_and_delay)
*	Canceled flights were flights in the dataset where a date, flight number, and scheduled departure and arrival times existed, but not actual departure and arrival times were recorded. Canceled flights were modeled as equivalent to a 4-hour delay.

## Potential Future Updates
* Calendar heat map: Update the format of the calendar heat map so each row is a day of the week making possible weekly patterns more apparent. 
* Canceled Flight Definition: Create a more dynamic definition of canceled flights. Currently all late flights are defined as a 4 hour delay. For days where there are few cancelations this feels reasonable, as travelers could most likely be rebooked onto other flights within 4 hours. For days where there are many cancellations, such as February 8th and 9th when there was a large snowstorm in NYC, there were no flights from 4PM February 8th until 11AM February 9th, a period of 19 hours. These two types of cancelations are not equivalent.
* Delayed Flights Definition: Create a more dynamic definition of delayed flights based on length of arrival delay.  FAA definitions for small, medium, and large delays could be used as thresholds and different weights could be applied to each classification
* User Defined Late Flight Threshold: Make the threshold for defining a late flight definable by the user via the app user interface. Perhaps input a slider into the app. This would probably reuqire reoirienting the main layout. I am currenlty not sure where a slider could go without disrupting the asthetic. 

## Deployed Project
https://evan-canfield.shinyapps.io/nycflights13_visualization/
