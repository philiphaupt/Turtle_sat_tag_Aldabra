#read in data files on turtle movement
rm(list = ls())

#libraries
library(tidyverse)
library(data.table)
library(sf)
library(tmap)
library(lubridate)

#------------------------------------------------
# 1. Read in shapefile data, and store all data in a single table which retains the geomotry and date values.

# Directory where data is stored in:
# data_dir <- "E:/gis/GISDATA/ALDABRA/working files/turtle/sat_tag_data/raw/" 
data_dir <- "E:/gis/GISDATA/ALDABRA/working files/turtle/sat_tag_data/copy_points/" #for shapefiles cleaned A and B

# Produce character vector of filne names inside the directory specifid above: i.e. all the point files
list_files <- list.files(data_dir) %>%
        tibble::enframe(name = NULL) %>%
        rename(file_name = value) %>%
        # filter(grepl(".csv", file_name))
        filter(grepl(".shp", file_name))

# Define data frame in which data will be stored
turtle_pts <- data.frame() # empty still

# Use  for loop to allow repeating the reading process (i.e. read each file sequentially)
for (i in 1:nrow(list_files)) {
        dbf_tmp <- sf::read_sf(paste0(data_dir, list_files[i, ])) # read in spatial shapefile data
        dbf_tmp2 <- dbf_tmp %>% # and only select fields of interest
                  dplyr::select(tag_id, utc, POSIX, POSIX_1, local_time, lc, nb_mes, wet_or_dry = `Wet.Dry`)
        turtle_pts <- rbindlist(list(turtle_pts, dbf_tmp2), use.names = T) #for each iteration, bind the new data to the building dataset # bind these data into a table, and add the next to this, and the next etc.
                 
        #FOR ALL DATA:
        # dbf_tmp2 <- read_csv(paste0(data_dir, list_files[i, ])) %>% 
                # dplyr::select(tag_id, utc, POSIX, POSIX_1, local_time, lc, lon2, lat2, nb_mes, wet_or_dry = `Wet/Dry`)

        
        turtle_pts <- rbindlist(list(turtle_pts, dbf_tmp2), use.names = T)
        
        
}
rm(dbf_tmp, dbf_tmp2)

#---------------------------------------------
# 2. Clean data: CORRECT DATES
# The dates read in are in incosistent format which will cause problems when trying to do calculations with them, the following corrects this
turtle_pts$utc_fixed <- parse_date_time(turtle_pts$utc, c("%Y-%m-%d %H:%M", "%d/%m/%Y %H:%M"))
turtle_pts$local_fixed <- parse_date_time(turtle_pts$local_time, c("%Y-%m-%d %H:%M", "%d/%m/%Y %H:%M"))


#---------------------------------------------
# 3. Convert data frame wtih geometry column to a defined R spatial object.
# convert the turtle data frame with the spatial column to a sf object o that we can use it in plots.
turtle_pts_sf <-
        base::ifelse(sf::st_is(turtle_pts$geometry, "POINT") %>% unique() == FALSE,

        turtle_pts %>%
        st_as_sf(coords = c("lon2", "lat2"), crs = 4326),

        turtle_pts)
# rm(turtle_pts)
#----------------------------------------------
# 4. Change tag id to factor to change legend in plot ouputs to categorical
turtle_pts_sf$tag_id <- as.factor(turtle_pts_sf$tag_id)

# 5. Reporoject satellite tagging points to utm 38 L (southern hemisphere)
turtle_pts_sf_utm38s <- st_transform(turtle_pts_sf, 32738)
rm(turtle_pts_sf)
# 5. save R object to allow calling it up in future without having to run all the read and cleaning scripts.
# write_rds(turtle_pts_sf_utm38s,"./data/turtle_ALL_pts_sf_utm38s.rds")
write_rds(turtle_pts_sf_utm38s,"./data/turtle_ALL_pts_sf_utm38s.rds")
rm(list_files)
#-----------------------------------------------
#-----------------------------------------------


