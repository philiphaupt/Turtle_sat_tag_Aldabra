# AIM: Determin the distance from the last transmisson point in the feeding grounds to the nearest MPA
library(sf)
library(tidyverse)
library(data.table)


# read last points
last_pts <- read_rds("./data/last_pts.rds")
MPAs <- read_rds("./data/MPAs.rds")
st_crs(last_pts)

#set crs same
st_crs(MPAs)
MPAs_utm38 <- st_transform(MPAs, 32738)
st_crs(MPAs_utm38)
MPAs_centroid_utm38s <- MPAs_utm38 %>% sf::st_centroid()
MPAs_centroid_utm38s <- tibble::rowid_to_column(MPAs_centroid_utm38s, "ID")
MPAs_utm38 <- tibble::rowid_to_column(MPAs_utm38, "ID") %>% 
        dplyr::filter(GEOMETRY_TYPE == "POLYGON") %>% 
        dplyr::filter(AREA_KM2 > 6.5)

# distance from MPAs (minus land) 


dist_list <- last_pts %>% 
        plyr::dlply(.variables = "tag_id", function(x){
                
                x_sf <- st_as_sf(x)
                # x_no_geom <- x_sf
                # x_no_geom <- st_set_geometry(x_no_geom, NULL)
                
                # 
                
                # x_join_mpa_names <- tidyr::expand(x_no_geom, ., MPA_names$NAME)
                 
                dist_last_pt_MPA <- as.data.frame(as.matrix(t(sf::st_distance(x_sf, MPAs_utm38))))
                names(dist_last_pt_MPA) <- "distance_m"
                dist_last_pt_MPA_named <- bind_cols(dist_last_pt_MPA, MPAs_utm38)
                dist_min <- dist_last_pt_MPA_named %>% dplyr::filter(distance_m == min(distance_m)) 
                        #left_join(MPAs_centroid_utm38s, by = c("ID"))
                
        })
dist_list

dist_df <- data.table::rbindlist(dist_list, use.names=TRUE)
# dist_df <- do.call(rbind,lapply(dist_list,data.frame))
# dist_df <- do.call(rbind.data.frame, dist_list)
dist_df$tag_id <- rep(names(dist_list), each=sapply(dist_list,nrow))
dist_sf <- st_as_sf(dist_df, sf_column_name = "geometry")
dist_sf_wgs84 <- st_transform_4326(dist_sf)

# plot
#view the protected areas on a map
tmap_mode("view")
tm_shape(MPAs) +
        tm_polygons(col = "olivedrab2",
                    alpha = 0.3)+
        #tm_borders(col = "forestgreen")+
        tm_shape(dist_sf_wgs84)+
        # tm_dots(size = 0.5,
        #            shapes = 4,
        #            alpha = 0.2,
        #            col = "salmon")+
        tm_text("NAME")+
        tm_shape(last_pts)+
        tm_dots(size = 0.7,
                col = "blue",
                shapes = 15,
                alpha = 0.4)+
        tm_text("tag_id", col = "white")
        #tm_text("distance_m")

dist_no_geom <- dist_df %>% dplyr::select(-geometry)
write.csv(dist_df, "./data/dist_no_geom_no_points_greater_6point5km2.csv")
