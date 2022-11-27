# fake data - test for multiple years wether resightings occur
library(tidyverse)


#copy data
fake_dat <- flipper_tags
dim(fake_dat)#check dims

#create fake date data 
fake_dat$year_fake <- rep(c(1995:2014),30) %>% 
        as_tibble() %>% 
        sample_n(301)


# Does the turtle have a tag on any of its flippers
old_tag <- fake_dat %>% filter(`New? R1` == "No" | `New? L1` == "No" )%>% 
        dplyr::select(year_fake, tag_1_right = `Tag 1 RIGHT`, tag_1_left = `Tag 1 LEFT`) #, Year, Month, Day,

#  subset of 2014 data and the rest
dat_2014 <- old_tag %>% filter(year_fake == 2014)
dat_before_2014 <- old_tag %>% filter(year_fake != 2014)

# join the data
resight_1_right <- left_join(dat_2014, dat_before_2014, by = ("tag_1_right"), suffix = c("_aft2014", "_bef2014")) 
resight_1_left <- left_join(dat_2014, dat_before_2014, by = ("tag_1_left"), suffix = c("_aft2014", "_bef2014"))


# dinstinct tags
distinct_resight_1_right <- left_join(dat_2014, dat_before_2014, by = ("tag_1_right"), suffix = c("_aft2014", "_bef2014")) %>%  distinct(tag_1_right)
distinct_resight_1_left <- left_join(dat_2014, dat_before_2014, by = ("tag_1_left"), suffix = c("_aft2014", "_bef2014")) %>% distinct(tag_1_left)

#now still need to pair these back up to see which were on  the same turtle
# possible tag combiantion
possible_tags <- flipper_tags %>% select(tag_1_right = `Tag 1 RIGHT`, tag_1_left = `Tag 1 LEFT`) %>% distinct()


# \ join 
distinct_resight_1_right_join_left_tags <- possible_tags %>% 
        inner_join(distinct_resight_1_right, by = "tag_1_right", suffix = ("_poss"))


distinct_resight_1_left_join_right_tags <- possible_tags %>% 
        inner_join(distinct_resight_1_left, by = "tag_1_left", suffix = ("_poss"))

# \revela joins to show where same tags appear multiple times
# join again
left_join(distinct_resight_1_right_join_left_tags,distinct_resight_1_left_join_right_tags, "tag_1_left")
# join again
left_join(distinct_resight_1_right_join_left_tags,distinct_resight_1_left_join_right_tags, "tag_1_right")
# join again
left_join(distinct_resight_1_right_join_left_tags,distinct_resight_1_left_join_right_tags, by = c("tag_1_left","tag_1_right"))


