library(curl)
library(sf)
library(wdpar)
library(tidyverse)
library(ggmap)


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

plot(st_geometry())


# union - needs fixing - somthing not quite right
pa_aoi <- st_union(call(country_list[2:8]))
pa_aoi <- st_union(Tanzania, Mozambique, Comoros,Kenya, Seychelles, Mauritius,  Madagascar)




# plot data
plot(st_geometry(pa_aoi))
