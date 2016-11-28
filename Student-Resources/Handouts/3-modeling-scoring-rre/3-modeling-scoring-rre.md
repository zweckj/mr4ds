# Modeling and Scoring with RevoScaleR
Ali Zaidi  
`r format(Sys.Date(), "%B %d, %Y")`  


# Introduction 

## URL for Today

Please refer to the github repository for course materials [github.com/akzaidi/R-cadence](https://github.com/akzaidi/R-cadence/)

## Agenda

- We will learn in this tutorial how to train and test models with the `RevoScaleR` package.
- Use your knowledge of data manipulation to create **train** and **test** sets.
- Use the modeling functions in `RevoScaleR` to train a model.
- Use the `rxPredict` function to test/score a model.
- We will see how you can score models on a variety of data sources.
- Use a functional methodology, i.e., we will create functions to automate the modeling, validation, and scoring process.

## Prerequisites

- Understanding of `rxDataStep` and `xdfs`
- Familiarity with `RevoScaleR` modeling and datastep functions: `rxLinMod`, `rxGlm`, `rxLogit`, `rxDTree`, `rxDForest`, `rxSplit`, and `rxPredict`
- Understand how to write functions in R
- Access to at least one interesting dataset

## Typical Lifecycle

![](images/revo-split-life-cycle.png)

Typical Modeling Lifecycle:

- Start with a data set
- Split into a training set and validation set(s)
- Use the `ScaleR` modeling functions on the train set to estimate your model
- Use `rxPredict` to validate/score your results

## Mortgage Dataset

- We will work with a mortgage dataset, which contains mortgage and credit profiles for various mortgage holders


```r
mort_path <- paste(rxGetOption("sampleDataDir"), "mortDefaultSmall.xdf", sep = "/")
file.copy(mort_path, "mortgage.xdf", overwrite = TRUE)
```

```
## [1] TRUE
```

```r
mort_xdf <- RxXdfData("mortgage.xdf")
rxGetInfo(mort_xdf, getVarInfo = TRUE, numRows = 5)
```

```
## File name: /home/alizaidi/mr4ds/Student-Resources/rmarkdown/mortgage.xdf 
## Number of observations: 1e+05 
## Number of variables: 6 
## Number of blocks: 10 
## Compression type: zlib 
## Variable information: 
## Var 1: creditScore, Type: integer, Low/High: (470, 925)
## Var 2: houseAge, Type: integer, Low/High: (0, 40)
## Var 3: yearsEmploy, Type: integer, Low/High: (0, 14)
## Var 4: ccDebt, Type: integer, Low/High: (0, 14094)
## Var 5: year, Type: integer, Low/High: (2000, 2009)
## Var 6: default, Type: integer, Low/High: (0, 1)
## Data (5 rows starting with row 1):
##   creditScore houseAge yearsEmploy ccDebt year default
## 1         691       16           9   6725 2000       0
## 2         691        4           4   5077 2000       0
## 3         743       18           3   3080 2000       0
## 4         728       22           1   4345 2000       0
## 5         745       17           3   2969 2000       0
```

## Transform Default to Categorical

- We might be interested in estimating a classification model for predicting defaults based on credit attributes


```r
rxDataStep(inData = mort_xdf,
           outFile = mort_xdf,
           overwrite = TRUE, 
           transforms = list(default_flag = factor(ifelse(default == 1,
                                                          "default",
                                                          "current"))
                             )
           )
rxGetInfo(mort_xdf, numRows = 3, getVarInfo = TRUE)
```

```
## File name: /home/alizaidi/mr4ds/Student-Resources/rmarkdown/mortgage.xdf 
## Number of observations: 1e+05 
## Number of variables: 7 
## Number of blocks: 10 
## Compression type: zlib 
## Variable information: 
## Var 1: creditScore, Type: integer, Low/High: (470, 925)
## Var 2: houseAge, Type: integer, Low/High: (0, 40)
## Var 3: yearsEmploy, Type: integer, Low/High: (0, 14)
## Var 4: ccDebt, Type: integer, Low/High: (0, 14094)
## Var 5: year, Type: integer, Low/High: (2000, 2009)
## Var 6: default, Type: integer, Low/High: (0, 1)
## Var 7: default_flag
##        2 factor levels: current default
## Data (3 rows starting with row 1):
##   creditScore houseAge yearsEmploy ccDebt year default default_flag
## 1         691       16           9   6725 2000       0      current
## 2         691        4           4   5077 2000       0      current
## 3         743       18           3   3080 2000       0      current
```


# Modeling
## Generating Training and Test Sets 

- The first step to estimating a model is having a tidy training dataset.
- We will work with the mortgage data and use `rxSplit` to create partitions.
- `rxSplit` splits an input `.xdf` into multiple `.xdfs`, similar in spirit to the `split` function in base R
- output is a list
- First step is to create a split variable
- We will randomly partition the data into a train and test sample, with 75% in the former, and 25% in the latter

## Partition Function


```r
create_partition <- function(xdf = mort_xdf,
                             partition_size = 0.75, ...) {
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
                     #outFilesBase = ,
                     outFileSuffixes = c("train", "validate"),
                     splitByFactor = "trainvalidate",
                     overwrite = TRUE)
  
  return(splitDS) 
  
}
```

## Minimizing IO
### Transforms in rxSplit

While the above example does what we want it to do, it's not very efficient. It requires two passes over the data, first to add the `trainvalidate` column, and then another to split it into train and validate sets. We could do all of that in a single step if we pass the transforms directly to `rxSplit`.


```r
create_partition <- function(xdf = mort_xdf,
                             partition_size = 0.75, ...) {

  splitDS <- rxSplit(inData = xdf, 
                     transforms = list(
                       trainvalidate = factor(
                         ifelse(rbinom(.rxNumRows,
                                       size = 1, prob = splitperc),
                                "train", "validate")
                         )
                       ),
                     transformObjects = list(splitperc = partition_size),
                     outFileSuffixes = c("train", "validate"),
                     splitByFactor = "trainvalidate",
                     overwrite = TRUE)
  
  return(splitDS) 
  
}
```


## Generating Training and Test Sets
### List of xdfs

- The `create_partition` function will output a list `xdfs`


```r
mort_split <- create_partition(reportProgress = 0)
names(mort_split) <- c("train", "validate")
lapply(mort_split, rxGetInfo)
```

```
## $train
## File name: /home/alizaidi/mr4ds/Student-Resources/rmarkdown/mortgage.trainvalidate.train.xdf 
## Number of observations: 75233 
## Number of variables: 8 
## Number of blocks: 10 
## Compression type: zlib 
## 
## $validate
## File name: /home/alizaidi/mr4ds/Student-Resources/rmarkdown/mortgage.trainvalidate.validate.xdf 
## Number of observations: 24767 
## Number of variables: 8 
## Number of blocks: 10 
## Compression type: zlib
```


## Build Your Model 
### Model Formula

- Once you have a training dataset, the most appropriate next step is to estimate your model
- `RevoScaleR` provides a plethora of modeling functions to choose from: decision trees, ensemble trees, linear models, and generalized linear models
- All take a formula as the first object in their call


```r
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

## Turns out, RevoScaleR already has a function for this
formula(mort_xdf, depVar = "default_flag", varsToDrop = c("defaultflag", "trainvalidate"))
```

```
## default_flag ~ creditScore + houseAge + yearsEmploy + ccDebt + 
##     year + default
## <environment: 0x324589d0>
```

## Build Your Model 
### Modeling Function

- Use the `make_form` function inside your favorite `rx` modeling function
- Default value will be a logistic regression, but can update the `model` parameter to any `rx` modeling function


```r
make_form()
```

```
## default_flag ~ creditScore + houseAge + yearsEmploy + ccDebt + 
##     year
## <environment: 0x146d369a0>
```

```r
estimate_model <- function(xdf_data = mort_split[["train"]],
                           form = make_form(xdf_data),
                           model = rxLogit, ...) {
  
  rx_model <- model(form, data = xdf_data, ...)
  
  return(rx_model)
  
  
}
```

## Build Your Model 
### Train Your Model with Our Modeling Function

- Let us now train our logistic regression model for defaults using the `estimate_model` function from the last slide


```r
default_model_logit <- estimate_model(mort_split$train, 
                                      reportProgress = 0)
summary(default_model_logit)
```

```
## Call:
## model(formula = form, data = xdf_data, reportProgress = 0)
## 
## Logistic Regression Results for: default_flag ~ creditScore +
##     houseAge + yearsEmploy + ccDebt + year
## Data: xdf_data (RxXdfData Data Source)
## File name:
##     /home/alizaidi/mr4ds/Student-Resources/rmarkdown/mortgage.trainvalidate.train.xdf
## Dependent variable(s): default_flag
## Total independent variables: 6 
## Number of valid observations: 75233
## Number of missing observations: 0 
## -2*LogLikelihood: 2442.0457 (Residual deviance on 75227 degrees of freedom)
##  
## Coefficients:
##               Estimate Std. Error z value Pr(>|z|)    
## (Intercept) -1.227e+03  6.869e+01 -17.855 2.22e-16 ***
## creditScore -7.210e-03  1.215e-03  -5.936 2.91e-09 ***
## houseAge     2.271e-02  7.893e-03   2.878  0.00401 ** 
## yearsEmploy -2.296e-01  3.019e-02  -7.605 2.22e-16 ***
## ccDebt       1.234e-03  4.098e-05  30.112 2.22e-16 ***
## year         6.070e-01  3.420e-02  17.749 2.22e-16 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Condition number of final variance-covariance matrix: 2.289 
## Number of iterations: 9
```


## Building Additional Models

- We can change the parameters of the `estimate_model` function to create a different model relatively quickly


```r
default_model_tree <- estimate_model(mort_split$train, 
                                     model = rxDTree,
                                     minBucket = 10,
                                     reportProgress = 0)
summary(default_model_tree)
```

```
##                     Length Class      Mode     
## frame                 9    data.frame list     
## where                 0    -none-     NULL     
## call                  5    -none-     call     
## cptable              35    -none-     numeric  
## method                1    -none-     character
## parms                 3    -none-     list     
## control               9    -none-     list     
## splits              120    -none-     numeric  
## xvars                 5    -none-     character
## variable.importance   5    -none-     numeric  
## ordered               5    -none-     logical  
## valid.obs             1    -none-     numeric  
## missing.obs           1    -none-     numeric  
## params               65    -none-     list     
## formula               3    formula    call
```

```r
# library(RevoTreeView)
# plot(createTreeView(default_model_tree))
```


# Validation
## How Does it Perform on Unseen Data 
### rxPredict for Logistic Regression


```
## [1] TRUE
```

- Now that we have built our model, our next step is to see how it performs on data it has yet to see
- We can use the `rxPredict` function to score/validate our results


```r
default_logit_scored <- rxPredict(default_model_logit,
                                   mort_split$validate,
                                   "scored.xdf",
                                  writeModelVars = TRUE, 
                                  extraVarsToWrite = "default",
                                  predVarNames = c("pred_logit_default"))
rxGetInfo(default_logit_scored, numRows = 2)
```

```
## File name: /home/alizaidi/mr4ds/Student-Resources/rmarkdown/scored.xdf 
## Number of observations: 24767 
## Number of variables: 8 
## Number of blocks: 10 
## Compression type: zlib 
## Data (2 rows starting with row 1):
##   pred_logit_default default default_flag creditScore houseAge yearsEmploy
## 1       6.239485e-07       0      current         743       18           3
## 2       1.631257e-05       0      current         539       15           3
##   ccDebt year
## 1   3080 2000
## 2   4588 2000
```


## Visualize Model Results


```r
rxRoc(actualVarName = "default", 
      predVarNames ="pred_logit_default", 
      data = default_logit_scored)
```

```
##    threshold        predVarName sensitivity specificity
## 1       0.00 pred_logit_default  1.00000000   0.0000000
## 2       0.01 pred_logit_default  0.87068966   0.9387449
## 3       0.02 pred_logit_default  0.81896552   0.9629630
## 4       0.03 pred_logit_default  0.75862069   0.9738347
## 5       0.04 pred_logit_default  0.69827586   0.9797574
## 6       0.05 pred_logit_default  0.65517241   0.9841386
## 7       0.06 pred_logit_default  0.62068966   0.9872216
## 8       0.07 pred_logit_default  0.57758621   0.9894933
## 9       0.08 pred_logit_default  0.53448276   0.9906292
## 10      0.09 pred_logit_default  0.49137931   0.9914811
## 11      0.10 pred_logit_default  0.48275862   0.9923330
## 12      0.11 pred_logit_default  0.46551724   0.9931037
## 13      0.12 pred_logit_default  0.44827586   0.9937934
## 14      0.13 pred_logit_default  0.43103448   0.9945235
## 15      0.14 pred_logit_default  0.41379310   0.9950103
## 16      0.15 pred_logit_default  0.38793103   0.9955783
## 17      0.16 pred_logit_default  0.37931034   0.9961462
## 18      0.17 pred_logit_default  0.37931034   0.9965924
## 19      0.18 pred_logit_default  0.34482759   0.9969170
## 20      0.19 pred_logit_default  0.34482759   0.9972009
## 21      0.20 pred_logit_default  0.33620690   0.9973632
## 22      0.21 pred_logit_default  0.33620690   0.9977689
## 23      0.22 pred_logit_default  0.31896552   0.9978500
## 24      0.23 pred_logit_default  0.31034483   0.9979717
## 25      0.24 pred_logit_default  0.30172414   0.9982151
## 26      0.25 pred_logit_default  0.28448276   0.9983368
## 27      0.26 pred_logit_default  0.27586207   0.9984585
## 28      0.27 pred_logit_default  0.27586207   0.9985396
## 29      0.28 pred_logit_default  0.26724138   0.9987019
## 30      0.29 pred_logit_default  0.25862069   0.9989047
## 31      0.30 pred_logit_default  0.25862069   0.9989858
## 32      0.31 pred_logit_default  0.24137931   0.9990264
## 33      0.32 pred_logit_default  0.23275862   0.9991075
## 34      0.33 pred_logit_default  0.21551724   0.9991481
## 35      0.34 pred_logit_default  0.20689655   0.9991887
## 36      0.35 pred_logit_default  0.18103448   0.9993509
## 37      0.37 pred_logit_default  0.16379310   0.9993509
## 38      0.38 pred_logit_default  0.14655172   0.9994321
## 39      0.39 pred_logit_default  0.12931034   0.9994726
## 40      0.40 pred_logit_default  0.12068966   0.9994726
## 41      0.41 pred_logit_default  0.12068966   0.9995132
## 42      0.42 pred_logit_default  0.10344828   0.9995943
## 43      0.43 pred_logit_default  0.09482759   0.9995943
## 44      0.46 pred_logit_default  0.09482759   0.9996755
## 45      0.47 pred_logit_default  0.08620690   0.9997160
## 46      0.49 pred_logit_default  0.07758621   0.9997160
## 47      0.50 pred_logit_default  0.06896552   0.9997160
## 48      0.53 pred_logit_default  0.06034483   0.9997566
## 49      0.55 pred_logit_default  0.04310345   0.9997972
## 50      0.57 pred_logit_default  0.04310345   0.9998377
## 51      0.60 pred_logit_default  0.04310345   0.9998783
## 52      0.67 pred_logit_default  0.04310345   0.9999189
## 53      0.68 pred_logit_default  0.04310345   0.9999594
## 54      0.71 pred_logit_default  0.03448276   0.9999594
## 55      0.72 pred_logit_default  0.02586207   0.9999594
## 56      0.76 pred_logit_default  0.01724138   0.9999594
## 57      0.78 pred_logit_default  0.01724138   1.0000000
## 58      0.97 pred_logit_default  0.00000000   1.0000000
```


## Testing a Second Model 
### rxPredict for Decision Tree

- We saw how easy it was to train on different in the previous sections
- Similary simple to test different models


```r
default_tree_scored <- rxPredict(default_model_tree,
                                  mort_split$validate,
                                  "scored.xdf",
                                  writeModelVars = TRUE,
                                 predVarNames = c("pred_tree_current",
                                                  "pred_tree_default"))
```

## Visualize Multiple ROCs


```r
rxRocCurve("default",
           c("pred_logit_default", "pred_tree_default"),
           data = default_tree_scored)
```

![](/home/alizaidi/mr4ds/Student-Resources/Handouts/3-modeling-scoring-rre/3-modeling-scoring-rre_files/figure-html/roc_multiple-1.png)<!-- -->

# Lab - Estimate Other Models Using the Functions Above

## Ensemble Tree Algorithms

Two of the most predictive algorithms in the `RevoScaleR` package are the `rxBTrees` and `rxDForest` algorithms, for gradient boosted decision trees and random forests, respectively.

Use the above functions and estimate a model for each of those algorithms, and add them to the `default_tree_scored` dataset to visualize ROC and AUC metrics.


```r
## Starter code

default_model_forest <- estimate_model(mort_split$train, 
                                       model = rxDForest,
                                       nTree = 100,
                                       importance = TRUE,
                                       reportProgress = 0)

default_forest_scored <- rxPredict(default_model_forest,
                                  mort_split$validate,
                                 "scored.xdf", 
                                type = 'prob',
                                predVarNames = c("pred_forest_current", "pred_forest_default", "pred_default"))

## same for rxBTrees

default_model_gbm <- estimate_model(mort_split$train,
                                    model = rxBTrees,
                                    importance = TRUE,
                                    nTree = 100, reportProgress = 0)

default_gbm_scored <- rxPredict(default_model_gbm,
                                  mort_split$validate,
                                 "scored.xdf",
                                predVarNames = c("pred_gbm_default"))
```


```r
# 
# rxRocCurve(actualVarName = "default",
#            predVarNames = c("pred_tree_default",
#                             "pred_logit_default",
#                             "pred_forest_default",
#                             "pred_gbm_default"),
#            data = 'scored.xdf')
```



# More Advanced Topics

## Scoring on Non-XDF Data Sources 
### Using a CSV as a Data Source

- The previous slides focused on using xdf data sources
- Most of the `rx` functions will work on non-xdf data sources
- For training, which is often an iterative process, it is recommended to use xdfs
- For scoring/testing, which requires just one pass through the data, feel free to use raw data!


```r
csv_path <- paste(rxGetOption("sampleDataDir"),
                   "mortDefaultSmall2009.csv",
                   sep = "/")
file.copy(csv_path, "mortDefaultSmall2009.csv", overwrite = TRUE)
```

```
## [1] TRUE
```

```r
mort_csv <- RxTextData("mortDefaultSmall2009.csv")
```

## Regression Tree

- For a slightly different model, we will estimate a regression tree.
- Just change the parameters in the `estimate_model` function


```r
tree_model_ccdebt <- estimate_model(xdf_data = mort_split$train,
                                    form = make_form(mort_split$train,
                                                     "ccDebt",
                                                     vars_to_skip = c("default_flag",
                                                                      "trainvalidate")),
                                    model = rxDTree)
# plot(RevoTreeView::createTreeView(tree_model_ccdebt))
```


## Test on CSV


```r
if (file.exists("mort2009predictions.xdf")) file.remove("mort2009predictions.xdf")
```

```
## [1] TRUE
```



```r
rxPredict(tree_model_ccdebt,
          data = mort_csv,
          outData = "mort2009predictions.xdf",
          writeModelVars = TRUE)

mort_2009_pred <- RxXdfData("mort2009predictions.xdf")
rxGetInfo(mort_2009_pred, numRows = 1)
```

```
## File name: /home/alizaidi/mr4ds/Student-Resources/rmarkdown/mort2009predictions.xdf 
## Number of observations: 10000 
## Number of variables: 7 
## Number of blocks: 1 
## Compression type: zlib 
## Data (1 row starting with row 1):
##   ccDebt_Pred ccDebt creditScore houseAge yearsEmploy year default
## 1    4839.105   3661         701       23           2 2009       0
```

# Multiclass Classification
## Convert Year to Factor

- We have seen how to estimate a binary classification model and a regression tree
- How would we estimate a multiclass classification model?
- Let's try to predict mortgage origination based on other variables
- Use `rxFactors` to convert *year* to a _factor_ variable


```r
mort_xdf_factor <- rxFactors(inData = mort_xdf,
                             factorInfo = c("year"),
                             outFile = "mort_year.xdf",
                             overwrite = TRUE)
```

## Convert Year to Factor

```r
rxGetInfo(mort_xdf_factor, getVarInfo = TRUE, numRows = 4)
```

```
## File name: /home/alizaidi/mr4ds/Student-Resources/rmarkdown/mort_year.xdf 
## Number of observations: 1e+05 
## Number of variables: 7 
## Number of blocks: 10 
## Compression type: zlib 
## Variable information: 
## Var 1: creditScore, Type: integer, Low/High: (470, 925)
## Var 2: houseAge, Type: integer, Low/High: (0, 40)
## Var 3: yearsEmploy, Type: integer, Low/High: (0, 14)
## Var 4: ccDebt, Type: integer, Low/High: (0, 14094)
## Var 5: year
##        10 factor levels: 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009
## Var 6: default, Type: integer, Low/High: (0, 1)
## Var 7: default_flag
##        2 factor levels: current default
## Data (4 rows starting with row 1):
##   creditScore houseAge yearsEmploy ccDebt year default default_flag
## 1         691       16           9   6725 2000       0      current
## 2         691        4           4   5077 2000       0      current
## 3         743       18           3   3080 2000       0      current
## 4         728       22           1   4345 2000       0      current
```

## Estimate Multiclass Classification

- You know the drill! Change the parameters in `estimate_model`:


```r
tree_multiclass_year <- estimate_model(xdf_data = mort_xdf_factor,
                                    form = make_form(mort_xdf_factor,
                                                     "year",
                                                     vars_to_skip = c("default",
                                                                      "trainvalidate")),
                                    model = rxDTree)
```

## Predict Multiclass Classification

- Score the results


```r
multiclass_preds <- rxPredict(tree_multiclass_year,
                              data = mort_xdf_factor,
                              writeModelVars = TRUE,
                              outData = "multi.xdf",
                              overwrite = TRUE)
```

## Predict Multiclass Classification

- View the results
- Predicted/scored column for each level of the response
- Sum up to one

```r
rxGetInfo(multiclass_preds, numRows = 3)
```


## Conclusion
### Thanks for Attending!

- Any questions?
- Try different models!
- Try modeling with `rxDForest`, `rxBTrees`: have significantly higher predictive accuracy, somewhat less interpretability
