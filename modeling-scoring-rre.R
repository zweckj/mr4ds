## ----create_path_to_mortgages--------------------------------------------
mort_path <- paste(rxGetOption("sampleDataDir"),
                   "mortDefaultSmall.xdf", 
                   sep = "/")
file.copy(mort_path, "mortgage.xdf", overwrite = TRUE)
mort_xdf <- RxXdfData("mortgage.xdf")
rxGetInfo(mort_xdf, getVarInfo = TRUE)

## ----add_default_flag----------------------------------------------------
rxDataStep(inData = mort_xdf,
           outFile = mort_xdf,
           overwrite = TRUE, 
           transforms = list(default_flag = factor(ifelse(default == 1,
                                                          "default",
                                                          "current"))
                             )
           )


## ----partition_function--------------------------------------------------


create_partition <- function(xdf = mort_xdf,
                             partition_size = 0.75,
                             output_path = "/output/", ...) {
  rxDataStep(inData = xdf,
             outFile = xdf,
             transforms = list(
               trainvalidate = factor(
                   ifelse(rbinom(.rxNumRows, 
                                 size = 1, prob = splitperc), 
                          "train", "validate")
               )
           ),
           transformObjects = list(splitperc = partition_size),
           overwrite = TRUE, ...)
  
  splitDS <- rxSplit(inData = xdf, 
                     outFilesBase = "",
                     outFileSuffixes = c("train", "validate"),
                     splitByFactor = "trainvalidate",
                     overwrite = TRUE)
  
  return(splitDS) 
  
}


## ----split_mortgages_data------------------------------------------------
mort_split <- create_partition()
names(mort_split) <- c("train", "validate")
lapply(mort_split, rxGetInfo)


## ----model_function------------------------------------------------------
make_form <- function(xdf = mort_xdf,
                      resp_var = "default_flag",
                      vars_to_skip = c("default", "trainvalidate")) {
  
  library(stringr)
  
  non_incl <- paste(vars_to_skip, collapse = "|")
  
  x_names <- names(xdf)
  
  features <- x_names[!str_detect(x_names, resp_var)]
  features <- features[!str_detect(features, non_incl)]
  
  form <- as.formula(paste(resp_var, paste0(features, collapse = " + "),
                           sep  = " ~ "))
  
  return(form)
}



## ----train_function------------------------------------------------------

make_form()

estimate_model <- function(xdf_data = mort_split[["train"]],
                           form = make_form(xdf_data),
                           model = rxLogit, ...) {
  
  rx_model <- model(form, data = xdf_data)
  
  return(rx_model)
  
  
}


## ----train_models, message = FALSE---------------------------------------
default_model_logit <- estimate_model(mort_split$train, 
                                      reportProgress = 0)


## ----r train_tree--------------------------------------------------------
default_model_tree <- estimate_model(mort_split$train, 
                                     model = rxDTree, 
                                     cp = 0, type = 'class')


## ----remove_any_older_xdf, echo = FALSE, message = F---------------------
if(file.exists("scored.xdf")) file.remove('scored.xdf')

## ----test_logistic_model-------------------------------------------------

default_logit_scored <- rxPredict(default_model_logit,
                                   mort_split$validate,
                                   "scored.xdf",
                                  writeModelVars = TRUE)


## ----default_factor------------------------------------------------------
rxGetInfo(default_logit_scored, numRows = 2)
rxDataStep(inData = default_logit_scored, 
           outFile = default_logit_scored,
           transforms = list(default_binary = ifelse(default_flag == "default",
                                                     1, 
                                                     0)),
           overwrite = TRUE)

## ----roc_curve-----------------------------------------------------------
rxRocCurve("default_binary", "default_flag_Pred", data = default_logit_scored)


## ----test_d_tree_model---------------------------------------------------
default_tree_scored <- rxPredict(default_model_tree,
                                  mort_split$validate,
                                  "scored.xdf",
                                  writeModelVars = TRUE)


## ----roc_multiple--------------------------------------------------------
rxRocCurve("default_binary", 
           c("default_flag_Pred", "default_prob"), 
           data = default_tree_scored)


## ----csv_copy------------------------------------------------------------

csv_path <- paste(rxGetOption("sampleDataDir"),
                   "mortDefaultSmall2009.csv", 
                   sep = "/")
file.copy(csv_path, "mortDefaultSmall2009.csv", overwrite = TRUE)

mort_csv <- RxTextData("mortDefaultSmall2009.csv")


## ----reg_tree------------------------------------------------------------
tree_model_ccdebt <- estimate_model(xdf_data = mort_split$train, 
                                    form = make_form(mort_split$train, 
                                                     "ccDebt", 
                                                     vars_to_skip = c("default_flag",
                                                                      "trainvalidate")), 
                                    model = rxDTree)
# plot(RevoTreeView::createTreeView(tree_model_ccdebt))



## ----, echo = FALSE, message = FALSE, warnings = FALSE-------------------
if (file.exists("mort2009predictions.xdf")) file.remove("mort2009predictions.xdf")

## ----test_csv------------------------------------------------------------

rxPredict(tree_model_ccdebt, 
          data = mort_csv, 
          outData = "mort2009predictions.xdf", 
          writeModelVars = TRUE)

mort_2009_pred <- RxXdfData("mort2009predictions.xdf")
rxGetInfo(mort_2009_pred, numRows = 1)



## ----create_year_factor--------------------------------------------------

mort_xdf_factor <- rxFactors(inData = mort_xdf, 
                             factorInfo = c("year"), 
                             outFile = "mort_year.xdf", 
                             overwrite = TRUE)



## ----view_multiclass-----------------------------------------------------
rxGetInfo(mort_xdf_factor, getVarInfo = TRUE)



## ----multiclass_tree-----------------------------------------------------
tree_multiclass_year <- estimate_model(xdf_data = mort_xdf_factor, 
                                    form = make_form(mort_xdf_factor, 
                                                     "year", 
                                                     vars_to_skip = c("default", 
                                                                      "trainvalidate")), 
                                    model = rxDTree, type = "class")



## ----multiclass_prediction-----------------------------------------------

multiclass_preds <- rxPredict(tree_multiclass_year, 
                              data = mort_xdf_factor, 
                              writeModelVars = TRUE, 
                              outData = "multi.xdf",
                              overwrite = TRUE)


## ----multiclass_view-----------------------------------------------------

rxGetInfo(multiclass_preds, numRows = 1)


