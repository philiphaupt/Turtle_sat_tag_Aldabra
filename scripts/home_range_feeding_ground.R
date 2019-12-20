# AIM: Determine the "home range during breeding, travelling and feeding"

# partion the data into sets, starting  with feeding grounds and apply the convex hull function

library(sf)
library(tidyverse)

# st_convex_hull(x)

st_convex_hull(feeding_ground_pts)