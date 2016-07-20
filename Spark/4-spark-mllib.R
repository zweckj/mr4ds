# Machine Learning Pipelines with Spark -----------------------------------

## Since Spark 1.3, there has been much interest in creating a simple,
## interactive machine learning pipeline that represents a full
## data science application from start to end








# Engineer Response Var  --------------------------------------------------

sample_taxi %>% ft_binarizer(input_col = "tip_pct", output_col = "good_tip", 
                             threshold = 0.1) -> taxi_binary


fit_dtree <- partitions$training %>% 
  ml_decision_tree(response = "good_tip", 
                   features = c("payment_type", "passenger_count", "trip_distance"), 
                   type = "classification")


score_dtree <- predict(fit_dtree, partitions$test)

fit_dforest <- partitions$training %>% 
  ml_random_forest(response = "good_tip", 
                   features = c("payment_type", "passenger_count", "trip_distance"), 
                   type = "classification")


score_dtree <- predict(fit_dtree, partitions$test)



# Create Training and Split -----------------------------------------------

partitions <- taxi_binary %>% 
  sdf_partition(training = 0.75, 
                test = 0.25, 
                seed = 1099)


# Fit MLlib Linear Model --------------------------------------------------

system.time(fit <- partitions$training %>%
              ml_linear_regression(response = "tip_pct", features = c("trip_distance")))
fit


# Plot Results ------------------------------------------------------------

partitions$test %>%
  select(tip_pct, trip_distance) %>% sample_frac(size = 0.1) %>% 
  collect -> taxi_test_df

taxi_test_df %>% 
  # filter(tip_pct < 1) %>% 
  ggplot(aes(trip_distance, tip_pct)) +
  geom_point(size = 2, alpha = 0.5) +
  geom_abline(aes(slope = coef(fit)[["trip_distance"]],
                  intercept = coef(fit)[["(Intercept)"]]),
              color = "red") +
  labs(
    x = "Trip Distance in Miles",
    y = "Tip Percentage (%)",
    title = "Linear Regression: Tip Percent ~ Trip Distance",
    subtitle = "Spark.ML linear regression to predict tip percentage."
  )



