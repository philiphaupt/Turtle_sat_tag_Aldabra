# Aim plot turtle points using lc to set set the visual properties as "lc" is the spatial accuracy of the satellite tag 
mpa_new %>%
        tm_shape() +
        tm_borders("black") +
        turtle_pts_sf %>% 
        filter(lc > 0) %>% 
        tm_shape() +
        tm_symbols(
                col = "lc",
                palette = "Accent",
                scale = .2,
                n = 3,
                alpha = 0.9
        ) +
        turtle_pts_sf %>% 
        filter(lc == 0) %>% 
        tm_shape() + 
        tm_symbols(
                col = "red",
                scale = .4,
                n = 1,
                alpha = 0.6
        )

# it appears that all the red points (lc == 0) are plotting near to other points, anddo not detract or obscure the results - these points were therefore kept in