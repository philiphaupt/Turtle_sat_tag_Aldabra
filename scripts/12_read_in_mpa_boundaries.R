library(curl)
library(sf)
library(wdpar)
library(tidyverse)
library(ggmap)
library(lwgeom)
library(countrycode)
library(mapedit)
library(tmap)

# 1. Specify a list of countiries along with their ISO 3 codes
# why? this allows match these countries to online databases of administrative and protected area boundaries.



#--------------------------------------------------------------------
# USER Defined list of countries for which to obtain protected areas:
my_country_list <-
        c("Somalia",
          "Tanzania",
          "Mozambique",
          "Comoros",
          "Kenya",
          "Seychelles",
          "Madagascar")
#--------------------------------------------------------------------


# Define the list of ISO3 country codes: this will allow easier matching when adminstrative boundaries need to be matches to the protected areas gievn the ISO 3 codes used in the file names of admininstrative boundaries
my_country_codes <- list()
for (k in seq_along(my_country_list)) {
        my_country_codes[k] <-
                countrycode::codelist$iso3c[codelist$country.name.en[1:length(codelist$country.name.en)] == my_country_list[k]]
}

#combine these list into a single dataframe called my_countries_df, and remove superflous r objects
my_country_list_df <-
        data.frame(matrix(unlist(my_country_list)), stringsAsFactors = FALSE)
my_country_codes_df <-
        data.frame(matrix(unlist(my_country_codes)), stringsAsFactors = FALSE)
my_countries_df <- cbind(my_country_list_df, my_country_codes_df)
names(my_countries_df) <- c("country_name", "country_code")
rm(my_country_list_df, my_country_codes_df)
my_country_codes <- unlist(my_country_codes)


#--------------------------------
# 2. Add protected areas to map through live link to https://www.protectedplanet.net/marine
## USeful resouces for the wdpa package & how to apply it:
## https://prioritizr.github.io/wdpar/articles/wdpar.html
## https://cran.rstudio.com/web/packages/wdpar/readme/README.html

# # find url for each of the user selected coutries in my_country_list
# download_urls <- list()
# for (i in seq_along(my_country_list)) {
#         download_urls[i] <- wdpa_url(my_country_list[i], wait = TRUE)
# }
# #
# # # add country names and codes to the urls in a new data frame
# download_urls_df <-
#         as.data.frame(matrix(
#                 unlist(download_urls),
#                 nrow = length(download_urls),
#                 byrow = TRUE
#         ), stringsAsFactors = FALSE)
# 
# download_urls_df <- cbind(download_urls_df, my_countries_df)
# download_urls_df <- download_urls_df %>% dplyr::rename(url = V1)
# download_urls_df$url <-
#         as.character(download_urls_df$url) # make sure urls are character
# #
# #
# # # paths to save file zipfile with data: Currently this a temporary file location: May want to copy a "fixed version" to ensure tha this can be exactly replicated
# path <- tempfile(pattern = paste0("WDPA_",download_urls_df$country_code,"_"), fileext = ".zip")
# #
# # # download zipfile
# downloaded_zip_files <- list()
# for (h in 1:(nrow(download_urls_df))) {
#          downloaded_zip_files[h] <- httr::GET(download_urls_df[h,1], httr::write_disk(path[h], overwrite = TRUE))
# }
# #
# # # load data (downloaded files of MPA boundaries) into R environment
# pa_raw <- lapply(path, function(x) {wdpar::wdpa_read(x)})

#---SHORTER ALTERNATIVE DOWNLOAD
#

pa_raw <-
         lapply(my_country_list, function(x) {
                 wdpar::wdpa_fetch(x)
         })

# assign the country names to each sf object
names(pa_raw) <- my_country_codes
purrr::map(pa_raw, names)
purrr::map(pa_raw, class)

class_geom_in_list <- function(x) {
        x$geometry %>% class()
}
purrr::map(.x = pa_raw[1:7], .f = class_geom_in_list)

#clean data
pa_raw_clean <- purrr::map(.x = pa_raw[2:7], .f = wdpa_clean) # works

# reproject data to longitude/latitude for plotting
st_transform_4326 <- function(x) {sf::st_transform(x, crs = 4326)}
pa_clean_4326 <- purrr::map(.x = pa_raw_clean, st_transform_4326)
purrr::map(.x = pa_clean_4326, .f = class_geom_in_list)
#--------------------
# combine protected areas into a single sf object - remove Somlia: Somalia's protected areas is problematic: they are only represented by points, and none are MARINE - so answer is that it is not relvant.
protected_areas <-
        mapedit:::combine_list_of_sf(pa_clean_4326, crs = 4236) %>%
        lwgeom::st_make_valid()

