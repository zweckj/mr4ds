
# Include shared lib ------------------------------------------------------

.libPaths(c(.libPaths(), "/Rlib/x86_64-pc-linux-gnu-library/3.2"))


# Standard Evaluation in dplyr --------------------------------------------

select_fn <- function(col_name) {
  select_df <- select_(taxi_df, col_name)
  return(select_df) 
}


select(arrange(taxi_df, desc(tip_amount), pickup_dow, dropoff_nhood), tip_amount, pickup_dow, dropoff_nhood)


# Two Groups
group_by(taxi_df, pickup_nhood, dropoff_nhood)

# Return Value is a Single Group
summarise(group_by(taxi_df, pickup_nhood, dropoff_nhood), 
          Num = n(), ave_tip_pct = mean(tip_pct))


# Return Value is Number of Groups in Pickup NHood
summarise(summarise(group_by(taxi_df, pickup_nhood, dropoff_nhood), 
                    Num = n(), ave_tip_pct = mean(tip_pct)), total_records = sum(Num))



taxi_df %>% group_by(pickup_nhood, dropoff_nhood) %>% 
  summarise(ave_tip_pct = mean(tip_pct)) %>% 
  arrange(desc(tip_pct))