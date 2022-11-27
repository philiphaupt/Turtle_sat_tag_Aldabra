# Area calculation for st_buffer 6500

# Does this really reflect the final stop over, or is it actually still mooching along the coastline?
# How do we know, given that other authors have shown smaller home ranges for green turtles?
#

library(units)
library(sf)


# read in buffer 6500 m

last_pts_buffer <- read_rds("./data/last_pts_buffer.rds") # the redius is 6500 m
# plot(st_buffer(st_point(0:1), dist = 1), axes = TRUE) # to test

# calcuate the area in square meters
area_buffer <- st_area(last_pts_buffer[1,]) # just need one row

# convert to square kilometer
units(area_buffer) <- with(ud_units, km^2)

# convert to hectares
units(area_buffer) <- with(ud_units, ha)
