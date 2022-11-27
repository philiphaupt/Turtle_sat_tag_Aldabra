# Check on speed of 108800
# Look at date and area

dat_108800 <- turtle_pts_sf_utm38s %>% filter(tag_id == 108800) %>% select(utc, utc_fixed)
