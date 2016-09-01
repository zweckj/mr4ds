library(dplyr)
library(stringr)
load(url("http://alizaidi.blob.core.windows.net/training/taxi_df.RData"))
(taxi_df <- tbl_df(taxi_df))

# Include shared lib ------------------------------------------------------

.libPaths(c(.libPaths(), 
            "/Rlib/x86_64-pc-linux-gnu-library/3.2"))


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



taxi_skinny <- taxi_df %>% 
  select(pickup_nhood, dropoff_nhood, trip_distance)

taxi_grouped <- taxi_skinny %>% 
  group_by(pickup_nhood, dropoff_nhood)

taxi_order <- taxi_grouped %>% 
  arrange(pickup_nhood,
          dropoff_nhood,
          desc(trip_distance))

taxi_order


normalize_function <- function(x) {
  
  scale <- sd(x)
  dist <- mean(x)
  
  # browser()
  (x - dist)/scale
}


taxi_mutate <- taxi_grouped %>% 
  mutate(scaled_value = normalize_function(trip_distance))
  

taxi_grouped

taxi_summarise <- taxi_grouped %>% 
  summarise(ave_dist = mean(trip_distance))

taxi_mutate_summarized <- taxi_summarise %>% 
  group_by_(c("pickup_nhood", "dropoff_nhood")) %>% 
  mutate(scaled_value = normalize_function(ave_dist))

iris_grouped <- iris %>% group_by(Species)

iris_grouped %>% tally()

iris_grouped[[3, "Species"]]

pick_group <- function(df = iris,
                       selection = iris_grouped[[3, "Species"]]) {
  
  df %>% filter_()

  
}


taxi_df <- mutate(taxi_df, 
                  tip_pct = tip_amount/fare_amount)

tip_models <- taxi_df %>% 
  group_by(dropoff_dow) %>%
  sample_n(10^3) %>%  
  do(lm_tip = lm(tip_pct ~ pickup_nhood + passenger_count + pickup_hour,
                 data = .),
     tip_pct = .$tip_pct) %>% 
  mutate(ave_tip_pct = mean(tip_pct))


length(tip_models$lm_tip[[1]]$fitted.values)

lapply(tip_models$lm_tip, 
       function(x) length(x$fitted.values))


library(broom)
taxi_models <- taxi_df  %>%  
  group_by(dropoff_dow) %>% 
  sample_n(10^3) %>% 
  do(tidy(lm(tip_pct ~ pickup_nhood + passenger_count + pickup_hour,
               data = .)))


# scoring models ----------------------------------------------------------

taxi_df <- mutate(taxi_df, 
                  tip_pct = tip_amount/fare_amount)

tip_models <- taxi_df %>% 
  group_by(dropoff_dow) %>%
  sample_n(10^3) %>%  
  do(lm_tip = lm(tip_pct ~ trip_distance,
                 data = .))

test_set_fri <- taxi_df %>% filter(pickup_dow == "Fri")

tip_df <- as.data.frame(tip_models)

fri_model <- tip_models[tip_models$dropoff_dow == "Fri", 2]
fri_model <- fri_model[[1]]

test_scores_fri <- predict(fri_model[[1]], test_set_fri)
test_set_fri$predicted_tips <- test_scores_fri

tip_list <- tip_models[[2]]
names(tip_list) <- tip_models[[1]]


fri_model <- tip_list$Fri

test_scores_fri <- predict(fri_model, test_set_fri)



ggplot(filter(test_set_fri, tip_amount < 20), 
       aes(x = payment_type, y = tip_amount)) + 
  geom_boxplot()



# RxText ------------------------------------------------------------------

mort_text <- RxTextData("/usr/lib64/microsoft-r/8.0/lib64/R/library/RevoScaleR/SampleData/mortDefaultSmall2009.csv")


# rxSplit and Transforms --------------------------------------------------



create_partition <- function(xdf = mort_xdf,
                             partition_size = 0.75,
                             output_path = "output/", ...) {
  # rxDataStep(inData = xdf,
  #            outFile = xdf,
  #            transforms = list(
  #              trainvalidate = factor(
  #                ifelse(rbinom(.rxNumRows, 
  #                              size = 1, prob = splitperc), 
  #                       "train", "validate")
  #              )
  #            ),
  #            transformObjects = list(splitperc = partition_size),
  #            overwrite = TRUE, ...)
  
  splitDS <- rxSplit(inData = xdf, 
                     outFilesBase = output_path,
                     outFileSuffixes = c("train", "validate"),
                     splitByFactor = "trainvalidate",
                     transforms = list(
                       trainvalidate = factor(
                         ifelse(rbinom(.rxNumRows, 
                                       size = 1, 
                                       prob = splitperc), 
                                "train", "validate")
                       )
                     ),
                     transformObjects = list(splitperc = partition_size),
                     overwrite = TRUE)
  
  return(splitDS) 
  
}


mort_split <- create_partition(reportProgress = 0)
names(mort_split) <- c("train", "validate")
lapply(mort_split, rxGetInfo)

# if you lose the variable mort_split
mort_split <- list(train = RxXdfData("mortgage.trainvalidate.train.xdf"),
                   validate = RxXdfData("mortgage.trainvalidate.validate.xdf"))


# dtree model -------------------------------------------------------------


default_model_tree <- estimate_model(mort_split$train, 
                                     model = rxDTree,
                                     minBucket = 10)
x <- rxAddInheritance(default_model_tree)
plot(x)

plot(as.rpart(default_model_tree))


rxGetInfo(mort_split$train, getVarInfo = TRUE)

rxSummary(~., data = mort_split$train)

library(RevoTreeView)
plot(createTreeView(default_model_tree))

default_tree_scored <- rxPredict(default_model_tree,
                                 mort_split$validate,
                                 "scored.xdf",
                                 writeModelVars = TRUE,
                                 predVarNames = c("pred_tree_current",
                                                  "pred_tree_default"))

scored_xdf <- RxXdfData("scored.xdf")

rxGetInfo(scored_xdf, numRows = 5)


rxRoc(actualVarName = "default", 
      predVarNames = c("pred_logit_default", "pred_tree_default"), 
      data = scored_xdf)


rxRocCurve(actualVarName = "default", 
           predVarNames = c("pred_logit_default",
                            "pred_tree_default"), 
           data = scored_xdf)


# ensemble algorithms -----------------------------------------------------


rxDForest
rxBTrees

system.time(default_model_forest <- estimate_model(mort_split$train,
                                                   model = rxDForest))

rxPredict(modelObject = default_model_forest,
          data = mort_split$validate,
          outData = "scored.xdf",
          writeModelVars = TRUE,
          type = "prob",
          predVarNames = c("pred_forest_current",
                           "pred_forest_default",
                           "pred_forest_label"))

rxGetInfo(scored_xdf, 
          getVarInfo = TRUE,
          numRows = 5)

system.time(default_model_btree <- estimate_model(mort_split$train,
                                                  model = rxBTrees)
)


rxPredict(modelObject = default_model_btree,
          data = mort_split$validate,
          outData = "scored.xdf",
          writeModelVars = TRUE,
          type = "prob",
          predVarNames = "pred_btree_default")


rxRocCurve(actualVarName = "default", 
           predVarNames = c("pred_logit_default",
                            "pred_tree_default",
                            "pred_forest_default",
                            "pred_btree_default"), 
           data = scored_xdf)
