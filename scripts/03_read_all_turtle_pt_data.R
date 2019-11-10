#read in data files on turtle movement

#libraries
library(tidyverse)
library(data.table)
library(sf)
library(tmap)
library(lubridate)
# Data is stored in:
data_dir <-
        "E:/gis/GISDATA/ALDABRA/working files/turtle/sat_tag_data/copy_points/"

list_files <- list.files(data_dir) %>%
        as_tibble() %>%
        rename(file_name = value) %>%
        filter(grepl(".shp", file_name))
#dplyr::filter(grepl(".dbf",file_name)) %>%
#dplyr::filter(grepl("points", file_name)) #%>%
#as.list(list_files)

#define data frame in which data will be stored
turtle_pts <- data.frame()

for (i in 1:nrow(list_files)) {
        dbf_tmp <- sf::read_sf(paste0(data_dir, list_files[i, ]))
        dbf_tmp2 <- dbf_tmp %>%
                #st_set_geometry(NULL) %>%
                dplyr::select(tag_id, utc, POSIX, POSIX_1, local_time, lc)
        turtle_pts <-
                rbindlist(list(turtle_pts, dbf_tmp2), use.names = T) #for each iteration, bind the new data to the building dataset
}



#-------------------FUNCTION TO CORRECT DATES
# Make dates consistent format: clean data - change the "/" to "-" in the date columns
# Funtion to replace / with - which can now be cycled over specific columns
#replace_date <- function(x, na.rm = FALSE) {
#        str_replace_all(x, "/", "-")
#}

# APLLY FUNCTION: this cycles the function applied to a vector (each specified column) and applies teh replacement function created above
# turtle_pts_cln <- turtle_pts %>%
#         mutate_at(c("utc", "local_time"), replace_date)

# !still a problem - data and year not in correct order! may use posix to see if it solves the problem


turtle_pts$utc_fixed <- parse_date_time(turtle_pts$utc, c("%Y-%m-%d %H:%M", "%d/%m/%Y %H:%M"))
turtle_pts$local_fixed <- parse_date_time(turtle_pts$local_time, c("%Y-%m-%d %H:%M", "%d/%m/%Y %H:%M"))


#---------------------------------------------
# convert the turtle data frame with the spatial column to a sf object o that we can use it in plots.
turtle_pts_sf <-
        turtle_pts %>%
        st_as_sf()

#change tag id to factor to change legend in plot ouputs to categorical
turtle_pts_sf$tag_id <- as.factor(turtle_pts_sf$tag_id)

#plot points on map for inspection
tmap_mode("view") # set mode as interactive
#plot commands
turtle_pts_sf %>%
        #filter(tag_id == "108793") %>% # canapply filteres like this or lc to restrict the plotting to certain turtles or to certain levels of spatial accuracy.
        tm_shape() +
        tm_symbols(
                col = "tag_id",
                palette = "Accent",
                scale = .5,
                n = 8,
                alpha = 0.9
        )


# load simplified Aldabra
ald_dir <-
        "E:/gis/GISDATA/ALDABRA/archive/imagery/1998Orthophotos/original/1998_orthophoto_shp/"
#ald_dir <- "E:/gis/GISDATA/ALDABRA/working files/Aldabra_outlines/"

# 1km mpa boundary

ald_mpa_dir <-
        "E:/stats/aldabra/turtles/turtles_ald_sat_tag_2011_2014/Turtle_sat_tag_Aldabra/data/input/mpa_boundary-simplified30_utm/"
ald <-
        read_sf(paste0(ald_mpa_dir, "mpa_boundary-simplified30_utm.shp"))
ald$label <- "MPA"

ald %>%
        tm_shape() +
        tm_borders("black")

#if not the mpa - you cabn use a buffer to set the area of interest
#buffer # check project and set distance or reproject
buf <- st_buffer(ald, dist = 6500) # here for example 1000m
buf$label <- "6500m"

ald %>%
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
        tm_shape(turtle_pts_sf) +
        tm_symbols(
                col = "tag_id",
                palette = "Accent",
                scale = .5,
                n = 8,
                alpha = 0.9
        )


# Plot using new mpa boundary
ald_mpa_new_dir <- "E:/gis/GISDATA/ALDABRA/working files/MPA/designated_mpa_expansion/"

mpa_new <- 
        read_sf(paste(ald_mpa_new_dir,"MPA_expanded_2018_utm38s.shp", sep = ""))

mpa_new %>% 
        tm_shape() +
        tm_borders("black", lty = "dashed")

#plot with points
mpa_new %>%
        tm_shape() +
        tm_borders("black", lty = "dashed") +
        tm_shape(turtle_pts_sf) +
        tm_symbols(
                col = "tag_id",
                palette = "Accent",
                scale = .5,
                n = 8,
                alpha = 0.9
        )

#st_bbox(ald)

# select last point inside buffer # needs to sort the date system below
# check projections: these have to be the same to ensure that hte process is correctly carried out
st_crs(mpa_new)
st_crs(turtle_pts_sf) # they should be the same, so reproject the points to match Aldabra:
#reproject aldabra
turtle_pts_sf_utm38s <- st_transform(turtle_pts_sf, 32738)

#GEOPROCESSING
#now intersect these to find the points inside the boundary
pts_subset_inside_mpa_utm38s <-
        st_intersection(turtle_pts_sf_utm38s, mpa_new)

