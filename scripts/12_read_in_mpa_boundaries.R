library(curl)
library(sf)
library(wdpar)
library(tidyverse)
library(ggmap)
library(lwgeom)


# Add protected areas to map through live link to https://www.protectedplanet.net/marine
country_list <- c("Somalia", "Tanzania", "Mozambique", "Comoros","Kenya", "Seychelles", "Mauritius",  "Madagascar")


# find url for each of the coutries in the list dataset
# download_url <- wdpa_url(, wait = TRUE)

# download_urls <- purrr::map(.x = country_list, .f = wdpa_url())

download_urls <- list()
for (i in seq_along(country_list)) {
        download_urls[i] <- wdpa_url(country_list[i], wait = TRUE)
}

download_urls_df <- as.data.frame(matrix(unlist(download_urls), nrow=length(download_urls),byrow = TRUE))
download_urls_df$country <- unlist(country_list)
download_urls_df <- download_urls_df %>% dplyr::rename(url = V1)
download_urls_df$url <- as.character(download_urls_df$url)


# paths to save file zipfile with data
path <- tempfile(pattern = paste0("WDPA_",download_urls_df$country,"_"), fileext = ".zip")

# download zipfile
downloaded_zip_files <- list()
for (h in 1:(nrow(download_urls_df))) {
        downloaded_zip_files[h] <- httr::GET(download_urls_df[h,1], httr::write_disk(path[h], overwrite = TRUE))
}



# load data
shps <- lapply(path, function(x) {wdpar::wdpa_read(x)}) 

#assign the country names to each sf object
names(shps) <- country_list
purrr::map(shps, names)

SOM_clean <- wdpa_clean(Somalia) # Somalia is the problematic country
shps_clean <- purrr::map(.x = shps[2:8], .f = wdpa_clean) #error message


# seperate list into shapes and apply st_union *super handy remember this function!
list2env(shps_clean,globalenv()) # The objects in the list have to be named to work!
list2env(shps[1],globalenv())

#plot(st_geometry())


# union - needs fixing - somthing not quite right
pa_aoi <- st_union(call(country_list[2:8]))
pa_aoi <- st_union(Tanzania, Mozambique, Comoros,Kenya, Seychelles, Mauritius,  Madagascar)




# plot data
plot(st_geometry(pa_aoi))

## countries are in the input folder
gadm_dir <- "E:/stats/aldabra/turtles/turtles_ald_sat_tag_2011_2014/Turtle_sat_tag_Aldabra/data/gadm_countries/"
gadm_files <- list.files(gadm_dir)

gadms <- list()
# gadms_union <- as_Spatial()
for (i in seq_along(gadm_files)) {
        gadms[i] <- read_rds(paste0(gadm_dir, gadm_files[i])) %>% 
                as_Spatial() %>% 
                st_as_sf %>% 
                st_set_precision(1000) %>%
                lwgeom::st_make_valid() %>%
                st_set_precision(1000) %>%
                st_combine() %>%
                st_union() %>%
                st_set_precision(1000) %>%
                lwgeom::st_make_valid() %>%
                st_transform(st_crs(Seychelles)) %>%
                lwgeom::st_make_valid()
        # gadms_union <- sf::st_union(gadms[i],gadms_union)
                
}

gadms_union <- map(gadms, st_union)
gadms_union <- st_union(gamds)


#
# clip Malta's protected areas to the coastline
# mlt_pa_data <- mlt_pa_data %>%
#         filter(MARINE == "terrestrial") %>%
#         st_intersection(mlt_boundary_data) %>%
#         rbind(mlt_pa_data %>%
#                       filter(MARINE == "marine") %>%
#                       st_difference(mlt_boundary_data)) %>%
#         rbind(mlt_pa_data %>% filter(!MARINE %in% c("terrestrial",
#                                                     "marine")))
