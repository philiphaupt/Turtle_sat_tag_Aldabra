#AIM: Rread and inspect the boudnaries of Aldabra Atoll's NEW marine proteted area (MPA) to decide which one to use in determining the start (first satellite tag point) outside of MPAs

library(tidyverse)
library(sf)
library(tmap)
#library(tmaptools)

# 1. Load data

#read in turtle points as R object data - does not require running script 1 first where the data are read in and cleaned.
turtle_pts_sf_utm38s <- read_rds("./data/turtle_pts_sf_utm38s.rds")


# load simplified Aldabra
#----------------

# Plot using new mpa boundary
ald_mpa_new_dir <- "E:/gis/GISDATA/ALDABRA/working files/MPA/designated_mpa_expansion/"

mpa_new <- 
        read_sf(paste(ald_mpa_new_dir,"MPA_expanded_2018_utm38s.shp", sep = ""))

write_rds(mpa_new, "./data/mpa_new.rds")

# plot new MPA
mpa_new %>% 
        tm_shape() +
        tm_borders("black", lty = "dashed")

# plot with points
mpa_new %>%
        tm_shape() +
        tm_borders("black", lty = "dashed") +
        tm_shape(turtle_pts_sf_utm38s) +
        tm_symbols(
                col = "tag_id",
                palette = "Accent",
                scale = .5,
                n = 8,
                alpha = 0.9
        )
