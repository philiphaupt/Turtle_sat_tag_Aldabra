# Aim: make a map of Aldabra Atoll

library(sf)
library(tmap)
library(sp)

# load simplified Aldabra
ald_dir <-
        "E:/gis/GISDATA/ALDABRA/archive/imagery/1998Orthophotos/original/1998_orthophoto_shp/"
#read in shapefile
aldabra <- read_sf(paste0(ald_dir, "base.shp"))
st_crs(aldabra) # is already in utm38s

# Settlement <- st_point(c(896100,634600))
# SpatialPolygons(list(Polygons(list(Polygon(Settlement)), 1))) %>%
#         as(., "SpatialPolygonsDataFrame")
# 
# st_crs(Settlement)
# Settlement <- Settlement %>% st_set_crs(st_crs(aldabra))
# class(Settlement)
# plot(Settlement)

tmap_mode("plot") 
tmap::tm_shape(aldabra) +
        #tm_graticules()+ #gives decimal degrees
        tm_grid()+ # will give utm
        tm_polygons(lwd = 0.7)+
        tm_layout(inner.margins = c(0.1,0.05)) +
        tm_scale_bar(breaks = c(0,5, 10), text.size = 1) 
        #tm_shape(Settlement)+
        #tm_symbols("black")
        
