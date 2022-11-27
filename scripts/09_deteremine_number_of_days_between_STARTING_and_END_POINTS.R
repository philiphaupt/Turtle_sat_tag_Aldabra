# AIM: Determine the number of days between the last point inside the MPA and the first point at the feeding ground

# Definition: Points here refer the the Turtle tracking locaties from the satelite tagging data
# From the results from 05_select_points_inside_Aldabra_NEW_mpa, it was decided that the following assumptions will be made for further analyses:
# Assumptions: The STARTING point of a turtle's track was defined as: Last point inside (new) MPA was used (as opposed to first point outside MPA), as first point may be very far off and much later, not giving an accurate starting point near Aldabra.
# Assumptions: The END point was defined as the FIRST POINT when the turtle was deemed to have arrived at the feeding grounds. This in turn was defined usinga  rule of taking the first point occuring within 6500 m of the very final point.

library(tidyverse)
library(sf)
library(tmap)
#library(tmaptools)

# read NEW larger Aldabra MPA boundaries from saved r object - to use for clipping points to
mpa_new <- read_rds("./data/mpa_new.rds")

# read turtle points - which will be clipped (from r object saved earlier)
turtle_pts_sf_utm38s <- read_rds("./data/turtle_pts_sf_utm38s.rds")

feeding_ground_pts_first <- read_rds("./data/feeding_ground_pts_first.rds")

last_pts_inside_mpa <- read_rds("./data/last_pts_inside_mpa.rds")


# calculate the number of days
#something not right here still - negative numbers?
fdg_df <- st_set_geometry(feeding_ground_pts_first, NULL) %>% 
        select(tag_id,utc_end = utc_fixed)

mpa_in_df <- st_set_geometry(last_pts_inside_mpa, NULL) %>% 
        select(tag_id,utc_start = utc_fixed)

travel_time <- full_join(mpa_in_df,
                         fdg_df,
                         by = "tag_id")

#final calculation for number of days taken        ) 
travel_time$time_in_days <- difftime(travel_time$utc_end, travel_time$utc_start)#, format = "%Y-%m-%d %H:%M") # 3rd gives NA

#see the results:
print(travel_time)

#write results - negative and NA values mean taht the turtle never let the MPA boundary, and should not be included!
write_csv(travel_time, "./travel_time_in_days.csv")
