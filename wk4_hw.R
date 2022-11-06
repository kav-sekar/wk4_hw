#load packages
library(usethis)
library(maptools)
library(RColorBrewer)
library(classInt)
library(sp)
library(rgeos)
library(tmap)
library(tmaptools)
library(sf)
library(rgdal)
library(geojsonio)
library(stringr)
library(janitor)
library(dplyr)
library(readr)
library(tidyverse)
library(here)
library(countrycode)

#read in global data
data <- read_csv("hw_data/HDR21-22_Composite_indices_complete_time_series.csv", na="NA")

#select inequality data for all the years
inequality_data <-data %>%
  dplyr::select(contains("iso3"),
                contains("country"),
                contains("gii"))

#create column with difference between 2010 and 2019
inequality_difference <- inequality_data %>%
  mutate(difference_2010_2019 = (gii_2010 - gii_2019)) %>%
  dplyr::select(contains("iso3"),
                contains("country"),
                contains("difference"))

#read shape file of world
shape <- st_read("hw_data/World_Countries_(Generalized)/World_Countries__Generalized_.shp")

#convert shape file's country code from iso2c to iso3c to match with data file
shape$ISO <- countrycode(shape$ISO, origin = "iso2c", destination = "iso3c")

#join world shape file with inequality difference data
map_inequality <- shape %>%
  left_join(.,
            inequality_difference,
            by = c("ISO"="iso3"))

#plot of inequality map
tmap_mode("plot")
tm_shape(map_inequality)+
tm_polygons("difference_2010_2019",
            style ="pretty",
            palette = "-magma",
            n = 10,
            title = "Diffenence in inequality indices between 2010 and 2019")
