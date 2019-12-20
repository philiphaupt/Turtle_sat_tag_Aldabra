# AIM: consolidate a data set for plotting inside and ouside MPA data set, using only the last point inside the MPA, and then all the points outside the MPA.
library(tidyverse)
library(sf)
library(tmap)
library(tmaptools)

#read data
# All points outside MPA
pts_subset_outside_mpa_utm38s <- read_rds("./data/pts_subset_outside_mpa_utm38s.rds")

# only the last point inside the Aldabra MPA
last_pts_inside_mpa <- read_rds("./data/last_pts_inside_mpa.rds")

# combine dta sets
turtle_points_start_to_end <- rbind(last_pts_inside_mpa, pts_subset_outside_mpa_utm38s)

write_rds(turtle_points_start_to_end,"./data/turtle_points_start_to_end.rds")

sf::st_write(turtle_points_start_to_end, "./output/turtle_tracks_start_to_end.gpkg", layer = "Sat_tag_points", layer_options = c("update = TRUE"))
