library(RSQLite)
library(ggmap)
library(ggplot2)
library(zipcode)
library(choroplethrMaps)
library(choroplethr)
library(dplyr)
#Data from https://catalog.data.gov/dataset/healthcare-associated-infections-hospital-3ca5e
#TheÂ Healthcare-Associated Infection (HAI)Â measures - provider data. These measures are developed byÂ Centers for Disease Control and Prevention (CDC)Â and collected through theÂ National Healthcare Safety Network (NHSN). They provide information on infections that occur while the patient is in the hospital. These infections can be related to devices, such as central lines and urinary catheters, or spread from patient to patient after contact with an infected person or surface. Many healthcare associated infections can be prevented when the hospitals useÂ CDC-recommended infection control steps.

con = dbConnect(RSQLite::SQLite(),dbname='medicare.sqlite')
rs = dbSendQuery(con, "SELECT * FROM medicare") 
data = dbFetch(rs)
data$zip = clean.zipcodes(data$ZIP.Code)
data(zipcode)
data=merge(data,zipcode,by.x="zip",by.y="zip")

df = data %>%
  select(City,State,latitude,longitude,Score,Measure.Name,Hospital.Name)

rm(data)

pMap = ggmap(get_map(location = "United States",
                     zoom=4,
                     maptype = 'terrain',
                     color = "bw")) 


###Input Filter Options
stateChoices = sort(unique(df$State))
