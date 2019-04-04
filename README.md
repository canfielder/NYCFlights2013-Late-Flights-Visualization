# NYCFlights13-Late-Flights-Visualization
An analysis of the NYCFligths13 Dataset visualizing late flights through a Shiny app.

This project was completed for the Spring 2019 session of UNC Charlotte’s DSBA 5122: Visual Analytics class. The project was a group project completed with Rommel Badilla and Chandra Reddy. Some small updates have been made since the project submittal.

The Shiny app was designed to provide a visualization of late flights leaving the NYC airports (JFK, LaGuardia, and Newark). In order to create the visualization the following data manipulations were performed on the NYCFlights13 dataset
*	A late flight was defined as any flight arriving 15 minutes late or greater. This corresponds to FAAs definition of a Medium Delay. A binary column was created identifying if a flight qualified as late (1) or not (0). (https://en.wikipedia.org/wiki/Flight_cancellation_and_delay)
*	Canceled flights were flights in the dataset where a date, flight number, and scheduled departure and arrival times existed, but not actual departure and arrival times were recorded. Canceled flights were modeled as equivalent to a 4-hour delay.


# Potential Future Updates:
* I would like to update the format of the calendar heat map so each row is a day of the week making possible weekly patterns more apparent. 
* I would like to create a more dynamic definition of canceled flights. Currently all late flights are defined as a 4 hour delay. For days where there are few cancelations this feels reasonable, as travelers could most likely be rebooked onto other flights within 4 hours. For days where there are many cancellations, such as February 8th and 9th when there was a large snowstorm in NYC, there were no flights from 4PM February 8th until 11AM February 9th, a period of 19 hours. These two types of cancelations are not equivalent.
* I would like to create a more dynamic definition of delayed flights based on how late the flights are. I would probably use the FAA definitions for small, medium, and large delays and provide different weights to each classification

The project has been deployed here:
https://evan-canfield.shinyapps.io/Design_Contest/
