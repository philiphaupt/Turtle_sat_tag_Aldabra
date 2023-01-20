library(tidyverse)

all_224007 <- read_csv("./data/storm_turtle_data/224007-All.csv")
# inspect
names(all_224007)

str(all_224007)

# Filter by location quality
all_224007 %>% distinct(`Loc. quality`) %>% arrange(`Loc. quality`)
