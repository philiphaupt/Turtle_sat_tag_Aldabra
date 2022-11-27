# plot map for publication
library(tmap)
library(tidyverse)
library(sf)
library(spData)
library(spDataLarge)

# Read in data
# read MPAs and admin areas
MPAs <-
        read_rds("./data/MPAs.rds")
admin_areas_proj <- read_rds("./data/admin_areas_proj.rds")


# add text label positon column
admin_areas_proj$x_mod <- 0
admin_areas_proj$x_mod[admin_areas_proj$GID_0 == "SOM"] <- -4.8
admin_areas_proj$y_mod <- -1
admin_areas_proj$y_mod[admin_areas_proj$GID_0 == "MDG"] <- +4.8
admin_areas_proj$y_mod[admin_areas_proj$GID_0 == "SOM"] <- -5.8
admin_areas_proj$y_mod[admin_areas_proj$GID_0 == "MOZ"] <- +5.6

# Read in turtle points and tracks/lines
turtle_points_start_to_end <-
        read_rds("./data/turtle_points_start_to_end.rds")
turtle_lines <- read_rds("./data/turtle_lines.rds")

# Read in EEZs
eez_dir <-
        "./data/World_EEZ_v11_20191118_gpkg/" #E:/stats/aldabra/turtles/turtles_ald_sat_tag_2011_2014/Turtle_sat_tag_Aldabra
eez <- read_sf(paste0(eez_dir, "eez_boundaries_v11.gpkg"))

# plot: The turtle tracks and points from START to FINISH: Defined (as earlier) as the last point inside the MPA to the first point at the feeding ground.
# Shapes: bbox, eez, admin_areas_proj, mpas, turtle_lines, turtle_points_start_to_end
# style black and white

#----------
#black and white
turtle_track_map_bw <- world %>%
        dplyr::filter(!name_long == "Somalia") %>%
        tm_shape(bbox = tmaptools::bb(matrix(c(35, -16, 58, 3), 2, 2))) +
        tm_fill("gray87") +
         tm_shape(eez)+
         tm_lines(col = "gray",
                  alpha = 0.5,
                  lty = "dotdash") +
        tm_shape(admin_areas_proj) +
        tm_graticules(
                alpha = 0.2,
                labels.size = 0.85,
                col = "white",
                n.x = 5,
                n.y = 5
        ) +
        tm_polygons() +
        tm_text(
                text = "NAME_0",
                size = 0.65,
                col = "gray47",
                case = "upper",
                auto.placement = FALSE,
                just = "left",
                ymod = "y_mod",
                xmod = "x_mod"
        ) +
        turtle_lines[c(1, 2, 3, 4, 5, 7, 8),] %>%
        dplyr::rename(`Turtle tag ID` = tag_id) %>%
        tm_shape() +
        tm_lines(
                col = "Turtle tag ID",
                palette = "gray",
                lwd = 1.5,
                alpha = 0.85
                # legend.show = FALSE
        ) +
        # MPAs %>%
        # dplyr::rename(`IUCN category` = IUCN_CAT) %>%
        # tm_shape() +
        # tm_borders(col = "black",
        #            lty = "dashed") +
        # tm_fill(col = "white",
        #         alpha = 0) +
        turtle_points_start_to_end %>%
        dplyr::rename(`Turtle tag ID` = tag_id) %>% 
        tm_shape() +
        tm_symbols(
                col = "black",
                shape = "tag_id",
                shapes = c(1, 15, 16, 17, 18, 19, 6, 3, 10),
                #palette = "gray",
                scale = .2,
                size = 3.5,
                alpha = 0.95,
                legend.col.show = FALSE
        ) +
        tm_layout(
                bg.color = "white",
                legend.outside = TRUE,
                legend.title.size = 1.3,
                legend.frame = TRUE,
                legend.bg.color = "white",
                legend.text.size = 1
        )
turtle_track_map_bw

tmap_save(
        turtle_track_map_bw,
        "./turtle_track_map_bw_eez.png",
        width = 16,
        height = 10,
        units = "cm",
        dpi = 300
)
