#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(leaflet)
library(spData)
library(dplyr)
library(sf)
library(DT)
library(tidyverse)
library(stringr)
library(rgeos)
library(rgdal)
library(lubridate)
library(tmap)

# Define UI for application that draws a histogram
ui <- fluidPage(

  
   # Application title
   titlePanel("Dashboard"),
   
   # Sidebar with a slider input for number of bins 
   sidebarLayout(
      sidebarPanel(
         selectInput("span", "Time Span:",
                     c("Day" = "day",
                       "Week" = "week",
                       "Month" = "month")),
         sliderInput("month",
                     "Select a month:",
                     min = as.Date("2017-05-01", "%Y-%m-%d"),
                     max = as.Date("2018-05-01", "%Y-%m-%d"),
                     value = as.Date("2017-11-01"),
                     timeFormat="%Y-%m-%d")
      ),
      
      # Show a plot of the generated distribution
      mainPanel(
          h2("Beijing City Service Call Time Series Analysis"),
          p("The dashboard visualizes the spatiotemporal city service call data of 2 large residential communities in Beijing",
          style = "font-family: 'times'"),
          plotOutput("geomline"),
          leafletOutput("map")
   )
  )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
   
   output$geomline <- renderPlot({
      # read in data
     setwd("D:/Auguste/Projects/UrbanXYZ/working_data")
     
     # read in 12345 with village ID as sf
     callvillage <- read_sf('Join_Output.shp', quiet = FALSE)
     
     # extract id, location, time, name columns from raw 12345 dataset
     callvillage_clean <- callvillage %>%
       dplyr::select(FID_1, id_town,nm_town_2, id_ori, type_1, lng, lat, time, month, area)
     
     callvillage_df <- callvillage_clean %>%
       st_drop_geometry() %>% # remove geom column for df wrangling
       mutate(
         time = ymd_hms(time), # convert string to lubridate POSIXt time object 
         date = date(time), # extract date without time 
         hour = hour(time), # hour in a day
         wday = wday(time, label = TRUE), # day in a week as ordered factor
         mday = mday(time) # day in a month
       )
     
     # March and April 2017 are negligible.
     callvillage_month <- callvillage_df %>% 
       dplyr::filter(month != "2017-03" & month != "2017-04") # remove obs in March and April 2017
     
     # create time series line plot for the time span
     callvillage_month %>%
       count(span = floor_date(time, input$span)) %>%
       ggplot(aes(span, n)) + geom_line() +
       labs(title = paste0("Total City Service Call in ", input$span), x = input$span, y = "number of calls") +
       theme(plot.title = element_text(hjust = 0.5))
     
   })
   
   output$map <- renderLeaflet({
     
     # read in village boundaries 
     village <- read_sf('huitian_village_190319.shp', quiet = FALSE)

     village_num_month <- callvillage_month %>%
       group_by(id_ori, month) %>%
       summarise(call_num = n()) %>% # calculate monthly call number in villages
       inner_join(village %>% dplyr::select(geometry, id_ori), by = "id_ori") # add geometry column
     
     village_num_month = st_as_sf(village_num_month)
     
     month_filter = substr(input$month, 1, 7)
     
     working_map <- tm_shape(village_num_month %>% filter(month == month_filter)) + 
                tm_fill(col = "call_num", 
                  breaks = c(0,10,20,30,40,50,200), 
                  title = "12345 call")
     
     tmap_leaflet(working_map)
   })
}

# Run the application 
shinyApp(ui = ui, server = server)

