library(dplyr)
library(ggmap)
library(ggplot2)
library(zipcode)
library(choroplethrMaps)
library(choroplethr)
#Data from https://catalog.data.gov/dataset/healthcare-associated-infections-hospital-3ca5e
#TheÂ Healthcare-Associated Infection (HAI)Â measures - provider data. These measures are developed byÂ Centers for Disease Control and Prevention (CDC)Â and collected through theÂ National Healthcare Safety Network (NHSN). They provide information on infections that occur while the patient is in the hospital. These infections can be related to devices, such as central lines and urinary catheters, or spread from patient to patient after contact with an infected person or surface. Many healthcare associated infections can be prevented when the hospitals useÂ CDC-recommended infection control steps.

data = read.csv('./Infections/data/Healthcare_Associated_Infections_-_Hospital.csv')

data$zip = clean.zipcodes(data$ZIP.Code)
data(zipcode)
data=merge(data,zipcode,by.x="zip",by.y="zip")

ggmap(get_map(location = "United States",
              zoom=4,
              maptype = 'terrain',
              color = "bw")) + 
  
  geom_point(data=data %>% 
               filter(Compared.to.National != 'Not Available') %>%
               filter(Compared.to.National != 'No Different than National Benchmark'), 
             aes(x=longitude,
                 y=latitude,
                 color=Compared.to.National))
