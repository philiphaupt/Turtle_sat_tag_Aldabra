# Aim: Visual comparison of using firs point outside MPA and last point inside MPA as starting point

#read in data already preprared in previous steps - see earlier files for their prep
first_pts_outside_mpa <- read_rds("./data/first_pts_outside_mpa.rds")
mpa_new <- read_rds("./data/mpa_new.rds")
turtle_pts_sf <- read_rds("./data/turtle_pts_sf.rds")
last_pts_inside_mpa <- read_rds("./data/last_pts_inside_mpa.rds")


# Plot BOTH sets of starting point shown:  STARTING POINT as: last point inside MPA
tm_shape(first_pts_outside_mpa) +
        tm_symbols(
                col = "red",
                scale = 0.5,
                alpha = 0.5,
                size = 2
        ) +
        tm_text("tag_id")+
        mpa_new %>%
        tm_shape() +
        tm_borders("black",
                   lty = "dashed") +
        turtle_pts_sf %>% 
        tm_shape() +
        tm_symbols(
                col = "grey",
                size = 0.3,
                scale = .5,
                alpha = 0.1
        ) +
        tm_shape(last_pts_inside_mpa) +
        tm_symbols(
                col = "blue",
                scale = 0.5,
                alpha = 0.5,
                size = 2
        ) +
        tm_text("tag_id")
        
# DECISION: IT makes sense to use the LAST POINT inside the MPA as the starting point! The dispalcement is massive for some of the first points outside the MPA as it is days after their last transmission from inside the MPAs, and therefore a significant distance has been covered in some instances.




