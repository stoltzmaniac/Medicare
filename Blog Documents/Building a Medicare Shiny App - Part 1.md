---
title: "Building a Medicare Shiny App - Part 1"
author: "Scott Stoltzman"
date: "May 14, 2017"
output: html_document
---



Hello R community. if you're up for some fun tinkering with a Shiny App please join me on a new project. I would love to see some collaboration in designing a Shiny Application which will help people make a decision about a healthcare provider. I have only just begun on this project but would to work with others.

This is just a quick look at the data, the roughest shiny app you've ever seen can be located on my [shinyapps.io page](https://stoltzmaniac.shinyapps.io/medicare_data/)

The first goal is to help people find a provider based off of City and State (or perhaps zipcode and latitude/longitude). This can take the form of a list, map, etc. I would also like people to be able to glean some information about the place they are going in comparison to the surrounding locations.

I was only able to put a an hour or so into this (and that was months ago) but have decided that it would be fun to start collaborating with anyone who is interested. Please make any pull requests and I'll get to them!

The data can be found [here](https://catalog.data.gov/dataset/healthcare-associated-infections-hospital-3ca5e) (supplied by data.gov)

[GitHub Repository](https://github.com/stoltzmaniac/Medicare)

Here is a look at the data we're dealing with after merging it with the zipcodes package!


```r
# I merged it with the zipcode data
data = read.csv('../Infections/data/Healthcare_Associated_Infections_-_Hospital.csv')
data$zip = clean.zipcodes(data$ZIP.Code)
data(zipcode)
data=merge(data,zipcode,by.x="zip",by.y="zip")
```
  

```r
head(data,3)
```

```
##     zip Provider.ID                    Hospital.Name
## 1 00603      400079 HOSP COMUNITARIO BUEN SAMARITANO
## 2 00603      400079 HOSP COMUNITARIO BUEN SAMARITANO
## 3 00603      400079 HOSP COMUNITARIO BUEN SAMARITANO
##                                   Address      City State ZIP.Code
## 1 CARR.2 KM.1.4 AVE. SEVERIANO CUEVAS #18 AGUADILLA    PR      603
## 2 CARR.2 KM.1.4 AVE. SEVERIANO CUEVAS #18 AGUADILLA    PR      603
## 3 CARR.2 KM.1.4 AVE. SEVERIANO CUEVAS #18 AGUADILLA    PR      603
##   County.Name Phone.Number                           Measure.Name
## 1   AGUADILLA   7876580000                  CAUTI: Observed Cases
## 2   AGUADILLA   7876580000                 CAUTI: Predicted Cases
## 3   AGUADILLA   7876580000 CAUTI: Number of Urinary Catheter Days
##        Measure.ID Compared.to.National         Score
## 1 HAI_2_NUMERATOR        Not Available Not Available
## 2 HAI_2_ELIGCASES        Not Available Not Available
## 3 HAI_2_DOPC_DAYS        Not Available Not Available
##                                                   Footnote
## 1 5 - Results are not available for this reporting period.
## 2 5 - Results are not available for this reporting period.
## 3 5 - Results are not available for this reporting period.
##   Measure.Start.Date Measure.End.Date Location      city state latitude
## 1         01/01/2015       12/31/2015       NA Aguadilla    PR 18.44862
## 2         01/01/2015       12/31/2015       NA Aguadilla    PR 18.44862
## 3         01/01/2015       12/31/2015       NA Aguadilla    PR 18.44862
##   longitude
## 1 -67.13422
## 2 -67.13422
## 3 -67.13422
```
  
I made an ugly plot of the number of rows per state in order to get see if the data appears to make sense based off of my knowledge of the population of the states. I didn't add the census data but that's certainly a possibility for the future.    



