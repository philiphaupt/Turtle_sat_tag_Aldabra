# AIM: Rread and inspect the boudnaries of Aldabra Atoll's marine proteted area (MPA) to decide which one to use in determining the start (first satellite tag point) outside of MPAs

library(tidyverse)
library(sf)
library(tmap)
#library(tmaptools)

# 1. Load data

#read in turtle points as R object data - does not require running script 1 first where the data are read in and cleaned.
turtle_pts_sf_utm38s <- read_rds("./data/turtle_pts_sf_utm38s.rds")


# load simplified Aldabra

# OLD 1km mpa boundary

ald_mpa_dir <-
        "./data/input/mpa_boundary-simplified30_utm/"
ald_mpa_1km <-
        read_sf(paste0(ald_mpa_dir, "mpa_boundary-simplified30_utm.shp"))
ald_mpa_1km$label <- "MPA"

ald_mpa_1km %>%
        tm_shape() +
        tm_borders("black")

#if not the mpa - you can use a buffer to set the area of interest
#buffer # check project and set distance or reproject
buf <- st_buffer(ald_mpa_1km, dist = 6500) # here for example 1000m
buf$label <- "6500m"

ald_mpa_1km %>%
        tm_shape() +
        tm_borders("black") +
        tm_text("label",
                auto.placement = FALSE,
                xmod = 0,
                ymod = 22) +
        tm_shape(buf) +
        tm_borders("black", lty = "dashed") +
        tm_text("label",
                auto.placement = FALSE,
                xmod = 0,
                ymod = 47) +
        tm_shape(turtle_pts_sf_utm38s) +
        tm_symbols(
                col = "tag_id",
                palette = "Accent",
                scale = .5,
                n = 8,
                alpha = 0.9
        )

