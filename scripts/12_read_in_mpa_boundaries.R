library(curl)
library(sf)
library(wdpar)
library(tidyverse)
library(ggmap)

# Add protected areas to map through live link to https://www.protectedplanet.net/marine

# find url for Liechtenstein dataset
download_url <- wdpa_url("LIE", wait = TRUE)

# path to save file zipfile with data
path <- tempfile(pattern = "WDPA_", fileext = ".zip")

# download zipfile
result <- httr::GET(download_url, httr::write_disk(path))

# load data
lie_raw_data <- wdpa_read(path)

# plot data
plot(lie_raw_data)