#read in data files on turtle movement

#libraries
library(tidyverse)
library(data.table)
library(foreign)
# Data is stored in:
data_dir <- "E:/gis/GISDATA/ALDABRA/working files/turtle/sat_tag_data/"

list_files <- list.files("E:/gis/GISDATA/ALDABRA/working files/turtle/sat_tag_data") %>% 
        as_tibble() %>% 
        rename(file_name = value) %>% 
        dplyr::filter(grepl(".dbf",file_name)) %>% 
        dplyr::filter(grepl("points", file_name)) #%>% 
        #as.list(list_files)

#define data frame in which data will be stored
turtle_pts <- data.frame()

for (i in nrow(list_files)) {
        dbf_tmp <- foreign::read.dbf(paste0(data_dir,list_files[i,]))
        #dbf_tmp2 <- foreign::read.dbf(paste0(data_dir,list_files[2,]))
        turtle_pts <- rbindlist(list(turtle_pts, dbf_tmp), use.names = T) #for each iteration, bind the new data to the building dataset
}
