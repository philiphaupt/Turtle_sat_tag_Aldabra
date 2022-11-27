# Aim: Determine the number of turtles that have returned from the total (unique) individual turtles which have been tagged at Aldabra in 2014.
# Author: Philip Haupt
# Date: 2020-04-14
# Method: 
# Assumption: To qualify as a resighting a turtle has to have spent a minimum time of at least 12 months(?) away from Aldabra. Literautre and previous data searches have suggested 2 -3 years, but by using 12 months any returness in say 18 months would also be detected (and is potentially interesting)

# Get the total number of turtles that resighted in 2014 and previously have been fitted with tags.
# Caveat turtles resighted in 2014 (early months like Jan - March, may have been tagged in late 2013 like Nov - December, and tehrefore are not actal resightings.)


library(tidyverse)
library(lubridate)

# The data file name with all the data that Heather sent to me is: "Tag search database_nesting - updated until 31Dec2014.xls"
# See email: 
# from:	Heather Richards <richardsheatheranne@gmail.com>
#         to:	Philip Haupt <philip.haupt@gmail.com>
#         date:	13 Apr 2020, 21:34
# subject:	All tagging data

# I downloaded the data file and stored in:  list.files("./data/input/")
filename <- "Tag search database_nesting - updated until 31Dec2014.xls"

# read in the data
flipper_tags <- readxl::read_excel(paste0("./data/input/",filename))

# what are the column names?
names(flipper_tags)

# Add a date column, to correct/construct dates for the 2014 data
flipper_tags$date_complete <- paste(flipper_tags$Year, flipper_tags$Month, flipper_tags$Day, sep = "-")
flipper_tags$date_corrected <- parse_date_time(flipper_tags$date_complete, c("%Y-%m-%d", "%d/%m/%Y")) # ensures that the new format is British & consistent with the way it was input for sattelite tags in this study.


# Does the turtle have a tag on any of its flippers
previously_tagged <- flipper_tags %>% 
        filter(`New?` == "No" | `New` == "No" ) %>% 
        dplyr::select(year = Year, date_corrected, tag_num_r = `Tag R#`, tag_num_l = `Tag L#`)

# spread data for inspection
data_check <- previously_tagged %>%
        select(date_corrected, tag_num_r, tag_num_l) %>% 
        pivot_wider(names_from = tag_num_r, values_from = tag_num_l)


#  subset of 2014 data and the rest
dat_2014 <- previously_tagged %>% filter(year == 2014)
dat_before_2014 <- previously_tagged %>% filter(year != 2014)


# join the data to find tags that match between the before and after 2014 data sets
resight_1_right <- left_join(dat_2014, dat_before_2014, by = ("tag_num_r"), suffix = c("_aft2014", "_bef2014")) %>% 
        distinct() %>% 
        arrange(tag_num_r, date_corrected_aft2014)
resight_1_left <- left_join(dat_2014, dat_before_2014, by = ("tag_num_l"), suffix = c("_aft2014", "_bef2014")) %>% 
        distinct() %>% 
        arrange(tag_num_l, date_corrected_aft2014)


        
# Remove turtles tagged in 2014, but not seen longer ago than 18 months
# 1) add a column showing the difference in the number of month
# 2) filter for those > 18 months.
# This will leave two data sets which needs amalgamting - and probably could be done through a full or an inner join and filtering process.

resight_1_right$date_dif <- resight_1_right$date_corrected_aft2014 - resight_1_right$date_corrected_aft2014 #r date calculations subtract two dates
resight_1_right$date_dif <- difftime(as.POSIXct(resight_1_right$date_corrected_aft2014), as.POSIXct(resight_1_right$date_corrected_aft2014), units="days")
