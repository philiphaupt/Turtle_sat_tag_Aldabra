# Aim: Inspect satelite tag points

library(sf)
library(tidyverse)
library(tmap)

#read in turtle points as R object data - does not require running script 1 first where the data are read in and cleaned.
turtle_pts_sf_utm38s <- read_rds("./data/turtle_pts_sf_utm38s.rds")
turtle_ALL_pts_sf_utm38s <- read_rds("./data/turtle_ALL_pts_sf_utm38s.rds")

tmap::tmap_mode("view")

tm_shape(turtle_pts_sf_utm38s) +
        tm_symbols(
                col = "tag_id",
                palette = "Accent",
                scale = .5,
                n = 8,
                alpha = 0.9
        )

# compare ALL points to GIS cleaned data
tm_shape(turtle_pts_sf_utm38s) +
        tm_symbols(
                col = "blue",
                alpha = 0.9
        ) +
        tm_shape(turtle_ALL_pts_sf_utm38s) + 
        tm_symbols(
                col = "red",
                alpha = 0.9
        )

tm_shape(turtle_ALL_pts_sf_utm38s) + 
        tm_symbols(
                 col = "tag_id",
                 palette = "Accent",
                 scale = .5,
                 n = 8,
                 alpha = 0.9
        )
        

sf::write_sf(turtle_ALL_pts_sf_utm38s, "./data/turtle_ALL_pts_sf_utm38s.GPKG", layer = "ALL_turtle_track_pts")
