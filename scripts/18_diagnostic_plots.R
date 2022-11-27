#It would be useful to add a column per tag with its deplaoyment date to allow calculating the number of days since deployment in the diagnostic plots.


turtle_pts %<>% 
        group_by(tag_id) %>% 
        mutate(number_days_since_deployment = lubridate::days(utc_fixed-dplyr::first(utc_fixed)))

#filter(utc > lubridate::ymd(2012-07-01,  "UTC")) %>%  #filter out early invalid records
ggplot2::ggplot(data = turtle_pts, aes(utc_fixed,nb_mes))+#number_days_since_deployment
                        geom_point(aes(colour = factor(wet_or_dry), 
                                       shape = factor(wet_or_dry),
                                       alpha = 0.9,
                                       size = 1))+
                        facet_wrap(~tag_id, scales = "free")
                


test <- turtle_pts %>% 
        ungroup() %>% 
        group_by(tag_id) %>% 
        arrange(tag_id, utc_fixed) %>%
        slice(1)
        #mutate(date_deploy = dplyr::first(utc_fixed))
