#compare final destination points with last data - Two divergent data sets that I created!
library(sf)
library(tmap)
library(tidyverse)

# library(leaflet) # for interactive maps
# library(mapview) # for interactive maps
# library(ggplot2) # tidyverse data visualization package
# library(shiny)   # for web applications

final_dest_pts_dir <- "E:/gis/GISDATA/ALDABRA/working files/turtle/sat_tag_data/"
final_dest_pts <- read_sf(dsn = paste0(final_dest_pts_dir,"final_destination_pts_wgs84.shp"))

tmap_mode("view")
tm_shape(final_dest_pts) +
        tm_symbols(col = "blue", scale = .5, n = 8, alpha = 0.5) +
        tm_shape(frst_lst_pts) +
        tm_symbols(col = "red", scale = .5, n = 8, alpha = 0.5)
        
