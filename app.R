#title: "Design Contest - Late Flights out of New York City in 2013"

# Library Installations--------------------------  
#Installation Check
if (!require(tidyverse)) {install.packages('tidyverse')}
if (!require(nycflights13)) {install.packages('nycflights13')}
if (!require(lubridate)) {install.packages('lubridate')}
if (!require(shiny)) {  install.packages('shiny')}
if (!require(shinythemes)) {install.packages('shinythemes')}

#Library Install
library(nycflights13)
library(tidyverse)
library(lubridate)
library(plotly)
library(shiny)
library(shinythemes)

#Design Input Development -----------------------
#Develop List of Major Airports in Continental US
airport_list <- flights %>% 
  left_join(y = airports, by = c("dest" = "faa")) %>% 
  filter(
    lon >= -126,
    lon <= -66,
    lat >= 24,
    lat <= 50
  ) %>% 
  group_by(dest) %>% 
  summarise(number_of_flights = n()) %>% 
  arrange(desc(number_of_flights)) %>% 
  top_n(20)

#Filter Flights by Major Airport List
flights_major <- flights %>% 
  semi_join(airport_list)

#Convert flight destination to ranked by total flights
flights_major <-  flights_major %>% 
  mutate(dest = as.character(dest)) %>% 
  mutate(dest = factor(x = flights_major$dest, levels = rev(airport_list$dest)))

#Incorporate Canceled Flights by Replacing NA Arrival Delays with 4 Hours 
flights_major <- flights_major %>% 
  mutate(arr_delay = replace(arr_delay, is.na(arr_delay), 4*60))

#Create binary column defining late flights. Also calculate a column for the date.
#Set threshold for late flights to 15 minutes (FAA Medium Delay threshold).
#Consider making reactive user input in future iterations.
late_threshold <- 15   

flights_major <- flights_major %>% 
  mutate(late = if_else(arr_delay >= late_threshold, 1, 0)) %>% 
  mutate(date = date(time_hour))

#Calculate the average delay and percent late of flights per day, total
flights_major_total <- flights_major %>% 
  group_by(date) %>% 
  summarise(
    number_of_flights = n(), 
    number_of_flights_late = sum(late, na.rm = T),
    av_delay = round(mean(arr_delay, na.rm = T), digits = 1)
  ) %>% 
  mutate(percent_late = round(number_of_flights_late/number_of_flights, digits = 4)*100) %>% 
  arrange(desc(percent_late))

#Merge Airport Data-set with the Flight Data-set
flights_major$dest <- as.character(flights_major$dest)

flights_major <- flights_major %>% 
  left_join(y = airports, by = c("dest" = "faa")) %>% 
  rename(name.airport = name)

#Develop Flight Data-set Based On Origin Airport 
flights_major_per_airport <- flights_major %>% 
  group_by(date, dest) %>% 
  summarize(
    number_of_flights = n(),
    number_of_flights_late = sum(late, na.rm = T),
    av_delay = round(mean(arr_delay, na.rm = T), digits = 1)
  ) %>% 
  mutate(percent_late = round(number_of_flights_late/number_of_flights, digits = 2)*100) %>% 
  arrange(date) %>% 
  left_join(y = airports, by = c("dest" = "faa"))

#Develop Flight Data-set Based on Daily Totals. 
#Possible use for faceting heat map by month
first_day_of_month_wday <- function(dx) {
  day(dx) <- 1
  wday(dx)
}

flights_major_total <- flights_major %>% 
  group_by(date) %>% 
  summarise(
    number_of_flights = n(), 
    number_of_flights_late = sum(late, na.rm = T),
    av_delay = round(mean(dep_delay, na.rm = T), digits = 1)
  ) %>% 
  mutate(percent_late = round(number_of_flights_late/number_of_flights, digits = 2)*100) %>% 
  arrange(desc(percent_late)) %>% 
  mutate(wk = ceiling((day(date) + first_day_of_month_wday(date) - 1) / 7))

#Develop Weather Data-set in order to plot hourly weather patterns
#Remove Wind speeds greater than 1,000 mph. This only affects a reading at Newark (EWR) on February 12, 2013 at 3:00AM.
weather_update <- weather %>%
  filter(wind_speed < 1000) %>% 
  na.omit()

single_weather_hourly <- weather_update %>%
  group_by(time_hour) %>% 
  summarise(
    av_temp = round(mean(temp, na.rm = T), digits = 1),
    av_dewp = round(mean(dewp, na.rm = T), digits = 1),
    av_humid = round(mean(humid, na.rm = T), digits = 1),
    av_wind_dir = round(mean(wind_dir, na.rm = T), digits = 1),
    av_wind_speed = round(mean(wind_speed, na.rm = T), digits = 1),
    av_precip = round(mean(precip, na.rm = T), digits = 4),
    av_pressure = round(mean(pressure, na.rm = T), digits = 1),
    av_visib = round(mean(visib, na.rm = T), digits = 1)
  ) %>% 
  mutate(date = date(time_hour)) %>% 
  mutate(hour = hour(time_hour))

