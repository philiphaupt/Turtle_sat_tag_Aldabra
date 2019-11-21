#read in data files on turtle movement

#libraries
library(tidyverse)
library(data.table)
library(sf)
library(tmap)
library(lubridate)

#------------------------------------------------
# 1. Read in shapefile data, and store all data in a single table which retains the geomotry and date values.

# Directory where data is stored in:
data_dir <-
        "E:/gis/GISDATA/ALDABRA/working files/turtle/sat_tag_data/copy_points/"

# Produce character vector of filne names inside the directory specifid above: i.e. all the point files
list_files <- list.files(data_dir) %>%
        tibble::enframe(name = NULL) %>%
        rename(file_name = value) %>%
        filter(grepl(".shp", file_name))


# Define data frame in which data will be stored
turtle_pts <- data.frame() # empty still

# Use  for loop to allow repeating the reading process (i.e. read each file sequentially)
for (i in 1:nrow(list_files)) {
        dbf_tmp <- sf::read_sf(paste0(data_dir, list_files[i, ])) # read in spatial shapefile data
        dbf_tmp2 <- dbf_tmp %>% # and only select fields of interest
                dplyr::select(tag_id, utc, POSIX, POSIX_1, local_time, lc)
        turtle_pts <- # bind these data into a table, and add the next to this, and the next etc.
                rbindlist(list(turtle_pts, dbf_tmp2), use.names = T) #for each iteration, bind the new data to the building dataset
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
        turtle_pts %>%
        st_as_sf()
rm(turtle_pts)
#----------------------------------------------
# 4. Change tag id to factor to change legend in plot ouputs to categorical
turtle_pts_sf$tag_id <- as.factor(turtle_pts_sf$tag_id)

# 5. Reporoject satellite tagging points to utm 38 L (southern hemisphere)
turtle_pts_sf_utm38s <- st_transform(turtle_pts_sf, 32738)
rm(turtle_pts_sf)
# 5. save R object to allow calling it up in future without having to run all the read and cleaning scripts.
write_rds(turtle_pts_sf_utm38s,"./data/turtle_pts_sf_utm38s.rds")
rm(list_files)
#-----------------------------------------------
#-----------------------------------------------