pts_subset_outside_mpa_utm38s <-
        st_difference(turtle_pts_sf_utm38s, mpa_new)


# Last points inside MPA
last_pts_inside_mpa <- pts_subset_inside_mpa_utm38s %>%
        group_by(tag_id) %>%
        #filter(lc > 1) %>% 
        filter(utc_fixed == max(utc_fixed))

# first points outside MPA
first_pts_outside_mpa <- pts_subset_outside_mpa_utm38s %>%
        group_by(tag_id) %>%
        #filter(lc > 1) %>% 
        filter(utc_fixed == min(utc_fixed))

# Very last points (outside) MPA
last_pts <- pts_subset_outside_mpa_utm38s %>%
        group_by(tag_id) %>%
        #filter(lc > 1) %>% 
        filter(utc_fixed == max(utc_fixed))

#buffer around last points
last_pts_buffer <- last_pts %>% 
        st_buffer(dist = 6500) # test value - I know that 6500 m that turtles stuck around Aldabra - so start with that number 


# ID all points outside MPA that fall inside buffer to select "feeding grounds"
feeding_ground_pts <- st_intersection(pts_subset_outside_mpa_utm38s, last_pts_buffer)

# ID the first feeding ground point - inside the 6.5 km buffer - as this is the point when the turtle arrives at the feeding ground
feeding_ground_pts_first <- feeding_ground_pts %>% 
        dplyr::group_by(tag_id) %>% 
        dplyr::filter(utc_fixed == min(utc_fixed))
        


#plot and inspect
mpa_new %>%
        tm_shape() +
        tm_borders("black") +
        # tm_text("label",
        #         auto.placement = FALSE,
        #         xmod = 0,
        #         ymod = 22) +
        # tm_shape(buf) +
        # tm_borders("black", lty = "dashed") +
        # tm_text("label",
        #         auto.placement = FALSE,
        #         xmod = 0,
        #         ymod = 47) +
        turtle_pts_sf %>% 
        tm_shape() +
        tm_symbols(
                col = "tag_id",
                palette = "Accent",
                scale = .5,
                n = 8,
                alpha = 0.9
        ) +
        #tm_shape(pts_subset_inside_mpa_utm38s) +
        #tm_symbols(
        #        col = "tag_id",
        #        scale = .5,
        #        n = 8,
        #        alpha = 0.5
        #) +
        tm_shape(last_pts_inside_mpa) +
        tm_symbols(
                col = "blue",
                scale = 0.9,
                alpha = 0.5,
                size = 2
        ) +
        tm_text("tag_id") +
        tm_shape(first_pts_outside_mpa) +
        tm_symbols(
                col = "red",
                scale = 0.9,
                alpha = 0.5,
                size = 2
        ) +
        tm_text("tag_id")


# Plot of last points inside MPAandfinal points, and buffer and the selected points outside MPA.
mpa_new %>%
        tm_shape() +
        tm_borders("black") +
        tm_shape(last_pts_buffer) +
        tm_borders("black", lty = "dashed") +
        turtle_pts_sf %>% 
        tm_shape() +
        tm_symbols(
                col = "grey",
                #palette = "Accent",
                scale = .2,
                #n = 8,
                alpha = 0.9
        ) +
        tm_shape(last_pts_inside_mpa) +
        tm_symbols(
                col = "blue",
                scale = 0.9,
                alpha = 0.5,
                size = 2
        ) +
        tm_text("tag_id") +
        tm_shape(last_pts) +
        tm_symbols(
                col = "red",
                scale = 0.9,
                alpha = 0.5,
                size = 2
        ) +
        tm_text("tag_id") +
        tm_shape(last_pts_buffer)+
        tm_borders(
                col = "black", 
                lty = "dashed"
                ) +
        #tm_shape(feeding_ground_pts) +
        #tm_symbols(col = "grey") +
        tm_shape(feeding_ground_pts_first) +
        tm_symbols(
                col = "cornflowerblue",
                scale = .5,
                alpha = .9,
                size = 3)
        
        
# calculate the number of days
#something not right here still - negative numbers?
(feeding_ground_pts_first$utc_fixed-last_pts_inside_mpa$utc_fixed)

feeding_ground_pts_first$tag_id
last_pts_inside_mpa$tag_id
feeding_ground_pts_first$utc_fixed
last_pts_inside_mpa$utc_fixed


#

# Create a variable taht contains all the points from the last pont inside MPa to the fisrt point at feeding site,
#  create a straight line variable connecting point to point to calculate hte distance
# divide the distance of the time taken

# 108799 may be problemmatic using this criteria - as first points ouside MPA are miles away
#plots looking only at 108799 track
# turtle_pts_sf %>% filter(tag_id == "108799") %>%
#         tm_shape() +
#         tm_symbols(
#                 #col = "tag_id",
#                 #palette = "Accent",
#                 scale = .5,
#                 #n = 8,
#                 alpha = 0.9
#         ) +
#         last_pts_inside_mpa %>% filter(tag_id == "108799") %>% 
#         tm_shape() +
#         tm_symbols(
#                 col = "blue",
#                 scale = 0.9,
#                 alpha = 0.5,
#                 size = 2
#         ) +
#         first_pts_outside_mpa %>% filter(tag_id == "108799") %>% 
#         tm_shape() +
#         tm_symbols(
#                 col = "red",
#                 scale = 0.9,
#                 alpha = 0.5,
#                 size = 2
#         ) +
#         tm_text("tag_id")


