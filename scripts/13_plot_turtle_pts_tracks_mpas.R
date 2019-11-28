# plot map for publication
library(tmap)
library(tidyverse)

# read in data
# MPAs and admin areas
MPAs_minus_land <- read_rds("./data/preprocessed/MPAs_minus_land.rds")
admin_areas <- read_rds("./data/preprocessed/admin_areas.rds")

# turtle tracks
#read in data already preprared in previous steps - see earlier files for their prep
turtle_pts_sf <- read_rds("./data/turtle_pts_sf.rds")
last_pts_inside_mpa <- read_rds("./data/last_pts_inside_mpa.rds")
last_pts_buffer <- read_rds("./data/last_pts_buffer.rds")
last_pts <- read_rds("./data/last_pts.rds")
feeding_ground_pts_first <- read_rds("./data/feeding_ground_pts_first.rds")
sf::st_write(turtle_lines, "turtle_points_start_to_end.gpkg", layer = "plotting_lines", layer_options = c("update = TRUE"))


#plot
tmap::tmap_mode("plot")
tmap::tm_shape(admin_areas_proj) +
        tmap::tm_borders(col = "brown") +
        tmap::tm_fill("sand")+
        tm_text(text = "NAME_0") +
        tm_graticules(alpha = 0.2) +
        tmap::tm_shape(MPAs_minus_land) +
        tmap::tm_borders(col = "forestgreen") +
        tmap::tm_fill(col = "IUCN_CAT",
                      alpha = 0.5) +
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
                   alpha = 0.95) +
        tm_layout(bg.color = "grey",
                  legend.outside = TRUE)

        

