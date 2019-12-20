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
        MPAs %>%
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

