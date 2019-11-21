# Aim: Inspect satelite tag points

library(sf)
library(tidyverse)
library(tmap)

#read in turtle points as R object data - does not require running script 1 first where the data are read in and cleaned.
turtle_pts_sf_utm38s <- read_rds("./data/turtle_pts_sf_utm38s.rds")

tmap::tmap_mode("view")

tm_shape(turtle_pts_sf_utm38s) +
        tm_symbols(
                col = "tag_id",
                palette = "Accent",
                scale = .5,
                n = 8,
                alpha = 0.9
        )
        