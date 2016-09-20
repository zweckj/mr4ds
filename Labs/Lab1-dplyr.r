
options(jupyter.rich_display=FALSE)

library(dplyr)
library(stringr)
load(url("http://alizaidi.blob.core.windows.net/training/taxi_df.RData"))

ls()

class(taxi_df)

taxi_df <- taxi_df %>% mutate(tip_pct = tip_amount/fare_amount)

taxi_df

## Some useful functions

# summary
# quantile
# ggplot() + geom_histogram
# ggplot() + geom_density

## some useful functions
# group_by(payment_type) %>% summarise(tip_amount)
# ggplot() + facet_wrap(~payment_type)

library(broom)
taxi_coefs <- taxi_df %>% sample_n(10^5) %>%
  group_by(dropoff_dow) %>%
  do(tidy(lm(tip_pct ~ pickup_nhood + passenger_count + pickup_hour,
     data = .), conf.int = TRUE)) %>% select(dropoff_dow, conf.low, conf.high)

taxi_metrics <- taxi_df %>% sample_n(10^5) %>%
  group_by(dropoff_dow) %>%
  do(glance(lm(tip_pct ~ pickup_nhood + passenger_count + pickup_hour,
     data = .)))



