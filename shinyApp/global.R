library(RSQLite)
library(ggmap)
library(ggplot2)
library(zipcode)
library(dplyr)
library(scales)
library(leaflet)
library(DT)

#Data from https://catalog.data.gov/dataset/healthcare-associated-infections-hospital-3ca5e
#TheÂ Healthcare-Associated Infection (HAI)Â measures - provider data. These measures are developed byÂ Centers for Disease Control and Prevention (CDC)Â and collected through theÂ National Healthcare Safety Network (NHSN). They provide information on infections that occur while the patient is in the hospital. These infections can be related to devices, such as central lines and urinary catheters, or spread from patient to patient after contact with an infected person or surface. Many healthcare associated infections can be prevented when the hospitals useÂ CDC-recommended infection control steps.

con = dbConnect(RSQLite::SQLite(),dbname='medicare.sqlite')
rs = dbSendQuery(con, "SELECT * FROM medicare") 
data = dbFetch(rs)
data$zip = clean.zipcodes(data$ZIP.Code)
data(zipcode)
data=merge(data,zipcode,by.x="zip",by.y="zip")
data$latlon = paste(data$latitude,data$longitude)

df = data %>%
  select(City,State,latitude,longitude,Score,Compared.to.National,Measure.Name,Hospital.Name,ZIP.Code,latlon,Address,Phone.Number)
rm(data)

###Input Filter Options
ALL_FILTER_NAME <- "All"
stateChoices = c(ALL_FILTER_NAME, sort(unique(df$State)))
cityChoices = c(ALL_FILTER_NAME, sort(unique(df$City)))
zipcodeChoices = c(ALL_FILTER_NAME, sort(unique(df$ZIP.Code)))
hospitalChoices = c(ALL_FILTER_NAME, sort(unique(df$Hospital.Name)))
measureNameChoices = factor(c(ALL_FILTER_NAME, sort(unique(df$Measure.Name))))

# Change types
df$Measure.Name <- as.factor(df$Measure.Name)
df$Score <- as.numeric(df$Score)

# Slider properties
SLIDER_MIN_VALUE <- 0
SLIDER_MAX_VALUE <- 100
SLIDER_INIT_VALUE <- 25

# Datatable properties
MAX_ITEMS_PER_PAGE <- SLIDER_INIT_VALUE
TABLE_PAGING <- TRUE
LENGTH_MENU <- c(5, 10, 15, 20, 25, 50, 75, 100)