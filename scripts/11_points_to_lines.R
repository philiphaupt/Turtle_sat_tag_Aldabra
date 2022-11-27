#aim points to lines for each turtle
library(tidyverse)
library(sf)
library(tmap)

#read in data
turtle_points_start_to_end <- read_rds("./data/turtle_points_start_to_end.rds")

# convert to lines
turtle_lines <- turtle_points_start_to_end %>%
        # dplyr::filter(tag_id != "108798") %>% 
        # dplyr::filter(tag_id != "108796") %>% 
        group_by(tag_id) %>% 
        summarize(.,do_union=FALSE) %>% 
        st_cast("LINESTRING")

class(turtle_lines)

#plot
turtle_lines[c(1,2,3,4,5,7,8),] %>% 
        tm_shape()+
        tm_lines(col = "tag_id",
                 palette = "Accent",
                 lwd = 2,
                   alpha = 0.95) +
        turtle_points_start_to_end %>% 
        tm_shape() +
        tm_symbols(col = "tag_id",
                   palette = "Accent",
                   scale = .2,
                   size = 2,
                   alpha = 0.95)


write_rds(turtle_lines, "./data/turtle_lines.rds")
sf::st_write(turtle_lines, "turtle_tracks_start_to_end.gpkg", layer = "plotting_lines", layer_options = c("update = TRUE"))
