# AIM calculate the distance from the points in the feeding grounds to the nearst  MPA polygon.

#libraries
library(sf)
library(sp)
library(rgeos)


#read in data
feeding_ground_pts <- read_rds("./data/feeding_ground_pts.rds")
feeding_ground_pts_first<- read_rds("./data/feeding_ground_pts_first.rds")

st_crs(feeding_ground_pts)
MPA_minus_land_utm38s <- st_transform(MPAs_minus_land, 32738)

#for each turtle (tag_id) calculate teh distance from the points recorded at teh feeding grounds to the nearest MPA
turtle_to_MPA <- apply(feeding_ground_pts %>% group_by(tag_id) %>% st_distance(MPA_minus_land_utm38s),2,min)
turtle_to_MPA <- feeding_ground_pts_first %>% 
        plyr::dlply(function(x) {
                y <- as_Spatial(x)
                z <- st_as_sf(y)
                dist <- st_distance(z)
                min_dist <- min(dist)
} ,.variables = "tag_id")

# spts <- as_Spatial(feeding_ground_pts)
# columbus <- as_Spatial(MPA_minus_land_utm38s)
(turtle_to_MPA <-  apply(gDistance(spts, columbus,byid=TRUE),2,min))
(turtle_to_MPA_793 <- feeding_ground_pts_first %>% filter(tag_id == "108793") %>% 
        st_distance(y = MPA_minus_land_utm38s)) %>% min()
(turtle_to_MPA_794 <- feeding_ground_pts_first %>% filter(tag_id == "108794") %>% 
        st_distance(y = MPA_minus_land_utm38s)) %>% min()
(turtle_to_MPA_795 <- feeding_ground_pts_first %>% filter(tag_id == "108795") %>% 
        st_distance(y = MPA_minus_land_utm38s)) %>% min()

(turtle_to_MPA_796 <- feeding_ground_pts_first %>% filter(tag_id == "108796") %>% 
                st_distance(y = MPA_minus_land_utm38s)) %>% min()
(turtle_to_MPA_797 <- feeding_ground_pts_first %>% filter(tag_id == "108797") %>% 
                st_distance(y = MPA_minus_land_utm38s)) %>% min()
(turtle_to_MPA_798 <- feeding_ground_pts_first %>% filter(tag_id == "108798") %>% 
                st_distance(y = MPA_minus_land_utm38s)) %>% min()

(turtle_to_MPA_799 <- feeding_ground_pts_first %>% filter(tag_id == "108799") %>% 
                st_distance(y = MPA_minus_land_utm38s)) %>% min()
(turtle_to_MPA_800 <- feeding_ground_pts_first %>% filter(tag_id == "108800") %>% 
                st_distance(y = MPA_minus_land_utm38s)) %>% min()
