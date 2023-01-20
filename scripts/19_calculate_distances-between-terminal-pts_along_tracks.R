# aim calculate the minumim and maximum distances of terminal points
library(tidyverse)
library(sf)

names(turtle_pts)
turtle_pts$geometry


turtle_pt_sf <- turtle_pts %>% sf::st_as_sf()


terminal_pts <- turtle_pt_sf %>% 
        arrange(tag_id,desc(local_fixed)) %>% 
        group_by(tag_id) %>% 
        slice(1)
        
terminal_pts <- terminal_pts %>% sf::st_set_crs(4326)
terminal_pts_utm <- st_transform(terminal_pts, 32738)

distances_between_terminal_pts <- st_distance(terminal_pts) %>% as_tibble()
names(distances_between_terminal_pts) <- as.character(unique(turtle_pts$tag_id))#turtle_pts %>% st_drop_geometry() %>% dplyr::select(tag_id = as.character(tag_id)) %>% unique() %>% unlist()#distinct(tag_id_chr = as.character(tag_id)) %>% ungroup() %>% dplyr::select(tag_id_chr)
row.names(distances_between_terminal_pts) <- as.character(unique(turtle_pts$tag_id))
distances_between_terminal_pts %>% pivot_longer(names_to = tad_id, )


sapply(distances_between_terminal_pts, function(x) min(as.numeric(x)) )  
sapply(distances_between_terminal_pts, function(x) max(as.numeric(x)) )  
