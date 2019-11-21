# AIM: Plot STARTING POINT (blue) as LAST points inside MPA and terminal (absolut last transmission in red); END POINT (Green) as the first point inside 6500 m of the terminal point.

#read in data already preprared in previous steps - see earlier files for their prep
mpa_new <- read_rds("./data/mpa_new.rds")
turtle_pts_sf <- read_rds("./data/turtle_pts_sf.rds")
last_pts_inside_mpa <- read_rds("./data/last_pts_inside_mpa.rds")
last_pts_buffer <- read_rds("./data/last_pts_buffer.rds")
last_pts <- read_rds("./data/last_pts.rds")
feeding_ground_pts_first <- read_rds("./data/feeding_ground_pts_first.rds")

#plot
last_pts_buffer %>% 
        tm_shape() +
        tm_borders("black", lty = "dashed") +
        tm_shape(turtle_pts_sf) +
        tm_symbols(col = "grey",
                   scale = .05,
                   size = 0.1,
                   alpha = 0.1) +
        tm_shape(mpa_new) +
        tm_borders("black") +
        tm_shape(last_pts_inside_mpa) +
        tm_symbols(
                col = "blue",
                scale = 0.05,
                alpha = 0.5,
                size = 0.2
        ) +
        tm_text("tag_id") +
        tm_shape(last_pts) +
        tm_symbols(
                col = "red",
                scale = 0.05,
                alpha = 0.5,
                size = 0.2
        ) +
        tm_text("tag_id") +
        tm_shape(last_pts_buffer) +
        tm_borders(col = "black",
                   lty = "dashed") +
        tm_shape(feeding_ground_pts_first) +
        tm_symbols(
                col = "forestgreen",
                scale = .05,
                alpha = .9,
                size = 0.1
        )