#Shiny  Visualization ---------------------------
#Plot Axis and Other List Definitions
{
  #HeatMap Axis
  x_heat <- list(
    title = "Day",
    autotick = FALSE,
    ticks = "outside",
    tick0 = 0,
    dtick = 5
  )
  
  y_heat <- list(
    title = ""
  )
  
  #Line.Hour Graph Axis
  x_line.hour <- list(
    title = "Hour",
    dtick = 1,
    range = c(4, 23)
  )
  
  y_line.hour <- list(
    title = "Number of Flights",
    dtick = 5,
    range = c(0,55)
  )
  
  #Bar Graph Axis - By Desitnation
  x_bar_dest <- list(
    title = "Percent of Flights Late",
    dtick = 5,
    range = c(0,100)
  )
  
  y_bar_dest <- list(
    title = "Destination Airport",
    type = "category",
    autorange = "reversed"
  )
  
  #Bar Graph Axis - By Carrier
  x_bar_carrier <- list(
    title = "Percent of Flights Late",
    dtick = 5,
    range = c(0,100)
  )
  
  y_bar_carrier <- list(
    title = "Carrier",
    type = "category",
    autorange = "reversed"
  ) 
  #Line.Wind Graph Axis
  x_line.weather <- list(
    title = "Hour",
    dtick = 4,
    range = c(0,23)
  )
  
  y_line.windspeed <- list(
    title = "Wind Speed (mph)",
    dtick = 5,
    range = c(0,40)
  )
  
  #Line.Precipitation Graph Axis
  y_line.precip <- list(
    title = "Precipitation (in)",
    dtick = 0.05,
    range = c(0,0.6)
  )
  
  #Line.Visibility Graph Axis
  y_line.visib <- list(
    title = "Visibility (miles)",
    dtick = 1,
    range = c(0,15)
  )
  
  #Boxplot Graph Axis
  
  y_boxplot.hour <- list(
    title = "Average Delay (min)",
    dtick = 50,
    range = c(-100,400)
  )
  weather_title_font <- list(
    size = 10) 
}

#24 Hour Profile - Zeros. Used to create a full 24 hour profile of late flights for line graph
hour_profile = data.frame("hour" = seq(0,23,1), "count" = rep(0,24))

ui <- fluidPage(
  theme = shinytheme("journal"),
  titlePanel("Late Flights out of New York City in 2013"),
  mainPanel(
    plotlyOutput("heat"),
    uiOutput("date"),
    tabsetPanel( 
      tabPanel("Arrival Delay", plotlyOutput("boxplot.hour")),
      tabPanel(paste("Late Flights"), plotlyOutput("line.hour")),
      tabPanel("Delay by Destination", plotlyOutput("bar_dest")),
      tabPanel("Delay by Carrier", plotlyOutput("bar_carrier")),
      tabPanel("Weather",
               shiny::fluidRow(
                 column(3,plotlyOutput("line.windspeed.av")),
                 column(3,plotlyOutput("line.precip.av")),
                 column(3,plotlyOutput("line.visib.av"))
               )
      )
    )
  )
)

