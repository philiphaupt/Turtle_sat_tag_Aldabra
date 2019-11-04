#read in data files on turtle movement

#libraries
library(tidyverse)
library(data.table)
library(sf)
# Data is stored in:
data_dir <-
        "E:/gis/GISDATA/ALDABRA/working files/turtle/sat_tag_data/tmp_last_pts/"

list_files <- list.files(data_dir) %>%
        as_tibble() %>%
        rename(file_name = value)
#dplyr::filter(grepl(".dbf",file_name)) %>%
#dplyr::filter(grepl("points", file_name)) #%>%
#as.list(list_files)

#define data frame in which data will be stored
turtle_pts <- data.frame()

for (i in 1:nrow(list_files)) {
        dbf_tmp <- sf::read_sf(paste0(data_dir, list_files[i, ]))
        dbf_tmp2 <- dbf_tmp %>% 
                #st_set_geometry(NULL) %>%
                dplyr::select(tag_id, utc, POSIX, local_time, POSIX_1)
        turtle_pts <-
                rbindlist(list(turtle_pts, dbf_tmp2), use.names = T) #for each iteration, bind the new data to the building dataset
}

frst_lst_pts <-
        turtle_pts %>% dplyr::filter(tag_id < 108798 | tag_id > 108798) %>%
        dplyr::filter(tag_id < 108796 | tag_id > 108796) %>% 
        st_as_sf()
write.csv(frst_lst_pts, "./valid_first_last_pts.csv")

frst_lst_pts <- read.csv("./valid_first_last_pts.csv")

frst_lst_pts$st_time <-
        as.Date(frst_lst_pts$utc, origin = "2011-11-01")

frst_lst_pts$newdate <-
        strptime(as.character(frst_lst_pts$utc), "%Y-%m-%d")
frst_lst_pts$newdate2 <-
        strptime(as.character(frst_lst_pts$utc), "%d/%m/%Y")
frst_lst_pts %>% unite(col = "newdate3", newdate:newdate2, sep = "")
frst_lst_pts$newdate[is.na(frst_lst_pts$newdate)] <- ""
strftime(x = frst_lst_pts$utc, tz = "UTC", format = "%Y-%m-%d %H:%M:%S")



frst_lst_pts %>% group_by(tag_id) %>%
        summarise(days = utc[, 1] - utc[, 2])
