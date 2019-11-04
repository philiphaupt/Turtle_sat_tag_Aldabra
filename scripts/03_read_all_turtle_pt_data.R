#read in data files on turtle movement

#libraries
library(tidyverse)
library(data.table)
library(sf)
library(tmap)
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
                dplyr::select(tag_id, utc, POSIX, POSIX_1, POSIX_1, lc)
        turtle_pts <-
                rbindlist(list(turtle_pts, dbf_tmp2), use.names = T) #for each iteration, bind the new data to the building dataset
}


# code to attempt fixing date errors
turtle_pts$st_time <-
        as.Date(turtle_pts$utc, origin = "2011-11-01")

turtle_pts$newdate <-
        strptime(as.character(turtle_pts$utc), "%Y-%m-%d")
turtle_pts$newdate2 <-
        strptime(as.character(turtle_pts$utc), "%d/%m/%Y")
turtle_pts %>% unite(col = "newdate3", newdate:newdate2, sep = "")
turtle_pts$newdate[is.na(turtle_pts$newdate)] <- ""
strftime(x = turtle_pts$utc, tz = "UTC", format = "%Y-%m-%d %H:%M:%S")

#-------------------FUNCTION TO CORRECT DATES
# Make dates consistent format: clean data - change the "/" to "-" in the date columns
# Funtion to replace / with - which can now be cycled over specific columns
replace_date <- function(x, na.rm = FALSE) {
        str_replace_all(x, "/", "-")
}

# APLLY FUNCTION: this cycles the function applied to a vector (each specified column) and applies teh replacement function created above
# turtle_pts_cln <- turtle_pts %>%
#         mutate_at(c("utc", "local_time"), replace_date)

# !still a problem - data and year not in correct order! may use posix to see if it solves the problem




#---------------------------------------------
# convert the turtle data frame with the spatial column to a sf object o that we can use it in plots.
turtle_pts_sf <-
        turtle_pts_cln %>%
        st_as_sf()

#change tag id to factor to change legend in plot ouputs to categorical
turtle_pts_sf$tag_id <- as.factor(turtle_pts_sf$tag_id)

#plot for inspection
tmap_mode("view")
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
ald_mpa_dir <-
        "E:/stats/aldabra/turtles/turtles_ald_sat_tag_2011_2014/Turtle_sat_tag_Aldabra/data/input/mpa_boundary-simplified30_utm/"
#use mpa boundary
ald <-
        read_sf(paste0(ald_mpa_dir, "mpa_boundary-simplified30_utm.shp"))

ald %>%
        tm_shape() +
        tm_borders("black")

#if not the mpa - you cabn use a buffer to set the area of interest
#buffer # check project and set distance or reproject
buf <- st_buffer(ald, dist = 1000) # here for example 1000m
buf$label <- "1000m"

ald %>%
        tm_shape() +
        tm_borders("black") +
        tm_shape(buf) +
        tm_borders("black") +
        tm_text("label",
                auto.placement = FALSE,
                xmod = -30,
                ymod = 30) +
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
st_crs(ald)
st_crs(turtle_pts_sf) # they should be the same, so reproject the points to match Aldabra:
#reproject aldabra
turtle_pts_sf_utm38s <- st_transform(turtle_pts_sf, 32738)

#GEOPROCESSING
#now intersect these to find the points inside the boundary
pts_subset_inside_mpa_utm38s <-
        st_intersection(turtle_pts_sf_utm38s, ald)

pts_subset_outside_mpa_utm38s <-
        st_difference(turtle_pts_sf_utm38s, ald)


# Last points inside MPA
last_pts_inside_mpa <- pts_subset_inside_mpa_utm38s %>%
        group_by(tag_id) %>%
        filter(POSIX_1 == max(POSIX_1))

# first points outside MPA
first_pts_outside_mpa <- pts_subset_outside_mpa_utm38s %>%
        group_by(tag_id) %>%
        filter(POSIX_1 == min(POSIX_1))

#plot and inspect
ald %>%
        tm_shape() +
        tm_borders("black") +
        #tm_shape(buf) +
        #tm_borders("black") +
        #tm_text("label",
        #        auto.placement = FALSE,
        #        xmod = -30,
        #        ymod = 30) +
        tm_shape(turtle_pts_sf) +
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
        #tm_text("tag_id") +
        tm_shape(first_pts_outside_mpa) +
        tm_symbols(
                col = "red",
                scale = 0.9,
                alpha = 0.5,
                size = 2
        ) +
        tm_text("tag_id")



# 108799 may be problemmatic using this criteria - as first points ouside MPA are miles away
#plots looking only at 108799 track
turtle_pts_sf %>% filter(tag_id == "108799") %>%
        tm_shape() +
        tm_symbols(
                #col = "tag_id",
                #palette = "Accent",
                scale = .5,
                #n = 8,
                alpha = 0.9
        ) +
        last_pts_inside_mpa %>% filter(tag_id == "108799") %>% 
        tm_shape() +
        tm_symbols(
                col = "blue",
                scale = 0.9,
                alpha = 0.5,
                size = 2
        ) +
        first_pts_outside_mpa %>% filter(tag_id == "108799") %>% 
        tm_shape() +
        tm_symbols(
                col = "red",
                scale = 0.9,
                alpha = 0.5,
                size = 2
        ) +
        tm_text("tag_id")

# 108800 may be problemmatic using this criteria - as first points ouside MPA are miles away
#plots looking only at 108800 track - PROBLEM HERE IS THE DATE FORMATTING IS INCORRECT
turtle_pts_sf %>% filter(tag_id == "108800") %>%
        tm_shape() +
        tm_symbols(
                #col = "tag_id",
                #palette = "Accent",
                scale = .5,
                #n = 8,
                alpha = 0.9
        ) +
        last_pts_inside_mpa %>% filter(tag_id == "108800") %>% 
        tm_shape() +
        tm_symbols(
                col = "blue",
                scale = 0.9,
                alpha = 0.5,
                size = 2
        ) +
        first_pts_outside_mpa %>% filter(tag_id == "108800") %>% 
        tm_shape() +
        tm_symbols(
                col = "red",
                scale = 0.9,
                alpha = 0.5,
                size = 2
        ) +
        tm_text("tag_id")