#--------------------------------------------------
#SOM_clean <- wdpa_clean(pa_raw$SOM) # Somalia's protected areas is problematic: they are only represented by points, and none are MARINE - so answer is that it is not relvant.
#class(pa_raw$SOM$geometry)
#pa_raw_clean <- purrr::map(.x = pa_raw[2:7], .f = wdpa_clean) # works


#--------------------------------------------------

# seperate list into shapes and apply st_union *super handy remember this function!
# list2env(pa_raw_clean,globalenv()) # The objects in the list have to be named to work!
# list2env([1],globalenv())

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
#-------------------------------------------------------
# Choose only marine and partial marine protected areas to be included

MPAs <- protected_areas %>%
        dplyr::filter(MARINE == "marine") %>%
        lwgeom::st_make_valid() %>% 
        st_as_sf()

#view the protected areas on a map
tmap_mode("view")
tm_shape(MPAs) +
        tm_polygons()+
        tm_borders(col = "forestgreen")


#---------------------------------------------
# MPAs to remove using their WDPAID numbers
# Erroneous or dubious

MPAs <- MPAs %>% dplyr::filter(!WDPAID == 305172) %>% 
        dplyr::filter(!WDPAID == 555542730)
write_rds(MPAs, "./data/MPAs.rds")
#---------------------------------------------
# Choose only relevant MPAs

# 1. Limit the protected areas to marine areas - remove land PAs.
## 1.1 Manually dowload administrative boundaries for the coutnries in my list:
## from: https://gadm.org/data.html : Select the data tab, a menu with a drop down list appears, where you can select the country that you want to download, and the different levels: level 0 (lowest level of detail is needed)
## NB! To automate: When you hovver over the format that you want to download, the www address for the actual file appears - lets use this with pattern recognition to download the files that we need.

#path to gadm files
path_gadm <-
        tempfile(pattern = paste0("gadm36_", my_country_codes, "_0_sf"),
                 fileext = ".rds")


downloaded_urls_gadm <- list()
for (m in seq_along(my_country_codes)) {
        downloaded_urls_gadm[m] <-
                paste0(
                        "https://biogeo.ucdavis.edu/data/gadm3.6/Rsf/gadm36_",
                        my_country_codes[m] ,
                        "_0_sf.rds"
                )
        #downloaded_gadm_files[m] <- httr::GET(downloaded_urls_gadm[m], httr::write_disk(path_gadm[m], overwrite = TRUE))
}

downloaded_gadm_files <- list()
for (n in seq_along(my_country_codes)) {
        #downloaded_urls_gadm[m] <- paste0("https://biogeo.ucdavis.edu/data/gadm3.6/Rsf/gadm36_", my_country_codes[m] ,"_0_sf.rds")
        downloaded_gadm_files[n] <-
                httr::GET(downloaded_urls_gadm[[n]],
                          httr::write_disk(path_gadm[n], overwrite = TRUE))
}


# load data (downloaded files of MPA boundaries) into R environment
shps_gadm <- lapply(path_gadm, function(x) {
        read_rds(x)
})
names(shps_gadm) <- my_country_codes

# combine administrative boundaries into a single sf object
admin_areas <-
        mapedit:::combine_list_of_sf(shps_gadm, crs = 4326) %>%
        lwgeom::st_make_valid()
#-------------------------------------
#test projections match to allow clipping:
st_crs(admin_areas)
st_crs(MPAs)
admin_areas_proj <- st_transform(admin_areas,crs = st_crs(MPAs)) # reproject to match
write_rds(admin_areas_proj,"./data/admin_areas_proj.rds")
admin_areas_proj <- read_rds("./data/admin_areas_proj.rds")
# clipping to marine only

MPAs_minus_land <- st_difference(MPAs, admin_areas_proj)



tmap::tmap_mode("view")
tmap::tm_shape(admin_areas) +
        tmap::tm_borders(col = "black") +
        tmap::tm_shape(MPAs_minus_land) +
        tmap::tm_borders(col = "forestgreen") +
        tmap::tm_fill(col = "IUCN_CAT")


########## Write to R object this will save re-downloading all the files - temp
write_rds(MPAs_minus_land, "./data/preprocessed/MPAs_minus_land.rds")
write_rds(admin_areas, "./data/preprocessed/admin_areas.rds")


