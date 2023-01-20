# AIM: Find feeding ground points, and find the first point of arrivl at the feeding grounds
# Assumptions: The END point was defined as the FIRST POINT when the turtle was deemed to have arrived at the feeding grounds. This in turn was defined usinga  rule of taking the first point occuring within 6500 m of the very final point.
# # The 6500 m was based on the distance which all turtles remained around Aldabra prior to leaving  - i.e. points captured between datttgin and leaving. This was used as it it suggess a "home range" of around 6500 km dring breeding - it may be incorrect, as it is not a fact - but an assuption.

#READ IN DATA
pts_subset_outside_mpa_utm38s <- read_rds("./data/pts_subset_outside_mpa_utm38s.rds")


#--------------------------------------------
# Very last points (outside) MPA
last_pts <- pts_subset_outside_mpa_utm38s %>%
        group_by(tag_id) %>%
        filter(utc_fixed == max(utc_fixed))

write_rds(last_pts, "./data/last_pts.rds")

#buffer around last points to allow selecting all the points inside the 6.5 km buffer, in turn ,to select the first point inside this 6.5 km bffer - which can be regarded as the point of arrival in the fedding grounds.
last_pts_buffer <- last_pts %>% 
        st_buffer(dist = 6500) # test value - I know that 6500 m that turtles stuck around Aldabra - so start with that number 

write_rds(last_pts_buffer, "./data/last_pts_buffer.rds")


# ID all points outside Aldabra MPA that fall inside buffer to select "feeding grounds"
feeding_ground_pts <- st_intersection(pts_subset_outside_mpa_utm38s, last_pts_buffer) %>% 
        select(1:13)

write_rds(feeding_ground_pts, "./data/feeding_ground_pts.rds")

# ID the first feeding ground point - inside the 6.5 km buffer - as this is the point when the turtle arrives at the feeding ground
feeding_ground_pts_first <- feeding_ground_pts %>% 
        dplyr::group_by(tag_id) %>% 
        dplyr::filter(utc_fixed == min(utc_fixed))

write_rds(feeding_ground_pts_first, "./data/feeding_ground_pts_first.rds")
