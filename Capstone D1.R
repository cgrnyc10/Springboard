# This is the first draft of my capstone project attempting to use drivers analysis to tease out the effect of
# weather on stock performance. 

# Set the correct working directory and load necessary packages
setwd("~/Desktop/Nerdery")
library(readr)
library(dplyr)
library(tidyr)

# Load proper files (must be in working directory data came from: XXXXXXXXXXX)
sp <- read_csv("SP.csv")

# Select out relevant stock data
stocks <- sp %>%
  select(Open, High, Low, Close, Volume)

# Get dates as a single column
dates <- sp %>%
  select(contains("Date")) 

# Slice out the relevant dates (time TBD, in this instance 1984). Need to double slice for some 
# reason, could just be superstition
Eight_Four <- slice(dates, 8065:7813)
Eight_Four <- slice(Eight_Four, 1:253)

# Step 1 of URL Creator: Change over dates to characters. Keeping as dates seems to add unecessery complexity.
csup <- sapply(Eight_Four, as.character)

# Step 2 of URL Creator: Define and add the proper time stamp 
niner <- "09:00:01-0500"
nines <- paste(csup, niner, sep = "T")

# Step 3 of URL Creator: Define and add the Dark Star API URL
url <- "https://api.forecast.io/forecast/33fa9e8496bc233758e25008e4bb7847/40.7067692,-74.0112509,"
urls <- paste(url,nines, sep = "")

# Create empty data frames to populate with data from API 
url_test = NULL
weather_temp = NULL
weather_percip = NULL
weather_percipprob = NULL
weather_summary = NULL
weather_icon = NULL
dates_for = NULL

#  For loop that makes an API call, pulls necessery daily data, populates one by one. There's probably a 
# faster way to do this.
for (i in 1:253) {
  url<- urls[i]
  weather <- fromJSON(url)
  weather_temp[i] <- weather$currently$temperature
  weather_percip[i] <- weather$currently$precipIntensity
  weather_percipprob[i] <- weather$currently$precipProbability
  weather_summary[i] <- weather$currently$summary
  weather_icon[i] <- weather$currently$icon
}

# Brings columns together, seems inefficient, but necessary
weather_bind <- cbind(Eight_Four, weather_temp, weather_percip, weather_percipprob, weather_summary, weather_icon, Eight_Four_Stocks)

# Performs necessery transformations to information to make it workable
weather_bind <- as.data.frame(weather_bind)
weather_bind <- tbl_df(weather_bind)
summary(weather_bind)
