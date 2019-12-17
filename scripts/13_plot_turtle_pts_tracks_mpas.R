# plot map for publication
library(tmap)
library(tidyverse)
library(sf)
library(spData)
library(spDataLarge)

# Read in data
# read MPAs and admin areas
MPAs_minus_land <-
        read_rds("./data/preprocessed/MPAs_minus_land.rds")
admin_areas_proj <- read_rds("./data/admin_areas_proj.rds")

# Read in turtle points and tracks/lines
turtle_points_start_to_end <-
        read_rds("./data/turtle_points_start_to_end.rds")
turtle_lines <- read_rds("./data/turtle_lines.rds")

# Read in EEZs
eez_dir <- "./data/World_EEZ_v11_20191118_gpkg/" #E:/stats/aldabra/turtles/turtles_ald_sat_tag_2011_2014/Turtle_sat_tag_Aldabra
eez <- read_sf(paste0(eez_dir,"eez_boundaries_v11.gpkg"))

# plot: Mpa showing the turtle tracks and points from START to FINISH: Defined (as earlier) as the last point inside the MPA to the first point at the feeding ground.
# sepia colours emulating ESRI world map in tmap_mode("view")
tmap::tmap_mode("plot")
data("world")
st_crs(world)
tm_shape(world)+
        tm_polygons()+
        tm_graticules()

turtle_track_map <- world %>% 
        dplyr::filter(!name_long == "Somalia") %>% 
        tm_shape(bbox=tmaptools::bb(matrix(c(35,-17,60, 5),2,2))) +
        tm_fill("cornsilk2") +
        tm_shape(admin_areas_proj) +
        tm_graticules(alpha = 0.2,
                      labels.size = 0.85) +
        tm_borders(col = "lemonchiffon4",
                   lwd = 0.1) +
        tm_fill("cornsilk2") +
        tm_text(
                text = "NAME_0",
                size = 0.65,
                col = "gray47",
                case = "upper",
                auto.placement = FALSE,
                just = "left"
        ) +
        MPAs_minus_land %>%
        dplyr::rename(`IUCN category` = IUCN_CAT) %>%
        tm_shape() +
        tm_borders(col = "forestgreen") +
        tm_fill(col = "IUCN category",
                palette = "-BuGn",
                alpha = 0.9) +
        turtle_lines[c(1, 2, 3, 4, 5, 7, 8), ] %>%
        dplyr::rename(`Turtle tag ID` = tag_id) %>%
        tm_shape() +
        tm_lines(
                col = "Turtle tag ID",
                palette = "Accent",
                lwd = 2.5,
                alpha = 0.95
        ) +
        turtle_points_start_to_end %>%
        tm_shape() +
        tm_symbols(
                col = "tag_id",
                palette = "Accent",
                scale = .2,
                size = 6.5,
                alpha = 0.95,
                legend.col.show = FALSE
        ) +
        tm_layout(
                bg.color = "gray82",
                legend.outside = TRUE,
                legend.title.size = 1.5,
                legend.frame = TRUE,
                legend.bg.color = "white",
                legend.text.size = 1
        )
turtle_track_map

tmap_save(turtle_track_map, "./turtle_track_map.png", width = 12, height = 7.5, units = "cm", dpi = 500)


#----------
#black and white
turtle_track_map_bw <- world %>% 
        dplyr::filter(!name_long == "Somalia") %>% 
        tm_shape(bbox=tmaptools::bb(matrix(c(37,-15,58, 3),2,2))) +
        tm_fill("gray87") +
        tm_shape(eez)+
        tm_borders("dotdash") +
        tm_shape(admin_areas_proj) +
        tm_graticules(alpha = 0.2,
                      labels.size = 0.85,
                      col = "gray87") +
        tm_polygons() +
        tm_text(
                text = "GID_0",
                size = 0.65,
                col = "gray47",
                case = "upper",
                auto.placement = FALSE,
                just = "left"
        ) +
        MPAs_minus_land %>%
        dplyr::rename(`IUCN category` = IUCN_CAT) %>%
        tm_shape() +
        tm_borders(col = "black",
                   lty = "dashed") +
        tm_fill(col = "white") +
        turtle_lines[c(1, 2, 3, 4, 5, 7, 8), ] %>%
        dplyr::rename(`Turtle tag ID` = tag_id) %>%
        tm_shape() +
        tm_lines(
                col = "Turtle tag ID",
                palette = "gray",
                lwd = 2.5,
                alpha = 0.95
        ) +
        turtle_points_start_to_end %>%
        tm_shape() +
        tm_symbols(
                col = "tag_id",
                shape = "tag_id",
                shapes = c(15,16,17,18,19,20,3,10),
                palette = "gray",
                scale = .2,
                size = 6.5,
                alpha = 0.95,
                legend.col.show = FALSE
        ) +
        tm_layout(
                bg.color = "white",
                legend.outside = TRUE,
                legend.title.size = 1.5,
                legend.frame = TRUE,
                legend.bg.color = "white",
                legend.text.size = 1
        )

tmap_save(turtle_track_map_bw, "./turtle_track_map_bw.png", width = 16, height = 10, units = "cm", dpi = 300)

#----------------------
#----------
#black and white - without "NOt reported" IUCN category MPAs: just for viewing at this stage

# turtle_track_map_bw_2 <- world %>% 
#         dplyr::filter(!name_long == "Somalia") %>% 
#         tm_shape(bbox=tmaptools::bb(matrix(c(35,-17,60, 5),2,2))) +
#         tm_fill("gray87") +
#         tm_shape(admin_areas_proj) +
#         tm_graticules(alpha = 0.2,
#                       labels.size = 0.85,
#                       col = "gray87") +
#         tm_polygons() +
#         tm_text(
#                 text = "NAME_0",
#                 size = 0.65,
#                 col = "gray47",
#                 case = "upper",
#                 auto.placement = FALSE,
#                 just = "right"
#         ) +
#         MPAs_minus_land %>%
#         dplyr::filter(!IUCN_CAT == "Not Reported") %>% 
#         dplyr::rename(`IUCN category` = IUCN_CAT) %>%
#         tm_shape() +
#         tm_borders(col = "forestgreen") +
#         tm_fill(col = "IUCN category",
#                 palette = "-BuGn",
#                 alpha = 0.9) +
#         turtle_lines[c(1, 2, 3, 4, 5, 7, 8), ] %>%
#         dplyr::rename(`Turtle tag ID` = tag_id) %>%
#         tm_shape() +
#         tm_lines(
#                 col = "Turtle tag ID",
#                 palette = "Accent",
#                 lwd = 2.5,
#                 alpha = 0.95
#         ) +
#         turtle_points_start_to_end %>%
#         tm_shape() +
#         tm_symbols(
#                 col = "tag_id",
#                 palette = "Accent",
#                 scale = .2,
#                 size = 6.5,
#                 alpha = 0.95,
#                 legend.col.show = FALSE
#         ) +
#         tm_layout(
#                 bg.color = "white",
#                 legend.outside = TRUE,
#                 legend.title.size = 1.5,
#                 legend.frame = TRUE,
#                 legend.bg.color = "white",
#                 legend.text.size = 1
#         )
