# Aim: Define whichturtles have returned to ALdabra after being flipper tagges

library(tidyverse)
library(readxl)


# Read in the flpper tagging data
flipper_tags <- readxl::read_excel("./data/input/tagged turtles 2014 all.xlsx")

# Unique turtles
unique_turtles <- flipper_tags %>% 
        dplyr::select(Year, Month, Day, `Tag 1 RIGHT`, `Tag 1 LEFT`) %>% 
        dplyr::distinct(`Tag 1 RIGHT`, `Tag 1 LEFT`)
        
        


# Summarise finding unique turtles tags and wether they have returned based on either column R1 and L1
returns <- flipper_tags %>% dplyr::filter(`New? R1` == "No" | `New? L1` == "No") %>% 
        dplyr::select(Year, Month, Day, `Tag 1 RIGHT`, `Tag 1 LEFT`) %>% 
        dplyr::arrange(`Tag 1 RIGHT`, `Tag 1 LEFT`,Year, Month, Day) 

# Unique turtles that have returned:
unique_returns <- returns %>%
        dplyr::select(`Tag 1 RIGHT`, `Tag 1 LEFT`) %>%
        unique() %>% 
        arrange(`Tag 1 RIGHT`, `Tag 1 LEFT`)



# Are there any duplicates in either of the tags of the unique retruns
unique_rtns_right <- unique_returns %>%
        dplyr::select(`Tag 1 RIGHT`) %>%
        unique()
# 110 obs - with 3 NA values therefore all are unique

# Are there any duplicates in either of the tags of the unique retruns?
unique_rtns_left <- unique_returns %>% 
        dplyr::select(`Tag 1 LEFT`) %>%
        unique()
# 99 unique obs with 9  therefore 4 tags should be duplciates

# which ones are duplicated right
dup_r <- which(duplicated(unique_returns$`Tag 1 RIGHT`))
# which ones are duplcaited left
dup_l <- which(duplicated(unique_returns$`Tag 1 LEFT`))
        
# show me the duplicates in a table
unique_returns$`Tag 1 RIGHT`[c(111,112,113)]


# duplcaited right - none (excluding NA values)
# duplcaited left - 7 duplicates
# SCA6635
# SCA6340
# SCA1702
# SCA3048
# SCA3154
# SCA6376

# c(SCA6635,
#   SCA6340,
#   SCA1702,
#   SCA3048,
#   SCA3154,
#   SCA6376)

# TEst - double check
unique_returns %>%  filter(`Tag 1 LEFT` == "SCA6635")

#So the
#113-7

unique_returns$rtn_mrk <- "return"

# So, no join the two data sets
dat <- left_join(unique_turtles, unique_returns)


# so there are 231 unique turtles of which 113 - 7 are TRUE unique returns
# (113-7)/231
round((113-7)/231,2)*100