server <- function(input, output) {
  
  #Date Input
  event_date <- reactive({
    s <- event_data("plotly_click", source = "heatplot")
    ymd(paste(2013, match(s$y, month.abb), s$x, sep="-"))
  })
  
  
  #Plots  
  output$heat <- renderPlotly({
    plot_ly(data = flights_major_total, 
            type = "heatmap",
            source = "heatplot",
            x = ~day(date), 
            y = ~month(date, label = TRUE, abbr = TRUE),
            z = ~percent_late,
            xgap = 2.5,
            ygap = 2.5,
            colors = "RdBu",
            reversescale = T,
            colorbar = list(title = "Percent<br>Late"),
            hoverlabel = list(bgcolor = "#F7F9F9"),
            hoverinfo = "text", 
            text = ~paste(month(x = flights_major_total$date, label = TRUE, abbr = FALSE), 
                          day(date), ", ", year(date), "<br>", "Average Delay: ", 
                          round(av_delay, digits = 0), "minutes")
    ) %>% 
      layout(xaxis = x_heat, yaxis = y_heat)
  })
  
  output$date <- renderUI({
    filter_date <- event_date()
    
    if (is.na(filter_date)) {
      strong(paste("Click on the calendar heat map to see information for that day."))
    } else {
      strong(paste("Date: ", month(filter_date, label = TRUE, abbr = FALSE)," ", day(filter_date), ", ", year(filter_date)))
    }
  })
  
  output$line.hour <- renderPlotly({
    filter_date <- event_date()
    
    #Line/Area Graph of Hourly Delays
    plot_ly(flights_major %>% 
              filter(date == filter_date , late == 1) %>% 
              group_by(hour = hour(time_hour)) %>% 
              summarize(number_late = n()) %>% 
              right_join(y = hour_profile, by = c("hour" = "hour")) %>% 
              mutate(number_late = replace_na(number_late,0)) %>% 
              select(-count),
            x = ~hour,
            y = ~number_late, 
            type = "scatter",
            mode = "lines",
            fill = 'tozeroy',
            hoverinfo = "text",
            text = ~paste("Late Flights: ", number_late, "<br>", format((as.POSIXct(as.character(hour), format = "%H")), "%r"))
    ) %>% 
      layout(title = "Late Flights By Hour", xaxis = x_line.hour, yaxis = y_line.hour)
  })
  
  output$bar_dest <- renderPlotly({
    filter_date  <- event_date()
    
    #Bar Graph By Destination Plot
    plot_ly(flights_major_per_airport %>%
              rename(name.airport = name) %>% 
              filter(date == filter_date),
            x = ~percent_late,
            y = ~dest,
            colors = "RdBu",
            type = "bar",
            hoverinfo = "text",
            text = ~paste(name.airport, "<br>",percent_late,"% Late"),
            marker = list(
              color = 'rgba(73,144,194,0.5)',
              line = list(
                color = 'rgb(73,144,194)',
                width = 2))
    ) %>% 
      layout(title = "Percent Late Flight By Destination", xaxis = x_bar_dest, yaxis = y_bar_dest)
  })
  
  output$bar_carrier <- renderPlotly({
    filter_date <- event_date()
    
    #Bar Graph By Carrier Plot
    plot_ly(flights_major %>% 
              group_by(date, carrier) %>% 
              summarise(
                number_of_flights = n(), 
                number_of_flights_late = sum(late, na.rm = T),
                av_delay = round(mean(dep_delay, na.rm = T), digits = 1)
              ) %>% 
              mutate(percent_late = round(number_of_flights_late/number_of_flights, digits = 2)*100) %>% 
              arrange(desc(percent_late)) %>% 
              left_join(y = airlines, by = c("carrier" = "carrier")) %>% 
              rename(name.carrier = name) %>% 
              filter(date == event_date()),
            x = ~percent_late,
            y = ~carrier,
            type = "bar",
            hoverinfo = "text",
            text = ~paste(name.carrier, "<br>",percent_late,"% Late"),
            marker = list(
              color = 'rgba(73,144,194,0.5)',
              line = list(
                color = 'rgb(73,144,194)',
                width = 2))
    ) %>% 
      layout(title = "Percent Late Flight By Carrier", xaxis = x_bar_carrier, yaxis = y_bar_carrier)
  })
  output$line.windspeed.av <- renderPlotly({
    filter_date <- event_date()
    
    #Line Graph of Wind Speed
    plot_ly(single_weather_hourly %>% 
              filter(date == filter_date) %>% 
              select(hour,av_wind_speed) %>% 
              right_join(y = hour_profile, by = c("hour" = "hour")) %>% 
              mutate(av_wind_speed = replace_na(av_wind_speed,0)) %>% 
              select(-count),
            x = ~hour,
            y = ~av_wind_speed, 
            type = "scatter",
            mode = "lines+markers"
    ) %>% 
      layout(title = "Average Wind Speed By Hour", xaxis =  x_line.weather, yaxis = y_line.windspeed, font = weather_title_font)  
  })
  
  output$line.precip.av <- renderPlotly({
    filter_date <- event_date()
    
    #Line Graph of Precipitation
    plot_ly(single_weather_hourly %>% 
              filter(date == filter_date) %>% 
              select(hour, av_precip) %>% 
              right_join(y = hour_profile, by = c("hour" = "hour")) %>% 
              mutate(av_precip = replace_na(av_precip,0)) %>% 
              select(-count),
            x = ~hour,
            y = ~av_precip, 
            type = "scatter",
            mode = "lines+markers"
    ) %>% 
      layout(title = "Average Precipitation By Hour", xaxis =  x_line.weather, yaxis = y_line.precip, font = weather_title_font)  
  })
  
  output$line.visib.av <- renderPlotly({
    filter_date <- event_date()
    
    #Line Graph of Visibility
    plot_ly(single_weather_hourly %>% 
              filter(date == filter_date) %>% 
              select(hour, av_visib) %>% 
              right_join(y = hour_profile, by = c("hour" = "hour")) %>% 
              mutate(av_visib = replace_na(av_visib,0)) %>% 
              select(-count),
            x = ~hour,
            y = ~av_visib, 
            type = "scatter",
            mode = "lines+markers"
    ) %>% 
      layout(title = "Average Visibility By Hour", xaxis =  x_line.weather, yaxis = y_line.visib, font = weather_title_font)  
  })
  output$boxplot.hour <- renderPlotly({
    #Time Series Boxplot
    plot_ly(flights_major %>% 
              filter(date == event_date(),
                     arr_delay <= 400),
            x = ~hour,
            y = ~arr_delay,
            type = "box"
    ) %>% 
      layout(title = "Average Delay By Hour", 
             xaxis =  x_line.hour, yaxis = y_boxplot.hour)
  })
}
shinyApp(ui = ui, server = server)

