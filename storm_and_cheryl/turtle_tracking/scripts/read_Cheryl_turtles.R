library(tidyverse)
library(readxl)
library(sf)
bonanna_all <-
  readxl::read_excel("./data/cheryl/raw/Bonanna_all.xlsx")
bonanna_cln <-
  readxl::read_excel("./data/cheryl/clean/Bonanna_cleaned.xlsx")

# Question who was cleaning done?
bonanna_all %>% dplyr::distinct(`GPS Fix Attempt`)
bonanna_cln %>% dplyr::distinct(`GPS Fix Attempt`)

# Read all Cheryl clean files
cheryl_files <- list.files("./data/cheryl/clean", full.names = TRUE)
cheryl_data <- map(cheryl_files, read_xlsx)

# Read Cheryl RAW data for comparison
# cheryl_files_raw <- list.files("./data/cheryl/raw", full.names = TRUE)
# cheryl_data_raw <- map(cheryl_files_raw, read_xlsx)

# give a name to each tables
names(cheryl_data) <- str_sub(list.files("./data/cheryl/clean"),
                              1,
                              str_locate(list.files("./data/cheryl/clean"), "_")[2, 2]) %>%
  tolower()

turtle_name_fn <-
  function(x = "./data/cheryl/clean") {
    str_sub(list.files(),
            1,
            str_locate(list.files(), "_")[2, 2]) %>%
      tolower()
  }


# provide simpler column names
cheryl_data_cln <-
  map(
    cheryl_data,
    dplyr::rename,
    date_time = `GPS fix time`,
    lat = `GPS Latitude`,
    long = `GPS Longitude`
  )


cheryl_data_cln <-
  map(cheryl_data_cln, dplyr::mutate, turtle  = turtle_name_fn())

# output csv
walk(cheryl_data_cln, write_csv(paste0("turtle_sat_tag_dat_",names()),.))

# library(readr)
# 
# files_to_read[1:4] %>% 
#   purrr::map(~read_csv(.x) %>%  
#                geocode(Combine_Address) %>% 
#                write_csv(sprintf('geocode_output_%s_geocode.csv', basename(.x))))
# Make each table a sf object
cheryl_data_cln_sf <-
  map(cheryl_data_cln,
      sf::st_as_sf,
      coords = c("long", "lat"),
      crs = "+proj=longlat +datum=WGS84")
cheryl_data_cln_sf %>% map( ~ as.data.frame(.x), .id = "years")

# test plot
map(, write_sf(),)
sf::st_write(cheryl_data)