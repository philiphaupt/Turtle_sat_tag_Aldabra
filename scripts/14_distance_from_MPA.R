# AIM: Determin the distance from the last transmisson point in the feeding grounds to the nearest MPA
library(sf)
library(tidyverse)


# read last points
last_pts <- read_rds("./data/last_pts.rds")
st_crs(last_pts)

#set crs same
st_crs(MPAs)
MPAs_utm38 <- st_transform(MPAs, 32738)
st_crs(MPAs_utm38)
MPAs_centroid_utm38s <- MPAs_utm38 %>% sf::st_centroid()
MPAs_centroid_utm38s <- tibble::rowid_to_column(MPAs_centroid_utm38s, "ID")
#MPA_id <- MPAs_centroid_utm38s %>% st_set_geometry(NULL) %>% unique() %>% dplyr::select(ID, WDPA_PID, NAME)

# distance from MPAs (minus land) 


dist_list <- last_pts %>% 
        plyr::dlply(.variables = "tag_id", function(x){
                
                x_sf <- st_as_sf(x)
                # x_no_geom <- x_sf
                # x_no_geom <- st_set_geometry(x_no_geom, NULL)
                
                # 
                
                # x_join_mpa_names <- tidyr::expand(x_no_geom, ., MPA_names$NAME)
                 
                dist_last_pt_MPA <- as.data.frame(as.matrix(t(sf::st_distance(x_sf, MPAs_centroid_utm38s))))
                names(dist_last_pt_MPA) <- "distance_m"
                dist_last_pt_MPA_named <- bind_cols(dist_last_pt_MPA, MPAs_centroid_utm38s)
                dist_min <- dist_last_pt_MPA_named %>% dplyr::filter(distance_m == min(distance_m)) 
                        #left_join(MPAs_centroid_utm38s, by = c("ID"))
                
        })
dist_list

dist_df <- do.call(rbind.data.frame, dist_list)
dist_sf <- st_as_sf(dist_df, sf_column_name = "geometry")
dist_sf_wgs84 <- st_transform_4326(dist_sf)


