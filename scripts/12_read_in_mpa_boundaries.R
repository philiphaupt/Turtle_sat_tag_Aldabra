library(curl)
library(sf)
library(wdpar)
library(tidyverse)
library(ggmap)
library(lwgeom)
library(countrycode)

# USER Defined list of countries for which to obtain protected areas:
my_country_list <- c("Somalia", "Tanzania", "Mozambique", "Comoros","Kenya", "Seychelles", "Mauritius",  "Madagascar")

# Define the list of ISO3 country codes: this will alloweasier matching when adminstrative boundaries need to be matches to the protected areas gievn the ISO 3 codes used in the file names of admininstrative boundaries
my_country_codes <- list()
for (k in seq_along(my_country_list)) {
        my_country_codes[k] <- countrycode::codelist$iso3c[codelist$country.name.en[1:length(codelist$country.name.en)] == my_country_list[k]]
}

#combine these list into a single dataframe called my_countries_df, and remove superflous r objects
my_country_list_df <- data.frame(matrix(unlist(my_country_list)), stringsAsFactors = FALSE)
my_country_codes_df <- data.frame(matrix(unlist(my_country_codes)), stringsAsFactors = FALSE)
my_countries_df <- cbind(my_country_list_df, my_country_codes_df)
names(my_countries_df) <- c("country_name", "country_code")
rm(my_country_list_df, my_country_codes_df)
my_country_codes <- unlist(my_country_codes)

#--------------------------------
# Add protected areas to map through live link to https://www.protectedplanet.net/marine


# find url for each of the user selected coutries in my_country_list
download_urls <- list()
for (i in seq_along(my_country_list)) {
        download_urls[i] <- wdpa_url(my_country_list[i], wait = TRUE)
}

# add country names and codes tot eh urls in a new data frame
download_urls_df <- as.data.frame(matrix(unlist(download_urls), nrow=length(download_urls),byrow = TRUE), stringsAsFactors = FALSE)
download_urls_df <- cbind(download_urls_df, my_countries_df)
download_urls_df <- download_urls_df %>% dplyr::rename(url = V1)
download_urls_df$url <- as.character(download_urls_df$url) # make sure urls are character


# paths to save file zipfile with data: Currently this a temporary file location: May want to copy a "fixed version" to ensure tha this can be exactly replicated
path <- tempfile(pattern = paste0("WDPA_",download_urls_df$country_code,"_"), fileext = ".zip")

# download zipfile
downloaded_zip_files <- list()
for (h in 1:(nrow(download_urls_df))) {
        downloaded_zip_files[h] <- httr::GET(download_urls_df[h,1], httr::write_disk(path[h], overwrite = TRUE))
}

# load data (downloaded files of MPA boundaries) into R environment
shps <- lapply(path, function(x) {wdpar::wdpa_read(x)}) 

#assign the country names to each sf object
# names(shps) <- my_country_list
names(shps) <- my_countries_df$country_code
purrr::map(shps, names)

#--------------------------------------------------
SOM_clean <- wdpa_clean(shps[1]) # Somalia is the problematic country
shps_clean <- purrr::map(.x = shps[2:8], .f = wdpa_clean) #error message
#--------------------------------------------------

# seperate list into shapes and apply st_union *super handy remember this function!
list2env(shps_clean,globalenv()) # The objects in the list have to be named to work!
list2env(shps[1],globalenv())

#plot(st_geometry())


# union - needs fixing - somthing not quite right
#pa_aoi <- st_union(call(as.vector(my_countries_df[2:8,2])))
my_countries_mpa_union <- sf::st_union(TZA, MOZ, COM, KEN, SYC, MUS, MDG)


# plot data
# plot(st_geometry(my_countries_mpa_union))


#---------------------------------------------
# Choose only relevant MPAs

# 1. clip to marine areas
## 1.1 Manually dowload administrative boundaries for the coutnries in my list:
## from: https://gadm.org/data.html : Select the data tab, a menu with a drop down list appears, where you can select the country that you want to download, and the different levels: level 0 (lowest level of detail is needed) 
## NB! To automate: When you hovver over the format that you want to download, the www address for the actual file appears - lets use this with pattern recognition to download the files that we need.

#path to gadm files
path_gadm <- tempfile(pattern = paste0("gadm36_", my_country_codes,"_0_sf"), fileext = ".rds")


downloaded_urls_gadm <- list()
for (m in seq_along(my_country_codes)) {
        downloaded_urls_gadm[m] <- paste0("https://biogeo.ucdavis.edu/data/gadm3.6/Rsf/gadm36_", my_country_codes[m] ,"_0_sf.rds")
        #downloaded_gadm_files[m] <- httr::GET(downloaded_urls_gadm[m], httr::write_disk(path_gadm[m], overwrite = TRUE))
}

downloaded_gadm_files <- list()
for (n in seq_along(my_country_codes)) {
        #downloaded_urls_gadm[m] <- paste0("https://biogeo.ucdavis.edu/data/gadm3.6/Rsf/gadm36_", my_country_codes[m] ,"_0_sf.rds")
        downloaded_gadm_files[n] <- httr::GET(downloaded_urls_gadm[[n]], httr::write_disk(path_gadm[n], overwrite = TRUE))
}


# load data (downloaded files of MPA boundaries) into R environment
shps_gadm <- lapply(path_gadm, function(x) {read_rds(x)}) 


########## START HERE - this will save re-downloading all the files - temp
write_rds(shps_clean, "./data/preprocessed/shps_clean.rds")
write_rds(shps_gadm, "./data/preprocessed/shps_gadm.rds")
#--------------------



## countries are in the input folder
# gadm_dir <- "E:/stats/aldabra/turtles/turtles_ald_sat_tag_2011_2014/Turtle_sat_tag_Aldabra/data/gadm_countries/"
# gadm_files <- list.files(gadm_dir)

gadms_clean <- list()
# gadms_union <- as_Spatial()
for (i in seq_along(shps_gadm)) {
        gadms_clean[i] <- shps_gadm[[i]] %>% 
                #st_as_sf %>% 
                st_set_precision(1000) %>%
                lwgeom::st_make_valid() %>%
                st_set_precision(1000) %>%
                st_combine() %>%
                st_union() %>%
                st_set_precision(1000) %>%
                lwgeom::st_make_valid() %>%
                st_transform(st_crs(SYC)) %>%
                lwgeom::st_make_valid()
        # gadms_union <- sf::st_union(gadms[i],gadms_union)
        
}

gadms_union <- map(gadms, st_union)
gadms_union <- st_union(gamds)

#TRY THIS:
# library(raster)
# misc = list()
# misc$countries = c("ZAF", "LSO", "SWZ", "ZWE", "MOZ", "NAM", "BWA")
# ctry_shps = do.call("bind", lapply(misc$countries, 
#                                    function(x) getData('GADM', country=x, level=0)))




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
#test

names(shps_gadm) <- paste0(my_country_codes, "_gadm")

list2env(shps_gadm,globalenv())

class(KEN)
class(KEN_gadm)

KEN_gadm <- st_as_sf(KEN_gadm)

st_set_crs(KEN,KEN_gadm)
st_crs(shps_gadm[[5]])
st_transform(KEN)#START HERE
 KEN_MPA <- KEN %>%
         filter(MARINE == "terrestrial") %>%
         st_intersection(shps_gadm[[5]]) %>%
         rbind(KEN_MPA %>%
                       filter(MARINE == "marine") %>%
                       st_difference(shps_gadm[[5]])) %>%
         rbind(KEN_MPA %>% filter(!MARINE %in% c("terrestrial",
                                                     "marine")))
 