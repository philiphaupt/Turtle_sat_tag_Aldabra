# AIM: Determine the most suitable starting point to calculate the number of days that each turtle spent frm ALdabra to the feeding grounds.

# Problem: Determine which is more sutable: There are two options: 1) Starting piont is the last point inside the (new) MPA, or 2) the first point outsidetif last point outside the (new) MPA boundary

# Specific objectives/steps: 
## 1. Isolate two sets of points from the orginal data set: inside points from outside points
## 2. Determine the first point outside of the MPA
## 3. Determine the last point inside the MPa

# Methods: 
## 1. GEOPROCESSING: Interesections of Turtle satellite tagging locations (points) and MPA boundaries to determine the inside and ouside points.
## 2. Use the date associated with the points to select/find the first point from the OUTSIDE POINTS subset
## 3. Use the date associated with the points to select/find the last point INSIDE the MPA boundaries

# NOTE: Dates were cleaned in: 01_read_and_clean_all_turtle_pt_data.R; Type to open it file.edit("./scripts/01_read_and_clean_all_turtle_pt_data.R")

library(tidyverse)
library(sf)
library(tmap)

#-----------------if you do not want to run all the previous scripts to prepare the data fresh, you can read a saved copy here:
# read NEW larger Aldabra MPA boundaries from saved r object - to use for clipping points to
mpa_new <- read_rds("./data/mpa_new.rds")

# read turtle points - which will be clipped (from r object saved earlier)
turtle_pts_sf_utm38s <- read_rds("./data/turtle_pts_sf_utm38s.rds")

#-------------------------------------

# NB preprocess check:
# Check that the projections match!
st_crs(mpa_new)
st_crs(turtle_pts_sf_utm38s)
st_crs(turtle_pts_sf_utm38s) == st_crs(mpa_new)
# both should be the Coordinate Reference System:
# EPSG: 32738 
# proj4string: "+proj=utm +zone=38 +south +datum=WGS84 +units=m +no_defs"

# If the third argument is true/they match, carry on: (otherwise reproject using st_transform)

#-------------------------------------------------
# 1. Split data into 2 sets: INSIDE MPA and OUTSIDE MPA boundaries

# 1a. INSIDE: Points inside the new MPA boundary (intersect points with new mpa boundary)
pts_subset_inside_mpa_utm38s <-
        st_intersection(turtle_pts_sf_utm38s, mpa_new)

write_rds(pts_subset_inside_mpa_utm38s,"./data/pts_subset_inside_mpa_utm38s.rds")
# 1b. OUSIDE: Points outside the new MPA boundary
pts_subset_outside_mpa_utm38s <-
        st_difference(turtle_pts_sf_utm38s, mpa_new)

write_rds(pts_subset_outside_mpa_utm38s,"./data/pts_subset_outside_mpa_utm38s.rds")
#------------------------------------------------
# 2. 
# Last points inside MPA
last_pts_inside_mpa <- pts_subset_inside_mpa_utm38s %>%
        group_by(tag_id) %>%
        filter(utc_fixed == max(utc_fixed))

write_rds(last_pts_inside_mpa,"./data/last_pts_inside_mpa.rds")
#--------------------------------------

# STARTING POINT is the FIRST points outside (new) MPA:
first_pts_outside_mpa <- pts_subset_outside_mpa_utm38s %>%
         group_by(tag_id) %>%
         filter(utc_fixed == min(utc_fixed))
write_rds(first_pts_outside_mpa,"./data/first_pts_outside_mpa.rds")


