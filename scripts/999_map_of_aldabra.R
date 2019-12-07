# Aim: make a map of Aldabra Atoll

library(sf)
library(tmap)
library(sp)
library(ggplot2)
library(spData)


# load simplified Aldabra
ald_dir <-
        "E:/gis/GISDATA/ALDABRA/archive/imagery/1998Orthophotos/original/1998_orthophoto_shp/"
#read in shapefile
aldabra <- read_sf(paste0(ald_dir, "base.shp"))
st_crs(aldabra) # is already in utm38s

localities <- st_sfc(st_point(c(46.207,-9.4)), crs = 4326) #896100,634600
localities <- st_sf(localities, name="Settlement")
st_crs(localities)
localities_utm38s <- localities %>% st_transform(st_crs(aldabra))#st_crs(aldabra)

tmap_mode("plot") 
aldabra_map <- tmap::tm_shape(aldabra) +
        tm_graticules(col = "gray87") + #gives decimal degrees
        #tm_grid()+ # will give utm
        tm_polygons(lwd = 0.7) +
        tm_shape(localities) +
        tm_symbols(col = "black",
                   size = 0.5) +
        #tm_legend("name")+
        tm_text("name",
                just = "left",
                ymod = 0.9) +
        tm_layout(inner.margins = c(0.1, 0.05)) +
        tm_scale_bar(breaks = c(0, 5, 10), text.size = 1)
        
        
        # 
tmap_save(aldabra_map, "./aldabra_map.png", width = 15, height = 7.5, units = "cm", dpi = 500)
