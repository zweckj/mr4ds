# Data Manipulation with dplyrXdf
Microsoft Data Science Team  
September 20th, 2016  


# Introduction

## Overview 
### Plan

At the end of this session, you will have learned how to:

* Take advantage of the verbs and syntax you learned from the `dplyr` module to manipulate `RxXdfData` data objects
* Summarize your `RxXdfData` objects quickly and easily
* Create custom functions and use them for mutations and summarizations
* Understand where and when to use the `dplyrXdf` package and when to use functions from the `RevoScaleR` package

## The Microsoft R Family

![Microsoft R Family](images/mr-family.png)

## Microsoft R Component Stack

![Microsoft R Family](images/mrcomponents.png)

<aside class="notes">
ScaleR: suite of HPA functions for data manipulation and modeling, plus some custom HPC functionality
ConnectR: high speed and direct connectors
DistributedR: framework for cross-platform distributed computation
DeployR: web service development kit through APIs, java, js, .net
</aside>


## Why dplyrXdf?
### Simplify Your Analysis Pipeline

* The `RevoScaleR` package enables R users to manipulate data that is larger than memory
* It introduces a new data type, called an `xdf` (short for eXternal Data Frame), which are highly efficient out-of-memory objects
* However, many of the `RevoScaleR` functions have a dramatically different syntax from base R functions
* The `dplyr` package is an exceptionally popular, due to its appealing syntax, and it's extensibility

## Simpler Analysis with dplyrXdf

* The `dplyrXdf` that exposes most of the `dplyr` functionality to `xdf` objects
* Many data analysis pipelines require creating many intermediate datasets, which are only needed for their role in deriving a final dataset, but have no/little use on their own
* The `dplyrXdf` abstracts this task of file management, so that you can focus on the data itself, rather than the management of intermediate files
* Unlike `dplyr`, or other base R packages, `dplyrXdf` allows you to work with data residing _outside_ of memory, and therefore scales to datasets of arbitrary size


## Requirements 
### What You'll Need

* I expect that you have already covered the `dplyr` training
* Understand the *XDF* data type and how to import data to *XDF*
* If you're working on a different computer than your trianer: have (`devtools`)[github.com/hadley/devtools] (and if on a Windows machine, [Rtools](https://cran.r-project.org/bin/windows/Rtools/))

## Installing dplyrXdf

* The `dplyrXdf` package is not yet on CRAN
* You have to download it from [github](https://github.com/RevolutionAnalytics/dplyrXdf/)
  - if you're on a windows machine, install [Rtools](https://cran.r-project.org/bin/windows/Rtools/) as well
  - the `devtools` package provides a very handy function, `install_github`, for installing R packages saved in github repositories

## Create XDF from taxi data

### Create a local directory to save XDF


```r
your_name <- "alizaidi"
your_dir <- paste0('/datadrive/', your_name)
# File Path to your Data
your_data <- file.path(your_dir, 'tripdata_2015.xdf')
dir.create(your_dir)
```

```
## Warning in dir.create(your_dir): '/datadrive/alizaidi' already exists
```

```r
download.file("http://alizaidi.blob.core.windows.net/training/yellow_tripdata_2015.xdf", 
              destfile = your_data)
```

## Create a Pointer to XDF


```r
library(dplyrXdf)
taxi_xdf <- RxXdfData(your_data)
taxi_xdf %>% head
```

```
##   VendorID passenger_count trip_distance RateCodeID store_and_fwd_flag
## 1        2               1          1.59          1                  N
## 2        1               1          3.30          1                  N
## 3        1               1          1.80          1                  N
## 4        1               1          0.50          1                  N
## 5        1               1          3.00          1                  N
## 6        1               1          9.00          1                  N
##   payment_type fare_amount tip_amount tolls_amount pickup_hour pickup_dow
## 1            1        12.0       3.25         0.00        6-10        Thu
## 2            1        14.5       2.00         0.00        6-10        Sat
## 3            2         9.5       0.00         0.00        6-10        Sat
## 4            2         3.5       0.00         0.00        6-10        Sat
## 5            2        15.0       0.00         0.00        6-10        Sat
## 6            1        27.0       6.70         5.33        6-10        Sat
##   dropoff_hour dropoff_dow        pickup_nhood    dropoff_nhood kSplits
## 1         6-10         Thu    Garment District      Murray Hill       D
## 2         6-10         Sat                Soho          Clinton       G
## 3         6-10         Sat Morningside Heights Hamilton Heights       A
## 4         6-10         Sat             Tribeca          Tribeca       B
## 5         6-10         Sat             Midtown          Chelsea       F
## 6         6-10         Sat                <NA>          Midtown       I
```



```r
class(taxi_xdf)
```

```
## [1] "RxXdfData"
## attr(,"package")
## [1] "RevoScaleR"
```


# Simplified Pipelines for Data Summaries

## Data Transforms 
### The rxDataStep Way

* All the functionality exposed by the `dplyrXdf` package can also be completed
by using the `rxDataStep` function in the `RevoScaleR` package included with your MRS installation
* In fact, `dplyrXdf` consists almost entirely of wrapper functions that call on other RevoScaleR functions
* Let's compare the workflow for adding a new column to a dataset with `rxDataStep` vs `dplyrXdf`

---


```r
taxi_xdf %>% rxGetInfo(getVarInfo = TRUE)
```

```
## File name: /datadrive/alizaidi/tripdata_2015.xdf 
## Number of observations: 37696906 
## Number of variables: 16 
## Number of blocks: 21 
## Compression type: zlib 
## Variable information: 
## Var 1: VendorID
##        2 factor levels: 2 1
## Var 2: passenger_count, Type: integer, Low/High: (1, 9)
## Var 3: trip_distance, Type: numeric, Low/High: (0.0000, 49.9000)
## Var 4: RateCodeID
##        7 factor levels: 1 2 5 3 4 99 6
## Var 5: store_and_fwd_flag
##        2 factor levels: N Y
## Var 6: payment_type
##        5 factor levels: 1 2 3 4 5
## Var 7: fare_amount, Type: numeric, Low/High: (0.0100, 503325.5300)
## Var 8: tip_amount, Type: numeric, Low/High: (-0.0100, 3950588.8000)
## Var 9: tolls_amount, Type: numeric, Low/High: (0.0000, 1000.6600)
## Var 10: pickup_hour
##        6 factor levels: 5-9 9-12 12-4 4-6 6-10 10-5
## Var 11: pickup_dow
##        7 factor levels: Sun Mon Tue Wed Thu Fri Sat
## Var 12: dropoff_hour
##        6 factor levels: 5-9 9-12 12-4 4-6 6-10 10-5
## Var 13: dropoff_dow
##        7 factor levels: Sun Mon Tue Wed Thu Fri Sat
## Var 14: pickup_nhood
##        263 factor levels: 19th Ward Abbott McKinley Albright Allen Annandale ... Woodhaven-Richmond Hill Woodlawn-Nordwood Woodrow Woodside Yorkville
## Var 15: dropoff_nhood
##        263 factor levels: 19th Ward Abbott McKinley Albright Allen Annandale ... Woodhaven-Richmond Hill Woodlawn-Nordwood Woodrow Woodside Yorkville
## Var 16: kSplits
##        10 factor levels: A B C D E F G H I J
```

---

```r
taxi_transform <- RxXdfData(your_data)
```

---



```r
system.time(taxi_transform <- rxDataStep(inData = taxi_xdf,
           outFile = taxi_transform,
           transforms = list(tip_pct = tip_amount/fare_amount),
           overwrite = TRUE))
```

```
##    user  system elapsed 
##   1.502   2.070  41.808
```

## Data Transforms 
### The rxDataStep Way


```r
rxGetInfo(RxXdfData(taxi_transform), numRows = 2)
```

```
## File name: /datadrive/alizaidi/tripdata_2015.xdf 
## Number of observations: 37696906 
## Number of variables: 17 
## Number of blocks: 21 
## Compression type: zlib 
## Data (2 rows starting with row 1):
##   VendorID passenger_count trip_distance RateCodeID store_and_fwd_flag
## 1        2               1          1.59          1                  N
## 2        1               1          3.30          1                  N
##   payment_type fare_amount tip_amount tolls_amount pickup_hour pickup_dow
## 1            1        12.0       3.25            0        6-10        Thu
## 2            1        14.5       2.00            0        6-10        Sat
##   dropoff_hour dropoff_dow     pickup_nhood dropoff_nhood kSplits
## 1         6-10         Thu Garment District   Murray Hill       D
## 2         6-10         Sat             Soho       Clinton       G
##     tip_pct
## 1 0.2708333
## 2 0.1379310
```

## Data Transforms 
### The dplyrXdf Way

* We could do the same operation with `dplyrXdf`, using the exact same syntax 
that we learned in the `dplyr` module and taking advantage of the `%>%` operator


```r
system.time(taxi_transform <- taxi_xdf %>% mutate(tip_pct = tip_amount/fare_amount))
```

```
##    user  system elapsed 
##   1.537   2.104  43.378
```

```r
taxi_transform %>% rxGetInfo(numRows = 2)
```

```
## File name: /tmp/RtmphytGxr/file7373ff7d85e.xdf 
## Number of observations: 37696906 
## Number of variables: 17 
## Number of blocks: 21 
## Compression type: zlib 
## Data (2 rows starting with row 1):
##   VendorID passenger_count trip_distance RateCodeID store_and_fwd_flag
## 1        2               1          1.59          1                  N
## 2        1               1          3.30          1                  N
##   payment_type fare_amount tip_amount tolls_amount pickup_hour pickup_dow
## 1            1        12.0       3.25            0        6-10        Thu
## 2            1        14.5       2.00            0        6-10        Sat
##   dropoff_hour dropoff_dow     pickup_nhood dropoff_nhood kSplits
## 1         6-10         Thu Garment District   Murray Hill       D
## 2         6-10         Sat             Soho       Clinton       G
##     tip_pct
## 1 0.2708333
## 2 0.1379310
```

## Differences

* The major difference between the `rxDataStep` operation and the `dplyrXdf` method, is that we do not specify an `outFile` argument anywhere in the `dplyrXdf` pipeline
* In our case, we have assigned our `mutate` value to a new variable called `taxi_transform`
* This creates a temporary file to save the intermediate `xdf`, and only saves the most recent output of a pipeline, where a pipeline is defined as all operations starting from a raw xdf file.
* To copy an *xdf* from the temporary directory to permanent storage, use the `persist` verb

---

```r
taxi_transform@file
```

```
## [1] "/tmp/RtmphytGxr/file7373ff7d85e.xdf"
```


```r
persist(taxi_transform, outFile = "taxiTransform.xdf") -> taxi_transform
```

## Using dplyrXdf for Aggregations 
### dplyrXdf Way

* The `dplyrXdf` package really shines when used for data aggregations and summarizations
* Whereas `rxSummary`, `rxCube`, and `rxCrossTabs` can compute a few summary statistics and do aggregations very quickly, they are not sufficiently general to be used in all places
---

```r
taxi_group <- taxi_transform %>%
  group_by(pickup_nhood) %>% 
  summarize(ave_tip_pct = mean(tip_pct))
taxi_group %>% head
```

```
##               pickup_nhood ave_tip_pct
## 1                Annandale  0.13750000
## 2            Ardon Heights  0.03814815
## 3 Astoria-Long Island City  0.12307670
## 4               Auburndale  0.14224544
## 5             Battery Park  0.15798303
## 6                Bay Ridge  0.40164238
```

## Using dplyrXdf for Aggregations 
### rxCube Way

* The above could have been done with `rxCube` as well, but would require additional considerations
* We would have to make sure that the `pickup_nhood` column was a factor (can't mutate in place because of different data types)
* `rxCube` can only provide summations and averages, so we cannot get standard deviations for instance.
* Creating your own factors is never a pleasant experience. You may feel like everything is going right until

![faceplant](http://www.ohmagif.com/wp-content/uploads/2015/02/dude-front-flip-epic-face-plant.gif)
---

```r
rxFactors(inData = taxi_transform, 
          outFile = "/datadrive/alizaidi/taxi_factor.xdf", 
          factorInfo = c("pickup_nhood"), 
          overwrite = TRUE)
```

```
## Warning in factorInfoVarList(factorInfo[i], varInfo, sortLevelsDefault = sortLevels, : 
##   No changes will be made to the factor variable 'pickup_nhood'
##   because 'sortLevels = FALSE' and there is no 'indexMap'.
```

```
## Warning in rxFactorsBase(inData = dataIO[["inData"]], factorInfo =
## factorInfo, : No changes made to the data set.
```

```r
head(rxCube(tip_pct ~ pickup_nhood, 
            means = TRUE, 
            data = "/datadrive/alizaidi/taxi_factor.xdf"))
```

```
##      pickup_nhood tip_pct Counts
## 1       19th Ward     NaN      0
## 2 Abbott McKinley     NaN      0
## 3        Albright     NaN      0
## 4           Allen     NaN      0
## 5       Annandale  0.1375      2
## 6      Arbor Hill     NaN      0
```

```r
# file.remove("data/taxi_factor.xdf")
```

# Creating Functional Pipelines with dplyrXdf
As we saw above, it's pretty easy to create a summarization or aggregation script. We can encapsulate our aggregation into it's own function.
Suppose we wanted to calculate average tip as a function of dropoff and pickup neighborhoods. In the `dplyr` nonmenclature, this means grouping by dropoff and pickup neighborhoods, and summarizing/averaging tip percent.


```r
rxGetInfo(taxi_transform, numRows = 5)
```

```
## File name: /home/alizaidi/mr4ds/Student-Resources/rmarkdown/taxiTransform.xdf 
## Number of observations: 37696906 
## Number of variables: 17 
## Number of blocks: 76 
## Compression type: zlib 
## Data (5 rows starting with row 1):
##   VendorID passenger_count trip_distance RateCodeID store_and_fwd_flag
## 1        2               1          1.59          1                  N
## 2        1               1          3.30          1                  N
## 3        1               1          1.80          1                  N
## 4        1               1          0.50          1                  N
## 5        1               1          3.00          1                  N
##   payment_type fare_amount tip_amount tolls_amount pickup_hour pickup_dow
## 1            1        12.0       3.25            0        6-10        Thu
## 2            1        14.5       2.00            0        6-10        Sat
## 3            2         9.5       0.00            0        6-10        Sat
## 4            2         3.5       0.00            0        6-10        Sat
## 5            2        15.0       0.00            0        6-10        Sat
##   dropoff_hour dropoff_dow        pickup_nhood    dropoff_nhood kSplits
## 1         6-10         Thu    Garment District      Murray Hill       D
## 2         6-10         Sat                Soho          Clinton       G
## 3         6-10         Sat Morningside Heights Hamilton Heights       A
## 4         6-10         Sat             Tribeca          Tribeca       B
## 5         6-10         Sat             Midtown          Chelsea       F
##     tip_pct
## 1 0.2708333
## 2 0.1379310
## 3 0.0000000
## 4 0.0000000
## 5 0.0000000
```
---

```r
mht_url <- "http://alizaidi.blob.core.windows.net/training/manhattan.rds"
manhattan_hoods <- readRDS(gzcon(url(mht_url)))
```
---

```r
taxi_transform %>% 
    filter(pickup_nhood %in% mht_hoods,
           dropoff_nhood %in% mht_hoods, 
           .rxArgs = list(transformObjects = list(mht_hoods = manhattan_hoods))) %>% 
    group_by(dropoff_nhood, pickup_nhood) %>% 
    summarize(ave_tip = mean(tip_pct), 
              ave_dist = mean(trip_distance)) %>% 
    filter(ave_dist > 3, ave_tip > 0.05) -> sum_df
```



---


```r
sum_df %>% rxGetInfo(getVarInfo = TRUE, numRows = 5)
```

```
## File name: /tmp/RtmphytGxr/file73737ad66f7d.xdf 
## Number of observations: 408 
## Number of variables: 4 
## Number of blocks: 1 
## Compression type: zlib 
## Variable information: 
## Var 1: dropoff_nhood
##        263 factor levels: 19th Ward Abbott McKinley Albright Allen Annandale ... Woodhaven-Richmond Hill Woodlawn-Nordwood Woodrow Woodside Yorkville
## Var 2: pickup_nhood
##        263 factor levels: 19th Ward Abbott McKinley Albright Allen Annandale ... Woodhaven-Richmond Hill Woodlawn-Nordwood Woodrow Woodside Yorkville
## Var 3: ave_tip, Type: numeric, Low/High: (0.0579, 0.1876)
## Var 4: ave_dist, Type: numeric, Low/High: (3.0004, 13.9100)
## Data (5 rows starting with row 1):
##      dropoff_nhood pickup_nhood   ave_tip ave_dist
## 1     Central Park Battery Park 0.1160478 6.028228
## 2          Clinton Battery Park 0.1300344 3.878010
## 3      East Harlem Battery Park 0.1102473 9.982296
## 4     East Village Battery Park 0.1401632 3.952964
## 5 Garment District Battery Park 0.1312443 3.874708
```

```r
class(sum_df)
```

```
## [1] "grouped_tbl_xdf"
## attr(,"package")
## [1] "dplyrXdf"
```

---

Alternatively, we can encapsulate this script into a function, so that we can easily call it in a functional pipeline.


```r
taxi_hood_sum <- function(taxi_data = taxi_df, ...) {
  
  taxi_data %>% 
    filter(pickup_nhood %in% manhattan_hoods,
           dropoff_nhood %in% manhattan_hoods, ...) %>% 
    group_by(dropoff_nhood, pickup_nhood) %>% 
    summarize(ave_tip = mean(tip_pct), 
              ave_dist = mean(trip_distance)) %>% 
    filter(ave_dist > 3, ave_tip > 0.05) -> sum_df
  
  return(sum_df)
  
}
```

---

The resulting summary object isn't very large (about 408 rows in this case), so it shouldn't cause any memory overhead issues if we covert it now to a `data.frame`. We can plot our results using our favorite plotting library. 


```r
tile_plot_hood <- function(df = taxi_hood_sum()) {
  
  library(ggplot2)
  
  ggplot(data = df, aes(x = pickup_nhood, y = dropoff_nhood)) + 
    geom_tile(aes(fill = ave_tip), colour = "white") + 
    theme_bw() + 
    theme(axis.text.x = element_text(angle = 45, hjust = 1),
          legend.position = 'bottom') + 
    scale_fill_gradient(low = "white", high = "steelblue") -> gplot
  
  return(gplot)
}
```

---


```r
# tile_plot_hood(as.data.frame(sum_df))
taxi_transform <- taxi_xdf %>% mutate(tip_pct = tip_amount/fare_amount)
library(plotly)
sum_df <- taxi_hood_sum(taxi_transform, 
                        .rxArgs = list(transformObjects = list(manhattan_hoods = manhattan_hoods))) %>% 
  persist("/datadrive/alizaidi/summarized.xdf")
ggplotly(tile_plot_hood(as.data.frame(sum_df)))
```

<!--html_preserve--><div id="htmlwidget-9369aedc3fbbbd049aed" style="width:672px;height:480px;" class="plotly html-widget"></div>
<script type="application/json" data-for="htmlwidget-9369aedc3fbbbd049aed">{"x":{"data":[{"x":[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27],"y":[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27],"z":[[null,0.469409684328737,null,null,0.504220786417153,0.472155949188361,0.673999580002122,null,0.567808411660331,0.667787296541759,null,0.284292408181803,0.667574575464338,0.817824495476734,null,null,0.595457154972357,0.632726314152218,0.648687350083259,0.573358754680082,null,null,0.580948089122947,0.584170349135422,0.428320289364853,null,0.798113980690646],[0.44831431788297,null,null,0.362992632506864,null,null,0.621073843017701,0.382582795834243,null,0.528826760050875,0.526389795554031,null,null,0.235027687449971,0.437666697663423,0.52654375143537,null,null,null,null,0.394943106831272,0.50435903846551,null,null,0.438696960154531,0.504293997823902,null],[null,0.550889676006611,null,null,null,0.324247528309142,null,0.647744337997379,null,null,null,0.551057364093343,0.452404349501503,0.726485800440648,null,null,null,0.607931874708565,null,null,null,null,0.579861572331044,0.602392941736808,0.546492046824238,null,0.49826676456345],[null,0.261076310765664,null,null,0.251137012194618,0,null,null,0.214094670835352,null,null,0.565304090864387,0.112193687031217,null,null,null,0.3014509301612,0.278643891208125,0.384017019275618,0.473174037125468,null,null,0.417933177580847,0.418421288876329,0.319063551579682,null,0.19119510054442],[0.556153640210605,null,null,0.333439924844302,null,0.313950931810655,0.581376667161901,0.488989099000327,null,null,null,0.324237586940338,0.37121168325388,0.789190650924692,0.508478557424655,0.517632742977553,null,0.525920904698594,null,null,0.590831104027673,0.613479922335332,null,null,0.421781500493096,null,0.401168651915314],[0.403591636917816,null,0.350456975435759,0.268335121633435,0.252453379059755,null,0.368261155516201,0.440166796359814,0.285540187490368,0.325012524422202,0.367062454207518,null,null,null,0.463908296415316,0.339217148282512,0.37908289045862,null,0.394819761579401,0.307117765043805,0.411196661263673,0.479663066861436,null,null,0.195457844160974,0.36327647678524,null],[0.634248478232573,0.55733207665223,null,null,0.589171606168958,0.174694690823838,null,null,null,null,null,0.317500859609403,0.437154372892431,0.360902440934051,null,null,null,0.616775301490517,null,null,null,null,0.603912125227235,0.598558160043415,0.507550037274514,null,0.384929636660592],[null,0.412962906502784,1,null,0.47202173345847,0.39500026750436,null,null,0.486116486095099,0.623866721631853,null,0.377701486903694,0.477669451060156,0.187306860412278,null,null,0.537370763756975,0.609221585637647,0.599733001698897,0.564281004589574,null,null,0.552972791500579,0.572772096427708,0.406953621482114,null,0.401669409876022],[0.565482401943123,null,null,0.252131315162355,null,0.368118987267381,null,0.462527702779921,null,null,null,0.423863752676338,0.426554286504111,0.867922495060666,null,null,null,0.562352017003939,null,null,null,null,null,null,0.50829033637807,null,0.442175327598488],[0.652717250650482,0.536951279456855,null,null,null,0.283461440483807,null,0.63739234056839,null,null,null,0.323104476195775,0.475729170159752,0.58984770503378,null,null,null,0.595327317992993,null,null,null,null,null,0.570208066026532,0.568180610110601,null,0.480472048864024],[null,0.507883028075615,null,null,null,0.343747031985751,null,null,null,null,null,0.480529107682032,0.503491801188868,0.0560675471691761,null,null,null,0.608180460088886,null,0.590801387843184,null,null,0.575612253320483,0.593989621024169,0.621996537663815,null,0.535391559462758],[0.589518800937647,0.468527247711344,0.512981113824923,0.237748537063204,0.359157481189438,null,0.559376905887907,0.455024349855034,0.348146882285433,0.476284631569612,0.523031847632725,null,null,0.0959859730397815,0.402502306109275,0.491841158005713,0.46693900862396,null,0.463803804236159,0.29322424823356,0.540991620254721,0.358773516277899,0.399527707787811,null,null,0.523131727889638,0.0977164301043574],[0.597055586894735,null,0.461560686897499,0.261103877727816,0.411685605904863,null,0.509221341081607,0.600176135847804,0.356700644025072,0.470659021422131,0.526294435931451,null,null,0.260832999566876,0.543835078210461,0.471209821232913,0.513513709592182,null,0.480988635986361,0.284010467555822,0.571558208123701,0.58430437712817,0.449445064358291,null,null,0.491473650466941,null],[0.634794475557892,0.490384506807251,0.539298828423263,0.281136306654101,0.51916419183057,0.0182587869795911,0.447523537311281,0.396990882913667,0.447057472871592,0.464533553858504,0.481142796007963,0.193685497951177,0.188657828619459,null,0.656801276150699,0.577969124451492,0.489786489427612,0.464251447935426,0.430911003384527,0.433690812552556,0.639697946645938,0.539824308973112,0.435954429545956,0.449543941061766,null,0.485866629071492,0.176286872694426],[null,0.406988401116357,null,null,0.486895599065546,0.349054185180499,null,null,null,null,null,0.494488381105173,0.527486837531591,0.795598492590613,null,null,0.563547807963217,0.61962158335624,null,0.603653821700536,null,null,0.58717991825187,0.586028626332395,0.52184120506703,null,0.511139147292617],[null,0.502832491341153,null,null,0.456606075200951,0.149552852211939,null,null,0.408207375589351,null,null,0.307895114292536,0.346827488305201,0.867401062008363,null,null,0.556869469360607,0.546097502490191,null,0.558029795279312,null,null,0.529655654126147,0.554588600436476,0.318954980531076,null,0.261423495026321],[0.579634967152385,null,null,0.241222681983883,null,0.291749520981862,null,0.492546602729291,null,null,null,0.440092798821944,0.483890341452858,0.428438925862969,0.4482448694582,0.530772682831862,null,0.574530122692582,null,null,0.473301230360635,0.57586817393437,null,null,0.447546682774745,null,null],[0.668615273454122,null,0.58771159528582,0.426639233326041,0.519527511150549,null,0.722233517303795,0.647221123723123,0.50165695321839,0.582565146261242,0.655086721373222,null,null,0.574494493606608,0.623250508309066,0.647006463720694,0.558089043876686,null,0.610836972872827,0.510377447845143,0.643297428525911,0.690960648861609,0.550274338581659,null,null,0.660207802572503,null],[0.648720624400598,null,null,null,null,0.399142041222486,null,0.604468849541271,null,null,null,0.494770909401258,0.463602979645218,0.754505414897274,null,null,null,0.626647575566108,null,null,null,0.586740952670893,null,null,0.488340008244287,null,0.418611058355373],[0.623857869429435,null,null,0.416052589313956,null,0.391319820900805,null,0.591318729012414,null,null,0.562074972001972,0.495710640925705,0.343667463715114,0.669256780710413,0.57280115030542,0.605607169896045,null,0.517804961064976,null,null,0.608928629230858,0.598621552800625,null,null,0.35346034064424,0.556257090452819,null],[null,0.491768200721872,null,null,null,0.391864719202279,null,null,null,null,null,0.472463031589256,0.478354759006977,0.485690101371843,null,null,0.520820999372788,0.702814538487751,null,0.526579266771441,null,null,0.575700490762488,0.567865444221196,0.470669575673224,null,0.436050387309775],[null,0.535700237805217,null,null,0.555331353031883,0.450693991015352,null,null,null,null,null,0.275459984947718,0.524510026294532,0.507050911332794,null,null,0.614214791039563,0.633089126140143,0.581949534637277,0.545636225859367,null,null,0.609062123216108,0.583986577187491,0.491832794246668,null,0.497379852532748],[0.619875079586083,null,0.596891877328639,0.476368141295915,0.505450616824324,null,0.663832881421335,0.637821873284797,null,null,0.600283548476785,0.488691493664518,null,0.489839031732199,0.597859669530448,0.627237999538152,null,0.572867313936438,null,null,0.592277362533382,0.625392986094369,null,null,0.532232218288087,0.596985464881574,null],[0.698153892217031,null,0.638045315777653,0.499231939923192,null,null,0.651327145234633,0.690746559003333,null,0.619493249943867,0.633827978387674,null,null,0.467140376919766,0.637256979754957,0.64357784007719,null,null,0.569874459363456,null,0.634550441195705,0.656858717124674,null,null,0.495600636824164,0.641409490920406,null],[0.563607806232553,0.452685684502616,0.524955277300221,0.271005698913959,0.450614104112924,0.0966501311270093,0.490596522468863,0.541130007366164,0.410070067865975,0.498841050029981,0.523560962915362,null,null,null,0.387569912857327,0.489055912187624,0.502262001705119,0.457236075336596,0.456080145352528,0.314157284143064,0.609195714860071,0.549827049709815,0.40947087863852,0.43130765364828,null,0.44643114255776,0.169522028107417],[null,0.520300628896462,null,null,null,0.311476975444768,null,null,null,null,null,0.507813081277236,0.432709096572166,0.360804206682853,null,null,null,0.673071253726068,null,0.578401773577511,null,null,0.59009457556351,0.62784048459495,0.513646054447383,null,0.445974348987903],[0.673629190533724,null,0.47477962640087,0.360155617764797,0.411641405117895,null,0.477110523666595,0.545498125592787,0.379085810693932,0.487596704108317,0.472787370426695,0.158990717528893,null,0.284962324196313,0.567710420689361,0.461688609010254,0.524672469757068,null,0.515286958522829,null,0.652054612710472,0.553774535903901,null,null,0.321481467120057,0.50758491952887,null]],"text":[[null,"ave_tip: 0.12<br>pickup_nhood: Central Park<br>dropoff_nhood: Battery Park",null,null,"ave_tip: 0.12<br>pickup_nhood: Clinton<br>dropoff_nhood: Battery Park","ave_tip: 0.12<br>pickup_nhood: East Harlem<br>dropoff_nhood: Battery Park","ave_tip: 0.15<br>pickup_nhood: East Village<br>dropoff_nhood: Battery Park",null,"ave_tip: 0.13<br>pickup_nhood: Garment District<br>dropoff_nhood: Battery Park","ave_tip: 0.14<br>pickup_nhood: Gramercy<br>dropoff_nhood: Battery Park",null,"ave_tip: 0.09<br>pickup_nhood: Hamilton Heights<br>dropoff_nhood: Battery Park","ave_tip: 0.14<br>pickup_nhood: Harlem<br>dropoff_nhood: Battery Park","ave_tip: 0.16<br>pickup_nhood: Inwood<br>dropoff_nhood: Battery Park",null,null,"ave_tip: 0.14<br>pickup_nhood: Midtown<br>dropoff_nhood: Battery Park","ave_tip: 0.14<br>pickup_nhood: Morningside Heights<br>dropoff_nhood: Battery Park","ave_tip: 0.14<br>pickup_nhood: Murray Hill<br>dropoff_nhood: Battery Park","ave_tip: 0.13<br>pickup_nhood: North Sutton Area<br>dropoff_nhood: Battery Park",null,null,"ave_tip: 0.13<br>pickup_nhood: Upper East Side<br>dropoff_nhood: Battery Park","ave_tip: 0.13<br>pickup_nhood: Upper West Side<br>dropoff_nhood: Battery Park","ave_tip: 0.11<br>pickup_nhood: Washington Heights<br>dropoff_nhood: Battery Park",null,"ave_tip: 0.16<br>pickup_nhood: Yorkville<br>dropoff_nhood: Battery Park"],["ave_tip: 0.12<br>pickup_nhood: Battery Park<br>dropoff_nhood: Central Park",null,null,"ave_tip: 0.1<br>pickup_nhood: Chinatown<br>dropoff_nhood: Central Park",null,null,"ave_tip: 0.14<br>pickup_nhood: East Village<br>dropoff_nhood: Central Park","ave_tip: 0.11<br>pickup_nhood: Financial District<br>dropoff_nhood: Central Park",null,"ave_tip: 0.13<br>pickup_nhood: Gramercy<br>dropoff_nhood: Central Park","ave_tip: 0.13<br>pickup_nhood: Greenwich Village<br>dropoff_nhood: Central Park",null,null,"ave_tip: 0.09<br>pickup_nhood: Inwood<br>dropoff_nhood: Central Park","ave_tip: 0.11<br>pickup_nhood: Little Italy<br>dropoff_nhood: Central Park","ave_tip: 0.13<br>pickup_nhood: Lower East Side<br>dropoff_nhood: Central Park",null,null,null,null,"ave_tip: 0.11<br>pickup_nhood: Soho<br>dropoff_nhood: Central Park","ave_tip: 0.12<br>pickup_nhood: Tribeca<br>dropoff_nhood: Central Park",null,null,"ave_tip: 0.11<br>pickup_nhood: Washington Heights<br>dropoff_nhood: Central Park","ave_tip: 0.12<br>pickup_nhood: West Village<br>dropoff_nhood: Central Park",null],[null,"ave_tip: 0.13<br>pickup_nhood: Central Park<br>dropoff_nhood: Chelsea",null,null,null,"ave_tip: 0.1<br>pickup_nhood: East Harlem<br>dropoff_nhood: Chelsea",null,"ave_tip: 0.14<br>pickup_nhood: Financial District<br>dropoff_nhood: Chelsea",null,null,null,"ave_tip: 0.13<br>pickup_nhood: Hamilton Heights<br>dropoff_nhood: Chelsea","ave_tip: 0.12<br>pickup_nhood: Harlem<br>dropoff_nhood: Chelsea","ave_tip: 0.15<br>pickup_nhood: Inwood<br>dropoff_nhood: Chelsea",null,null,null,"ave_tip: 0.14<br>pickup_nhood: Morningside Heights<br>dropoff_nhood: Chelsea",null,null,null,null,"ave_tip: 0.13<br>pickup_nhood: Upper East Side<br>dropoff_nhood: Chelsea","ave_tip: 0.14<br>pickup_nhood: Upper West Side<br>dropoff_nhood: Chelsea","ave_tip: 0.13<br>pickup_nhood: Washington Heights<br>dropoff_nhood: Chelsea",null,"ave_tip: 0.12<br>pickup_nhood: Yorkville<br>dropoff_nhood: Chelsea"],[null,"ave_tip: 0.09<br>pickup_nhood: Central Park<br>dropoff_nhood: Chinatown",null,null,"ave_tip: 0.09<br>pickup_nhood: Clinton<br>dropoff_nhood: Chinatown","ave_tip: 0.06<br>pickup_nhood: East Harlem<br>dropoff_nhood: Chinatown",null,null,"ave_tip: 0.09<br>pickup_nhood: Garment District<br>dropoff_nhood: Chinatown",null,null,"ave_tip: 0.13<br>pickup_nhood: Hamilton Heights<br>dropoff_nhood: Chinatown","ave_tip: 0.07<br>pickup_nhood: Harlem<br>dropoff_nhood: Chinatown",null,null,null,"ave_tip: 0.1<br>pickup_nhood: Midtown<br>dropoff_nhood: Chinatown","ave_tip: 0.09<br>pickup_nhood: Morningside Heights<br>dropoff_nhood: Chinatown","ave_tip: 0.11<br>pickup_nhood: Murray Hill<br>dropoff_nhood: Chinatown","ave_tip: 0.12<br>pickup_nhood: North Sutton Area<br>dropoff_nhood: Chinatown",null,null,"ave_tip: 0.11<br>pickup_nhood: Upper East Side<br>dropoff_nhood: Chinatown","ave_tip: 0.11<br>pickup_nhood: Upper West Side<br>dropoff_nhood: Chinatown","ave_tip: 0.1<br>pickup_nhood: Washington Heights<br>dropoff_nhood: Chinatown",null,"ave_tip: 0.08<br>pickup_nhood: Yorkville<br>dropoff_nhood: Chinatown"],["ave_tip: 0.13<br>pickup_nhood: Battery Park<br>dropoff_nhood: Clinton",null,null,"ave_tip: 0.1<br>pickup_nhood: Chinatown<br>dropoff_nhood: Clinton",null,"ave_tip: 0.1<br>pickup_nhood: East Harlem<br>dropoff_nhood: Clinton","ave_tip: 0.13<br>pickup_nhood: East Village<br>dropoff_nhood: Clinton","ave_tip: 0.12<br>pickup_nhood: Financial District<br>dropoff_nhood: Clinton",null,null,null,"ave_tip: 0.1<br>pickup_nhood: Hamilton Heights<br>dropoff_nhood: Clinton","ave_tip: 0.11<br>pickup_nhood: Harlem<br>dropoff_nhood: Clinton","ave_tip: 0.16<br>pickup_nhood: Inwood<br>dropoff_nhood: Clinton","ave_tip: 0.12<br>pickup_nhood: Little Italy<br>dropoff_nhood: Clinton","ave_tip: 0.13<br>pickup_nhood: Lower East Side<br>dropoff_nhood: Clinton",null,"ave_tip: 0.13<br>pickup_nhood: Morningside Heights<br>dropoff_nhood: Clinton",null,null,"ave_tip: 0.13<br>pickup_nhood: Soho<br>dropoff_nhood: Clinton","ave_tip: 0.14<br>pickup_nhood: Tribeca<br>dropoff_nhood: Clinton",null,null,"ave_tip: 0.11<br>pickup_nhood: Washington Heights<br>dropoff_nhood: Clinton",null,"ave_tip: 0.11<br>pickup_nhood: Yorkville<br>dropoff_nhood: Clinton"],["ave_tip: 0.11<br>pickup_nhood: Battery Park<br>dropoff_nhood: East Harlem",null,"ave_tip: 0.1<br>pickup_nhood: Chelsea<br>dropoff_nhood: East Harlem","ave_tip: 0.09<br>pickup_nhood: Chinatown<br>dropoff_nhood: East Harlem","ave_tip: 0.09<br>pickup_nhood: Clinton<br>dropoff_nhood: East Harlem",null,"ave_tip: 0.11<br>pickup_nhood: East Village<br>dropoff_nhood: East Harlem","ave_tip: 0.11<br>pickup_nhood: Financial District<br>dropoff_nhood: East Harlem","ave_tip: 0.09<br>pickup_nhood: Garment District<br>dropoff_nhood: East Harlem","ave_tip: 0.1<br>pickup_nhood: Gramercy<br>dropoff_nhood: East Harlem","ave_tip: 0.11<br>pickup_nhood: Greenwich Village<br>dropoff_nhood: East Harlem",null,null,null,"ave_tip: 0.12<br>pickup_nhood: Little Italy<br>dropoff_nhood: East Harlem","ave_tip: 0.1<br>pickup_nhood: Lower East Side<br>dropoff_nhood: East Harlem","ave_tip: 0.11<br>pickup_nhood: Midtown<br>dropoff_nhood: East Harlem",null,"ave_tip: 0.11<br>pickup_nhood: Murray Hill<br>dropoff_nhood: East Harlem","ave_tip: 0.1<br>pickup_nhood: North Sutton Area<br>dropoff_nhood: East Harlem","ave_tip: 0.11<br>pickup_nhood: Soho<br>dropoff_nhood: East Harlem","ave_tip: 0.12<br>pickup_nhood: Tribeca<br>dropoff_nhood: East Harlem",null,null,"ave_tip: 0.08<br>pickup_nhood: Washington Heights<br>dropoff_nhood: East Harlem","ave_tip: 0.11<br>pickup_nhood: West Village<br>dropoff_nhood: East Harlem",null],["ave_tip: 0.14<br>pickup_nhood: Battery Park<br>dropoff_nhood: East Village","ave_tip: 0.13<br>pickup_nhood: Central Park<br>dropoff_nhood: East Village",null,null,"ave_tip: 0.13<br>pickup_nhood: Clinton<br>dropoff_nhood: East Village","ave_tip: 0.08<br>pickup_nhood: East Harlem<br>dropoff_nhood: East Village",null,null,null,null,null,"ave_tip: 0.1<br>pickup_nhood: Hamilton Heights<br>dropoff_nhood: East Village","ave_tip: 0.11<br>pickup_nhood: Harlem<br>dropoff_nhood: East Village","ave_tip: 0.1<br>pickup_nhood: Inwood<br>dropoff_nhood: East Village",null,null,null,"ave_tip: 0.14<br>pickup_nhood: Morningside Heights<br>dropoff_nhood: East Village",null,null,null,null,"ave_tip: 0.14<br>pickup_nhood: Upper East Side<br>dropoff_nhood: East Village","ave_tip: 0.14<br>pickup_nhood: Upper West Side<br>dropoff_nhood: East Village","ave_tip: 0.12<br>pickup_nhood: Washington Heights<br>dropoff_nhood: East Village",null,"ave_tip: 0.11<br>pickup_nhood: Yorkville<br>dropoff_nhood: East Village"],[null,"ave_tip: 0.11<br>pickup_nhood: Central Park<br>dropoff_nhood: Financial District","ave_tip: 0.19<br>pickup_nhood: Chelsea<br>dropoff_nhood: Financial District",null,"ave_tip: 0.12<br>pickup_nhood: Clinton<br>dropoff_nhood: Financial District","ave_tip: 0.11<br>pickup_nhood: East Harlem<br>dropoff_nhood: Financial District",null,null,"ave_tip: 0.12<br>pickup_nhood: Garment District<br>dropoff_nhood: Financial District","ave_tip: 0.14<br>pickup_nhood: Gramercy<br>dropoff_nhood: Financial District",null,"ave_tip: 0.11<br>pickup_nhood: Hamilton Heights<br>dropoff_nhood: Financial District","ave_tip: 0.12<br>pickup_nhood: Harlem<br>dropoff_nhood: Financial District","ave_tip: 0.08<br>pickup_nhood: Inwood<br>dropoff_nhood: Financial District",null,null,"ave_tip: 0.13<br>pickup_nhood: Midtown<br>dropoff_nhood: Financial District","ave_tip: 0.14<br>pickup_nhood: Morningside Heights<br>dropoff_nhood: Financial District","ave_tip: 0.14<br>pickup_nhood: Murray Hill<br>dropoff_nhood: Financial District","ave_tip: 0.13<br>pickup_nhood: North Sutton Area<br>dropoff_nhood: Financial District",null,null,"ave_tip: 0.13<br>pickup_nhood: Upper East Side<br>dropoff_nhood: Financial District","ave_tip: 0.13<br>pickup_nhood: Upper West Side<br>dropoff_nhood: Financial District","ave_tip: 0.11<br>pickup_nhood: Washington Heights<br>dropoff_nhood: Financial District",null,"ave_tip: 0.11<br>pickup_nhood: Yorkville<br>dropoff_nhood: Financial District"],["ave_tip: 0.13<br>pickup_nhood: Battery Park<br>dropoff_nhood: Garment District",null,null,"ave_tip: 0.09<br>pickup_nhood: Chinatown<br>dropoff_nhood: Garment District",null,"ave_tip: 0.11<br>pickup_nhood: East Harlem<br>dropoff_nhood: Garment District",null,"ave_tip: 0.12<br>pickup_nhood: Financial District<br>dropoff_nhood: Garment District",null,null,null,"ave_tip: 0.11<br>pickup_nhood: Hamilton Heights<br>dropoff_nhood: Garment District","ave_tip: 0.11<br>pickup_nhood: Harlem<br>dropoff_nhood: Garment District","ave_tip: 0.17<br>pickup_nhood: Inwood<br>dropoff_nhood: Garment District",null,null,null,"ave_tip: 0.13<br>pickup_nhood: Morningside Heights<br>dropoff_nhood: Garment District",null,null,null,null,null,null,"ave_tip: 0.12<br>pickup_nhood: Washington Heights<br>dropoff_nhood: Garment District",null,"ave_tip: 0.12<br>pickup_nhood: Yorkville<br>dropoff_nhood: Garment District"],["ave_tip: 0.14<br>pickup_nhood: Battery Park<br>dropoff_nhood: Gramercy","ave_tip: 0.13<br>pickup_nhood: Central Park<br>dropoff_nhood: Gramercy",null,null,null,"ave_tip: 0.09<br>pickup_nhood: East Harlem<br>dropoff_nhood: Gramercy",null,"ave_tip: 0.14<br>pickup_nhood: Financial District<br>dropoff_nhood: Gramercy",null,null,null,"ave_tip: 0.1<br>pickup_nhood: Hamilton Heights<br>dropoff_nhood: Gramercy","ave_tip: 0.12<br>pickup_nhood: Harlem<br>dropoff_nhood: Gramercy","ave_tip: 0.13<br>pickup_nhood: Inwood<br>dropoff_nhood: Gramercy",null,null,null,"ave_tip: 0.14<br>pickup_nhood: Morningside Heights<br>dropoff_nhood: Gramercy",null,null,null,null,null,"ave_tip: 0.13<br>pickup_nhood: Upper West Side<br>dropoff_nhood: Gramercy","ave_tip: 0.13<br>pickup_nhood: Washington Heights<br>dropoff_nhood: Gramercy",null,"ave_tip: 0.12<br>pickup_nhood: Yorkville<br>dropoff_nhood: Gramercy"],[null,"ave_tip: 0.12<br>pickup_nhood: Central Park<br>dropoff_nhood: Greenwich Village",null,null,null,"ave_tip: 0.1<br>pickup_nhood: East Harlem<br>dropoff_nhood: Greenwich Village",null,null,null,null,null,"ave_tip: 0.12<br>pickup_nhood: Hamilton Heights<br>dropoff_nhood: Greenwich Village","ave_tip: 0.12<br>pickup_nhood: Harlem<br>dropoff_nhood: Greenwich Village","ave_tip: 0.07<br>pickup_nhood: Inwood<br>dropoff_nhood: Greenwich Village",null,null,null,"ave_tip: 0.14<br>pickup_nhood: Morningside Heights<br>dropoff_nhood: Greenwich Village",null,"ave_tip: 0.13<br>pickup_nhood: North Sutton Area<br>dropoff_nhood: Greenwich Village",null,null,"ave_tip: 0.13<br>pickup_nhood: Upper East Side<br>dropoff_nhood: Greenwich Village","ave_tip: 0.13<br>pickup_nhood: Upper West Side<br>dropoff_nhood: Greenwich Village","ave_tip: 0.14<br>pickup_nhood: Washington Heights<br>dropoff_nhood: Greenwich Village",null,"ave_tip: 0.13<br>pickup_nhood: Yorkville<br>dropoff_nhood: Greenwich Village"],["ave_tip: 0.13<br>pickup_nhood: Battery Park<br>dropoff_nhood: Hamilton Heights","ave_tip: 0.12<br>pickup_nhood: Central Park<br>dropoff_nhood: Hamilton Heights","ave_tip: 0.12<br>pickup_nhood: Chelsea<br>dropoff_nhood: Hamilton Heights","ave_tip: 0.09<br>pickup_nhood: Chinatown<br>dropoff_nhood: Hamilton Heights","ave_tip: 0.1<br>pickup_nhood: Clinton<br>dropoff_nhood: Hamilton Heights",null,"ave_tip: 0.13<br>pickup_nhood: East Village<br>dropoff_nhood: Hamilton Heights","ave_tip: 0.12<br>pickup_nhood: Financial District<br>dropoff_nhood: Hamilton Heights","ave_tip: 0.1<br>pickup_nhood: Garment District<br>dropoff_nhood: Hamilton Heights","ave_tip: 0.12<br>pickup_nhood: Gramercy<br>dropoff_nhood: Hamilton Heights","ave_tip: 0.13<br>pickup_nhood: Greenwich Village<br>dropoff_nhood: Hamilton Heights",null,null,"ave_tip: 0.07<br>pickup_nhood: Inwood<br>dropoff_nhood: Hamilton Heights","ave_tip: 0.11<br>pickup_nhood: Little Italy<br>dropoff_nhood: Hamilton Heights","ave_tip: 0.12<br>pickup_nhood: Lower East Side<br>dropoff_nhood: Hamilton Heights","ave_tip: 0.12<br>pickup_nhood: Midtown<br>dropoff_nhood: Hamilton Heights",null,"ave_tip: 0.12<br>pickup_nhood: Murray Hill<br>dropoff_nhood: Hamilton Heights","ave_tip: 0.1<br>pickup_nhood: North Sutton Area<br>dropoff_nhood: Hamilton Heights","ave_tip: 0.13<br>pickup_nhood: Soho<br>dropoff_nhood: Hamilton Heights","ave_tip: 0.1<br>pickup_nhood: Tribeca<br>dropoff_nhood: Hamilton Heights","ave_tip: 0.11<br>pickup_nhood: Upper East Side<br>dropoff_nhood: Hamilton Heights",null,null,"ave_tip: 0.13<br>pickup_nhood: West Village<br>dropoff_nhood: Hamilton Heights","ave_tip: 0.07<br>pickup_nhood: Yorkville<br>dropoff_nhood: Hamilton Heights"],["ave_tip: 0.14<br>pickup_nhood: Battery Park<br>dropoff_nhood: Harlem",null,"ave_tip: 0.12<br>pickup_nhood: Chelsea<br>dropoff_nhood: Harlem","ave_tip: 0.09<br>pickup_nhood: Chinatown<br>dropoff_nhood: Harlem","ave_tip: 0.11<br>pickup_nhood: Clinton<br>dropoff_nhood: Harlem",null,"ave_tip: 0.12<br>pickup_nhood: East Village<br>dropoff_nhood: Harlem","ave_tip: 0.14<br>pickup_nhood: Financial District<br>dropoff_nhood: Harlem","ave_tip: 0.1<br>pickup_nhood: Garment District<br>dropoff_nhood: Harlem","ave_tip: 0.12<br>pickup_nhood: Gramercy<br>dropoff_nhood: Harlem","ave_tip: 0.13<br>pickup_nhood: Greenwich Village<br>dropoff_nhood: Harlem",null,null,"ave_tip: 0.09<br>pickup_nhood: Inwood<br>dropoff_nhood: Harlem","ave_tip: 0.13<br>pickup_nhood: Little Italy<br>dropoff_nhood: Harlem","ave_tip: 0.12<br>pickup_nhood: Lower East Side<br>dropoff_nhood: Harlem","ave_tip: 0.12<br>pickup_nhood: Midtown<br>dropoff_nhood: Harlem",null,"ave_tip: 0.12<br>pickup_nhood: Murray Hill<br>dropoff_nhood: Harlem","ave_tip: 0.09<br>pickup_nhood: North Sutton Area<br>dropoff_nhood: Harlem","ave_tip: 0.13<br>pickup_nhood: Soho<br>dropoff_nhood: Harlem","ave_tip: 0.13<br>pickup_nhood: Tribeca<br>dropoff_nhood: Harlem","ave_tip: 0.12<br>pickup_nhood: Upper East Side<br>dropoff_nhood: Harlem",null,null,"ave_tip: 0.12<br>pickup_nhood: West Village<br>dropoff_nhood: Harlem",null],["ave_tip: 0.14<br>pickup_nhood: Battery Park<br>dropoff_nhood: Inwood","ave_tip: 0.12<br>pickup_nhood: Central Park<br>dropoff_nhood: Inwood","ave_tip: 0.13<br>pickup_nhood: Chelsea<br>dropoff_nhood: Inwood","ave_tip: 0.09<br>pickup_nhood: Chinatown<br>dropoff_nhood: Inwood","ave_tip: 0.13<br>pickup_nhood: Clinton<br>dropoff_nhood: Inwood","ave_tip: 0.06<br>pickup_nhood: East Harlem<br>dropoff_nhood: Inwood","ave_tip: 0.12<br>pickup_nhood: East Village<br>dropoff_nhood: Inwood","ave_tip: 0.11<br>pickup_nhood: Financial District<br>dropoff_nhood: Inwood","ave_tip: 0.12<br>pickup_nhood: Garment District<br>dropoff_nhood: Inwood","ave_tip: 0.12<br>pickup_nhood: Gramercy<br>dropoff_nhood: Inwood","ave_tip: 0.12<br>pickup_nhood: Greenwich Village<br>dropoff_nhood: Inwood","ave_tip: 0.08<br>pickup_nhood: Hamilton Heights<br>dropoff_nhood: Inwood","ave_tip: 0.08<br>pickup_nhood: Harlem<br>dropoff_nhood: Inwood",null,"ave_tip: 0.14<br>pickup_nhood: Little Italy<br>dropoff_nhood: Inwood","ave_tip: 0.13<br>pickup_nhood: Lower East Side<br>dropoff_nhood: Inwood","ave_tip: 0.12<br>pickup_nhood: Midtown<br>dropoff_nhood: Inwood","ave_tip: 0.12<br>pickup_nhood: Morningside Heights<br>dropoff_nhood: Inwood","ave_tip: 0.11<br>pickup_nhood: Murray Hill<br>dropoff_nhood: Inwood","ave_tip: 0.11<br>pickup_nhood: North Sutton Area<br>dropoff_nhood: Inwood","ave_tip: 0.14<br>pickup_nhood: Soho<br>dropoff_nhood: Inwood","ave_tip: 0.13<br>pickup_nhood: Tribeca<br>dropoff_nhood: Inwood","ave_tip: 0.11<br>pickup_nhood: Upper East Side<br>dropoff_nhood: Inwood","ave_tip: 0.12<br>pickup_nhood: Upper West Side<br>dropoff_nhood: Inwood",null,"ave_tip: 0.12<br>pickup_nhood: West Village<br>dropoff_nhood: Inwood","ave_tip: 0.08<br>pickup_nhood: Yorkville<br>dropoff_nhood: Inwood"],[null,"ave_tip: 0.11<br>pickup_nhood: Central Park<br>dropoff_nhood: Little Italy",null,null,"ave_tip: 0.12<br>pickup_nhood: Clinton<br>dropoff_nhood: Little Italy","ave_tip: 0.1<br>pickup_nhood: East Harlem<br>dropoff_nhood: Little Italy",null,null,null,null,null,"ave_tip: 0.12<br>pickup_nhood: Hamilton Heights<br>dropoff_nhood: Little Italy","ave_tip: 0.13<br>pickup_nhood: Harlem<br>dropoff_nhood: Little Italy","ave_tip: 0.16<br>pickup_nhood: Inwood<br>dropoff_nhood: Little Italy",null,null,"ave_tip: 0.13<br>pickup_nhood: Midtown<br>dropoff_nhood: Little Italy","ave_tip: 0.14<br>pickup_nhood: Morningside Heights<br>dropoff_nhood: Little Italy",null,"ave_tip: 0.14<br>pickup_nhood: North Sutton Area<br>dropoff_nhood: Little Italy",null,null,"ave_tip: 0.13<br>pickup_nhood: Upper East Side<br>dropoff_nhood: Little Italy","ave_tip: 0.13<br>pickup_nhood: Upper West Side<br>dropoff_nhood: Little Italy","ave_tip: 0.13<br>pickup_nhood: Washington Heights<br>dropoff_nhood: Little Italy",null,"ave_tip: 0.12<br>pickup_nhood: Yorkville<br>dropoff_nhood: Little Italy"],[null,"ave_tip: 0.12<br>pickup_nhood: Central Park<br>dropoff_nhood: Lower East Side",null,null,"ave_tip: 0.12<br>pickup_nhood: Clinton<br>dropoff_nhood: Lower East Side","ave_tip: 0.08<br>pickup_nhood: East Harlem<br>dropoff_nhood: Lower East Side",null,null,"ave_tip: 0.11<br>pickup_nhood: Garment District<br>dropoff_nhood: Lower East Side",null,null,"ave_tip: 0.1<br>pickup_nhood: Hamilton Heights<br>dropoff_nhood: Lower East Side","ave_tip: 0.1<br>pickup_nhood: Harlem<br>dropoff_nhood: Lower East Side","ave_tip: 0.17<br>pickup_nhood: Inwood<br>dropoff_nhood: Lower East Side",null,null,"ave_tip: 0.13<br>pickup_nhood: Midtown<br>dropoff_nhood: Lower East Side","ave_tip: 0.13<br>pickup_nhood: Morningside Heights<br>dropoff_nhood: Lower East Side",null,"ave_tip: 0.13<br>pickup_nhood: North Sutton Area<br>dropoff_nhood: Lower East Side",null,null,"ave_tip: 0.13<br>pickup_nhood: Upper East Side<br>dropoff_nhood: Lower East Side","ave_tip: 0.13<br>pickup_nhood: Upper West Side<br>dropoff_nhood: Lower East Side","ave_tip: 0.1<br>pickup_nhood: Washington Heights<br>dropoff_nhood: Lower East Side",null,"ave_tip: 0.09<br>pickup_nhood: Yorkville<br>dropoff_nhood: Lower East Side"],["ave_tip: 0.13<br>pickup_nhood: Battery Park<br>dropoff_nhood: Midtown",null,null,"ave_tip: 0.09<br>pickup_nhood: Chinatown<br>dropoff_nhood: Midtown",null,"ave_tip: 0.1<br>pickup_nhood: East Harlem<br>dropoff_nhood: Midtown",null,"ave_tip: 0.12<br>pickup_nhood: Financial District<br>dropoff_nhood: Midtown",null,null,null,"ave_tip: 0.11<br>pickup_nhood: Hamilton Heights<br>dropoff_nhood: Midtown","ave_tip: 0.12<br>pickup_nhood: Harlem<br>dropoff_nhood: Midtown","ave_tip: 0.11<br>pickup_nhood: Inwood<br>dropoff_nhood: Midtown","ave_tip: 0.12<br>pickup_nhood: Little Italy<br>dropoff_nhood: Midtown","ave_tip: 0.13<br>pickup_nhood: Lower East Side<br>dropoff_nhood: Midtown",null,"ave_tip: 0.13<br>pickup_nhood: Morningside Heights<br>dropoff_nhood: Midtown",null,null,"ave_tip: 0.12<br>pickup_nhood: Soho<br>dropoff_nhood: Midtown","ave_tip: 0.13<br>pickup_nhood: Tribeca<br>dropoff_nhood: Midtown",null,null,"ave_tip: 0.12<br>pickup_nhood: Washington Heights<br>dropoff_nhood: Midtown",null,null],["ave_tip: 0.14<br>pickup_nhood: Battery Park<br>dropoff_nhood: Morningside Heights",null,"ave_tip: 0.13<br>pickup_nhood: Chelsea<br>dropoff_nhood: Morningside Heights","ave_tip: 0.11<br>pickup_nhood: Chinatown<br>dropoff_nhood: Morningside Heights","ave_tip: 0.13<br>pickup_nhood: Clinton<br>dropoff_nhood: Morningside Heights",null,"ave_tip: 0.15<br>pickup_nhood: East Village<br>dropoff_nhood: Morningside Heights","ave_tip: 0.14<br>pickup_nhood: Financial District<br>dropoff_nhood: Morningside Heights","ave_tip: 0.12<br>pickup_nhood: Garment District<br>dropoff_nhood: Morningside Heights","ave_tip: 0.13<br>pickup_nhood: Gramercy<br>dropoff_nhood: Morningside Heights","ave_tip: 0.14<br>pickup_nhood: Greenwich Village<br>dropoff_nhood: Morningside Heights",null,null,"ave_tip: 0.13<br>pickup_nhood: Inwood<br>dropoff_nhood: Morningside Heights","ave_tip: 0.14<br>pickup_nhood: Little Italy<br>dropoff_nhood: Morningside Heights","ave_tip: 0.14<br>pickup_nhood: Lower East Side<br>dropoff_nhood: Morningside Heights","ave_tip: 0.13<br>pickup_nhood: Midtown<br>dropoff_nhood: Morningside Heights",null,"ave_tip: 0.14<br>pickup_nhood: Murray Hill<br>dropoff_nhood: Morningside Heights","ave_tip: 0.12<br>pickup_nhood: North Sutton Area<br>dropoff_nhood: Morningside Heights","ave_tip: 0.14<br>pickup_nhood: Soho<br>dropoff_nhood: Morningside Heights","ave_tip: 0.15<br>pickup_nhood: Tribeca<br>dropoff_nhood: Morningside Heights","ave_tip: 0.13<br>pickup_nhood: Upper East Side<br>dropoff_nhood: Morningside Heights",null,null,"ave_tip: 0.14<br>pickup_nhood: West Village<br>dropoff_nhood: Morningside Heights",null],["ave_tip: 0.14<br>pickup_nhood: Battery Park<br>dropoff_nhood: Murray Hill",null,null,null,null,"ave_tip: 0.11<br>pickup_nhood: East Harlem<br>dropoff_nhood: Murray Hill",null,"ave_tip: 0.14<br>pickup_nhood: Financial District<br>dropoff_nhood: Murray Hill",null,null,null,"ave_tip: 0.12<br>pickup_nhood: Hamilton Heights<br>dropoff_nhood: Murray Hill","ave_tip: 0.12<br>pickup_nhood: Harlem<br>dropoff_nhood: Murray Hill","ave_tip: 0.16<br>pickup_nhood: Inwood<br>dropoff_nhood: Murray Hill",null,null,null,"ave_tip: 0.14<br>pickup_nhood: Morningside Heights<br>dropoff_nhood: Murray Hill",null,null,null,"ave_tip: 0.13<br>pickup_nhood: Tribeca<br>dropoff_nhood: Murray Hill",null,null,"ave_tip: 0.12<br>pickup_nhood: Washington Heights<br>dropoff_nhood: Murray Hill",null,"ave_tip: 0.11<br>pickup_nhood: Yorkville<br>dropoff_nhood: Murray Hill"],["ave_tip: 0.14<br>pickup_nhood: Battery Park<br>dropoff_nhood: North Sutton Area",null,null,"ave_tip: 0.11<br>pickup_nhood: Chinatown<br>dropoff_nhood: North Sutton Area",null,"ave_tip: 0.11<br>pickup_nhood: East Harlem<br>dropoff_nhood: North Sutton Area",null,"ave_tip: 0.13<br>pickup_nhood: Financial District<br>dropoff_nhood: North Sutton Area",null,null,"ave_tip: 0.13<br>pickup_nhood: Greenwich Village<br>dropoff_nhood: North Sutton Area","ave_tip: 0.12<br>pickup_nhood: Hamilton Heights<br>dropoff_nhood: North Sutton Area","ave_tip: 0.1<br>pickup_nhood: Harlem<br>dropoff_nhood: North Sutton Area","ave_tip: 0.14<br>pickup_nhood: Inwood<br>dropoff_nhood: North Sutton Area","ave_tip: 0.13<br>pickup_nhood: Little Italy<br>dropoff_nhood: North Sutton Area","ave_tip: 0.14<br>pickup_nhood: Lower East Side<br>dropoff_nhood: North Sutton Area",null,"ave_tip: 0.13<br>pickup_nhood: Morningside Heights<br>dropoff_nhood: North Sutton Area",null,null,"ave_tip: 0.14<br>pickup_nhood: Soho<br>dropoff_nhood: North Sutton Area","ave_tip: 0.14<br>pickup_nhood: Tribeca<br>dropoff_nhood: North Sutton Area",null,null,"ave_tip: 0.1<br>pickup_nhood: Washington Heights<br>dropoff_nhood: North Sutton Area","ave_tip: 0.13<br>pickup_nhood: West Village<br>dropoff_nhood: North Sutton Area",null],[null,"ave_tip: 0.12<br>pickup_nhood: Central Park<br>dropoff_nhood: Soho",null,null,null,"ave_tip: 0.11<br>pickup_nhood: East Harlem<br>dropoff_nhood: Soho",null,null,null,null,null,"ave_tip: 0.12<br>pickup_nhood: Hamilton Heights<br>dropoff_nhood: Soho","ave_tip: 0.12<br>pickup_nhood: Harlem<br>dropoff_nhood: Soho","ave_tip: 0.12<br>pickup_nhood: Inwood<br>dropoff_nhood: Soho",null,null,"ave_tip: 0.13<br>pickup_nhood: Midtown<br>dropoff_nhood: Soho","ave_tip: 0.15<br>pickup_nhood: Morningside Heights<br>dropoff_nhood: Soho",null,"ave_tip: 0.13<br>pickup_nhood: North Sutton Area<br>dropoff_nhood: Soho",null,null,"ave_tip: 0.13<br>pickup_nhood: Upper East Side<br>dropoff_nhood: Soho","ave_tip: 0.13<br>pickup_nhood: Upper West Side<br>dropoff_nhood: Soho","ave_tip: 0.12<br>pickup_nhood: Washington Heights<br>dropoff_nhood: Soho",null,"ave_tip: 0.11<br>pickup_nhood: Yorkville<br>dropoff_nhood: Soho"],[null,"ave_tip: 0.13<br>pickup_nhood: Central Park<br>dropoff_nhood: Tribeca",null,null,"ave_tip: 0.13<br>pickup_nhood: Clinton<br>dropoff_nhood: Tribeca","ave_tip: 0.12<br>pickup_nhood: East Harlem<br>dropoff_nhood: Tribeca",null,null,null,null,null,"ave_tip: 0.09<br>pickup_nhood: Hamilton Heights<br>dropoff_nhood: Tribeca","ave_tip: 0.13<br>pickup_nhood: Harlem<br>dropoff_nhood: Tribeca","ave_tip: 0.12<br>pickup_nhood: Inwood<br>dropoff_nhood: Tribeca",null,null,"ave_tip: 0.14<br>pickup_nhood: Midtown<br>dropoff_nhood: Tribeca","ave_tip: 0.14<br>pickup_nhood: Morningside Heights<br>dropoff_nhood: Tribeca","ave_tip: 0.13<br>pickup_nhood: Murray Hill<br>dropoff_nhood: Tribeca","ave_tip: 0.13<br>pickup_nhood: North Sutton Area<br>dropoff_nhood: Tribeca",null,null,"ave_tip: 0.14<br>pickup_nhood: Upper East Side<br>dropoff_nhood: Tribeca","ave_tip: 0.13<br>pickup_nhood: Upper West Side<br>dropoff_nhood: Tribeca","ave_tip: 0.12<br>pickup_nhood: Washington Heights<br>dropoff_nhood: Tribeca",null,"ave_tip: 0.12<br>pickup_nhood: Yorkville<br>dropoff_nhood: Tribeca"],["ave_tip: 0.14<br>pickup_nhood: Battery Park<br>dropoff_nhood: Upper East Side",null,"ave_tip: 0.14<br>pickup_nhood: Chelsea<br>dropoff_nhood: Upper East Side","ave_tip: 0.12<br>pickup_nhood: Chinatown<br>dropoff_nhood: Upper East Side","ave_tip: 0.12<br>pickup_nhood: Clinton<br>dropoff_nhood: Upper East Side",null,"ave_tip: 0.14<br>pickup_nhood: East Village<br>dropoff_nhood: Upper East Side","ave_tip: 0.14<br>pickup_nhood: Financial District<br>dropoff_nhood: Upper East Side",null,null,"ave_tip: 0.14<br>pickup_nhood: Greenwich Village<br>dropoff_nhood: Upper East Side","ave_tip: 0.12<br>pickup_nhood: Hamilton Heights<br>dropoff_nhood: Upper East Side",null,"ave_tip: 0.12<br>pickup_nhood: Inwood<br>dropoff_nhood: Upper East Side","ave_tip: 0.14<br>pickup_nhood: Little Italy<br>dropoff_nhood: Upper East Side","ave_tip: 0.14<br>pickup_nhood: Lower East Side<br>dropoff_nhood: Upper East Side",null,"ave_tip: 0.13<br>pickup_nhood: Morningside Heights<br>dropoff_nhood: Upper East Side",null,null,"ave_tip: 0.13<br>pickup_nhood: Soho<br>dropoff_nhood: Upper East Side","ave_tip: 0.14<br>pickup_nhood: Tribeca<br>dropoff_nhood: Upper East Side",null,null,"ave_tip: 0.13<br>pickup_nhood: Washington Heights<br>dropoff_nhood: Upper East Side","ave_tip: 0.14<br>pickup_nhood: West Village<br>dropoff_nhood: Upper East Side",null],["ave_tip: 0.15<br>pickup_nhood: Battery Park<br>dropoff_nhood: Upper West Side",null,"ave_tip: 0.14<br>pickup_nhood: Chelsea<br>dropoff_nhood: Upper West Side","ave_tip: 0.12<br>pickup_nhood: Chinatown<br>dropoff_nhood: Upper West Side",null,null,"ave_tip: 0.14<br>pickup_nhood: East Village<br>dropoff_nhood: Upper West Side","ave_tip: 0.15<br>pickup_nhood: Financial District<br>dropoff_nhood: Upper West Side",null,"ave_tip: 0.14<br>pickup_nhood: Gramercy<br>dropoff_nhood: Upper West Side","ave_tip: 0.14<br>pickup_nhood: Greenwich Village<br>dropoff_nhood: Upper West Side",null,null,"ave_tip: 0.12<br>pickup_nhood: Inwood<br>dropoff_nhood: Upper West Side","ave_tip: 0.14<br>pickup_nhood: Little Italy<br>dropoff_nhood: Upper West Side","ave_tip: 0.14<br>pickup_nhood: Lower East Side<br>dropoff_nhood: Upper West Side",null,null,"ave_tip: 0.13<br>pickup_nhood: Murray Hill<br>dropoff_nhood: Upper West Side",null,"ave_tip: 0.14<br>pickup_nhood: Soho<br>dropoff_nhood: Upper West Side","ave_tip: 0.14<br>pickup_nhood: Tribeca<br>dropoff_nhood: Upper West Side",null,null,"ave_tip: 0.12<br>pickup_nhood: Washington Heights<br>dropoff_nhood: Upper West Side","ave_tip: 0.14<br>pickup_nhood: West Village<br>dropoff_nhood: Upper West Side",null],["ave_tip: 0.13<br>pickup_nhood: Battery Park<br>dropoff_nhood: Washington Heights","ave_tip: 0.12<br>pickup_nhood: Central Park<br>dropoff_nhood: Washington Heights","ave_tip: 0.13<br>pickup_nhood: Chelsea<br>dropoff_nhood: Washington Heights","ave_tip: 0.09<br>pickup_nhood: Chinatown<br>dropoff_nhood: Washington Heights","ave_tip: 0.12<br>pickup_nhood: Clinton<br>dropoff_nhood: Washington Heights","ave_tip: 0.07<br>pickup_nhood: East Harlem<br>dropoff_nhood: Washington Heights","ave_tip: 0.12<br>pickup_nhood: East Village<br>dropoff_nhood: Washington Heights","ave_tip: 0.13<br>pickup_nhood: Financial District<br>dropoff_nhood: Washington Heights","ave_tip: 0.11<br>pickup_nhood: Garment District<br>dropoff_nhood: Washington Heights","ave_tip: 0.12<br>pickup_nhood: Gramercy<br>dropoff_nhood: Washington Heights","ave_tip: 0.13<br>pickup_nhood: Greenwich Village<br>dropoff_nhood: Washington Heights",null,null,null,"ave_tip: 0.11<br>pickup_nhood: Little Italy<br>dropoff_nhood: Washington Heights","ave_tip: 0.12<br>pickup_nhood: Lower East Side<br>dropoff_nhood: Washington Heights","ave_tip: 0.12<br>pickup_nhood: Midtown<br>dropoff_nhood: Washington Heights","ave_tip: 0.12<br>pickup_nhood: Morningside Heights<br>dropoff_nhood: Washington Heights","ave_tip: 0.12<br>pickup_nhood: Murray Hill<br>dropoff_nhood: Washington Heights","ave_tip: 0.1<br>pickup_nhood: North Sutton Area<br>dropoff_nhood: Washington Heights","ave_tip: 0.14<br>pickup_nhood: Soho<br>dropoff_nhood: Washington Heights","ave_tip: 0.13<br>pickup_nhood: Tribeca<br>dropoff_nhood: Washington Heights","ave_tip: 0.11<br>pickup_nhood: Upper East Side<br>dropoff_nhood: Washington Heights","ave_tip: 0.11<br>pickup_nhood: Upper West Side<br>dropoff_nhood: Washington Heights",null,"ave_tip: 0.12<br>pickup_nhood: West Village<br>dropoff_nhood: Washington Heights","ave_tip: 0.08<br>pickup_nhood: Yorkville<br>dropoff_nhood: Washington Heights"],[null,"ave_tip: 0.13<br>pickup_nhood: Central Park<br>dropoff_nhood: West Village",null,null,null,"ave_tip: 0.1<br>pickup_nhood: East Harlem<br>dropoff_nhood: West Village",null,null,null,null,null,"ave_tip: 0.12<br>pickup_nhood: Hamilton Heights<br>dropoff_nhood: West Village","ave_tip: 0.11<br>pickup_nhood: Harlem<br>dropoff_nhood: West Village","ave_tip: 0.1<br>pickup_nhood: Inwood<br>dropoff_nhood: West Village",null,null,null,"ave_tip: 0.15<br>pickup_nhood: Morningside Heights<br>dropoff_nhood: West Village",null,"ave_tip: 0.13<br>pickup_nhood: North Sutton Area<br>dropoff_nhood: West Village",null,null,"ave_tip: 0.13<br>pickup_nhood: Upper East Side<br>dropoff_nhood: West Village","ave_tip: 0.14<br>pickup_nhood: Upper West Side<br>dropoff_nhood: West Village","ave_tip: 0.12<br>pickup_nhood: Washington Heights<br>dropoff_nhood: West Village",null,"ave_tip: 0.12<br>pickup_nhood: Yorkville<br>dropoff_nhood: West Village"],["ave_tip: 0.15<br>pickup_nhood: Battery Park<br>dropoff_nhood: Yorkville",null,"ave_tip: 0.12<br>pickup_nhood: Chelsea<br>dropoff_nhood: Yorkville","ave_tip: 0.1<br>pickup_nhood: Chinatown<br>dropoff_nhood: Yorkville","ave_tip: 0.11<br>pickup_nhood: Clinton<br>dropoff_nhood: Yorkville",null,"ave_tip: 0.12<br>pickup_nhood: East Village<br>dropoff_nhood: Yorkville","ave_tip: 0.13<br>pickup_nhood: Financial District<br>dropoff_nhood: Yorkville","ave_tip: 0.11<br>pickup_nhood: Garment District<br>dropoff_nhood: Yorkville","ave_tip: 0.12<br>pickup_nhood: Gramercy<br>dropoff_nhood: Yorkville","ave_tip: 0.12<br>pickup_nhood: Greenwich Village<br>dropoff_nhood: Yorkville","ave_tip: 0.08<br>pickup_nhood: Hamilton Heights<br>dropoff_nhood: Yorkville",null,"ave_tip: 0.09<br>pickup_nhood: Inwood<br>dropoff_nhood: Yorkville","ave_tip: 0.13<br>pickup_nhood: Little Italy<br>dropoff_nhood: Yorkville","ave_tip: 0.12<br>pickup_nhood: Lower East Side<br>dropoff_nhood: Yorkville","ave_tip: 0.13<br>pickup_nhood: Midtown<br>dropoff_nhood: Yorkville",null,"ave_tip: 0.12<br>pickup_nhood: Murray Hill<br>dropoff_nhood: Yorkville",null,"ave_tip: 0.14<br>pickup_nhood: Soho<br>dropoff_nhood: Yorkville","ave_tip: 0.13<br>pickup_nhood: Tribeca<br>dropoff_nhood: Yorkville",null,null,"ave_tip: 0.1<br>pickup_nhood: Washington Heights<br>dropoff_nhood: Yorkville","ave_tip: 0.12<br>pickup_nhood: West Village<br>dropoff_nhood: Yorkville",null]],"colorscale":[[0,"#FFFFFF"],[0.0182587869795911,"#FCFDFE"],[0.0560675471691761,"#F5F8FB"],[0.0959859730397815,"#EEF2F8"],[0.0966501311270093,"#EEF2F8"],[0.0977164301043574,"#EEF2F8"],[0.112193687031217,"#EBF0F7"],[0.149552852211939,"#E5EBF4"],[0.158990717528893,"#E3EAF3"],[0.169522028107417,"#E1E9F2"],[0.174694690823838,"#E0E8F2"],[0.176286872694426,"#E0E8F2"],[0.187306860412278,"#DEE6F1"],[0.188657828619459,"#DEE6F1"],[0.19119510054442,"#DDE6F1"],[0.193685497951177,"#DDE6F0"],[0.195457844160974,"#DDE5F0"],[0.214094670835352,"#D9E3EF"],[0.235027687449971,"#D6E0ED"],[0.237748537063204,"#D5E0ED"],[0.241222681983883,"#D5DFED"],[0.251137012194618,"#D3DEEC"],[0.252131315162355,"#D3DEEC"],[0.252453379059755,"#D3DEEC"],[0.260832999566876,"#D1DDEB"],[0.261076310765664,"#D1DDEB"],[0.261103877727816,"#D1DDEB"],[0.261423495026321,"#D1DDEB"],[0.268335121633435,"#D0DCEB"],[0.271005698913959,"#CFDCEB"],[0.275459984947718,"#CFDBEA"],[0.278643891208125,"#CEDBEA"],[0.281136306654101,"#CEDAEA"],[0.283461440483807,"#CDDAEA"],[0.284010467555822,"#CDDAEA"],[0.284292408181803,"#CDDAEA"],[0.284962324196313,"#CDDAEA"],[0.285540187490368,"#CDDAE9"],[0.291749520981862,"#CCD9E9"],[0.29322424823356,"#CCD9E9"],[0.3014509301612,"#CAD8E8"],[0.307117765043805,"#C9D7E8"],[0.307895114292536,"#C9D7E8"],[0.311476975444768,"#C8D6E8"],[0.313950931810655,"#C8D6E7"],[0.314157284143064,"#C8D6E7"],[0.317500859609403,"#C7D6E7"],[0.318954980531076,"#C7D5E7"],[0.319063551579682,"#C7D5E7"],[0.321481467120057,"#C7D5E7"],[0.323104476195775,"#C6D5E7"],[0.324237586940338,"#C6D5E7"],[0.324247528309142,"#C6D5E7"],[0.325012524422202,"#C6D5E6"],[0.333439924844302,"#C5D4E6"],[0.339217148282512,"#C4D3E5"],[0.343667463715114,"#C3D2E5"],[0.343747031985751,"#C3D2E5"],[0.346827488305201,"#C2D2E5"],[0.348146882285433,"#C2D2E5"],[0.349054185180499,"#C2D2E5"],[0.350456975435759,"#C2D1E5"],[0.35346034064424,"#C1D1E4"],[0.356700644025072,"#C0D1E4"],[0.358773516277899,"#C0D0E4"],[0.359157481189438,"#C0D0E4"],[0.360155617764797,"#C0D0E4"],[0.360804206682853,"#C0D0E4"],[0.360902440934051,"#C0D0E4"],[0.362992632506864,"#BFD0E4"],[0.36327647678524,"#BFD0E4"],[0.367062454207518,"#BFCFE3"],[0.368118987267381,"#BECFE3"],[0.368261155516201,"#BECFE3"],[0.37121168325388,"#BECFE3"],[0.377701486903694,"#BDCEE3"],[0.37908289045862,"#BDCEE2"],[0.379085810693932,"#BDCEE2"],[0.382582795834243,"#BCCDE2"],[0.384017019275618,"#BCCDE2"],[0.384929636660592,"#BBCDE2"],[0.387569912857327,"#BBCDE2"],[0.391319820900805,"#BACCE2"],[0.391864719202279,"#BACCE1"],[0.394819761579401,"#BACCE1"],[0.394943106831272,"#BACCE1"],[0.39500026750436,"#BACCE1"],[0.396990882913667,"#B9CBE1"],[0.399142041222486,"#B9CBE1"],[0.399527707787811,"#B9CBE1"],[0.401168651915314,"#B9CBE1"],[0.401669409876022,"#B9CBE1"],[0.402502306109275,"#B8CBE1"],[0.403591636917816,"#B8CBE1"],[0.406953621482114,"#B8CAE0"],[0.406988401116357,"#B8CAE0"],[0.408207375589351,"#B7CAE0"],[0.40947087863852,"#B7CAE0"],[0.410070067865975,"#B7CAE0"],[0.411196661263673,"#B7CAE0"],[0.411641405117895,"#B7CAE0"],[0.411685605904863,"#B7CAE0"],[0.412962906502784,"#B7C9E0"],[0.416052589313956,"#B6C9E0"],[0.417933177580847,"#B6C9E0"],[0.418421288876329,"#B6C9DF"],[0.418611058355373,"#B6C9DF"],[0.421781500493096,"#B5C8DF"],[0.423863752676338,"#B5C8DF"],[0.426554286504111,"#B4C8DF"],[0.426639233326041,"#B4C8DF"],[0.428320289364853,"#B4C7DF"],[0.428438925862969,"#B4C7DF"],[0.430911003384527,"#B3C7DF"],[0.43130765364828,"#B3C7DF"],[0.432709096572166,"#B3C7DE"],[0.433690812552556,"#B3C7DE"],[0.435954429545956,"#B2C6DE"],[0.436050387309775,"#B2C6DE"],[0.437154372892431,"#B2C6DE"],[0.437666697663423,"#B2C6DE"],[0.438696960154531,"#B2C6DE"],[0.440092798821944,"#B2C6DE"],[0.440166796359814,"#B2C6DE"],[0.442175327598488,"#B1C6DE"],[0.445974348987903,"#B1C5DD"],[0.44643114255776,"#B1C5DD"],[0.447057472871592,"#B1C5DD"],[0.447523537311281,"#B0C5DD"],[0.447546682774745,"#B0C5DD"],[0.4482448694582,"#B0C5DD"],[0.44831431788297,"#B0C5DD"],[0.449445064358291,"#B0C5DD"],[0.449543941061766,"#B0C5DD"],[0.450614104112924,"#B0C5DD"],[0.450693991015352,"#B0C5DD"],[0.452404349501503,"#B0C4DD"],[0.452685684502616,"#B0C4DD"],[0.455024349855034,"#AFC4DD"],[0.456080145352528,"#AFC4DD"],[0.456606075200951,"#AFC4DD"],[0.457236075336596,"#AFC4DD"],[0.461560686897499,"#AEC3DC"],[0.461688609010254,"#AEC3DC"],[0.462527702779921,"#AEC3DC"],[0.463602979645218,"#AEC3DC"],[0.463803804236159,"#AEC3DC"],[0.463908296415316,"#AEC3DC"],[0.464251447935426,"#ADC3DC"],[0.464533553858504,"#ADC3DC"],[0.46693900862396,"#ADC3DC"],[0.467140376919766,"#ADC3DC"],[0.468527247711344,"#ADC2DC"],[0.469409684328737,"#ADC2DC"],[0.470659021422131,"#ACC2DC"],[0.470669575673224,"#ACC2DC"],[0.471209821232913,"#ACC2DC"],[0.47202173345847,"#ACC2DB"],[0.472155949188361,"#ACC2DB"],[0.472463031589256,"#ACC2DB"],[0.472787370426695,"#ACC2DB"],[0.473174037125468,"#ACC2DB"],[0.473301230360635,"#ACC2DB"],[0.47477962640087,"#ACC2DB"],[0.475729170159752,"#ABC1DB"],[0.476284631569612,"#ABC1DB"],[0.476368141295915,"#ABC1DB"],[0.477110523666595,"#ABC1DB"],[0.477669451060156,"#ABC1DB"],[0.478354759006977,"#ABC1DB"],[0.479663066861436,"#ABC1DB"],[0.480472048864024,"#ABC1DB"],[0.480529107682032,"#ABC1DB"],[0.480988635986361,"#ABC1DB"],[0.481142796007963,"#AAC1DB"],[0.483890341452858,"#AAC0DB"],[0.485690101371843,"#AAC0DA"],[0.485866629071492,"#AAC0DA"],[0.486116486095099,"#AAC0DA"],[0.486895599065546,"#A9C0DA"],[0.487596704108317,"#A9C0DA"],[0.488340008244287,"#A9C0DA"],[0.488691493664518,"#A9C0DA"],[0.488989099000327,"#A9C0DA"],[0.489055912187624,"#A9C0DA"],[0.489786489427612,"#A9C0DA"],[0.489839031732199,"#A9C0DA"],[0.490384506807251,"#A9C0DA"],[0.490596522468863,"#A9C0DA"],[0.491473650466941,"#A9BFDA"],[0.491768200721872,"#A9BFDA"],[0.491832794246668,"#A9BFDA"],[0.491841158005713,"#A9BFDA"],[0.492546602729291,"#A8BFDA"],[0.494488381105173,"#A8BFDA"],[0.494770909401258,"#A8BFDA"],[0.495600636824164,"#A8BFDA"],[0.495710640925705,"#A8BFDA"],[0.497379852532748,"#A8BFDA"],[0.49826676456345,"#A7BFD9"],[0.498841050029981,"#A7BFD9"],[0.499231939923192,"#A7BFD9"],[0.50165695321839,"#A7BED9"],[0.502262001705119,"#A7BED9"],[0.502832491341153,"#A7BED9"],[0.503491801188868,"#A7BED9"],[0.504220786417153,"#A6BED9"],[0.504293997823902,"#A6BED9"],[0.50435903846551,"#A6BED9"],[0.505450616824324,"#A6BED9"],[0.507050911332794,"#A6BED9"],[0.507550037274514,"#A6BDD9"],[0.50758491952887,"#A6BDD9"],[0.507813081277236,"#A6BDD9"],[0.507883028075615,"#A6BDD9"],[0.50829033637807,"#A6BDD9"],[0.508478557424655,"#A6BDD9"],[0.509221341081607,"#A6BDD9"],[0.510377447845143,"#A5BDD9"],[0.511139147292617,"#A5BDD9"],[0.512981113824923,"#A5BDD8"],[0.513513709592182,"#A5BDD8"],[0.513646054447383,"#A5BDD8"],[0.515286958522829,"#A4BCD8"],[0.517632742977553,"#A4BCD8"],[0.517804961064976,"#A4BCD8"],[0.51916419183057,"#A4BCD8"],[0.519527511150549,"#A4BCD8"],[0.520300628896462,"#A4BCD8"],[0.520820999372788,"#A3BCD8"],[0.52184120506703,"#A3BCD8"],[0.523031847632725,"#A3BCD8"],[0.523131727889638,"#A3BCD8"],[0.523560962915362,"#A3BBD8"],[0.524510026294532,"#A3BBD8"],[0.524672469757068,"#A3BBD7"],[0.524955277300221,"#A3BBD7"],[0.525920904698594,"#A3BBD7"],[0.526294435931451,"#A2BBD7"],[0.526389795554031,"#A2BBD7"],[0.52654375143537,"#A2BBD7"],[0.526579266771441,"#A2BBD7"],[0.527486837531591,"#A2BBD7"],[0.528826760050875,"#A2BBD7"],[0.529655654126147,"#A2BBD7"],[0.530772682831862,"#A2BBD7"],[0.532232218288087,"#A1BAD7"],[0.535391559462758,"#A1BAD7"],[0.535700237805217,"#A1BAD7"],[0.536951279456855,"#A1BAD7"],[0.537370763756975,"#A0BAD7"],[0.539298828423263,"#A0B9D6"],[0.539824308973112,"#A0B9D6"],[0.540991620254721,"#A0B9D6"],[0.541130007366164,"#A0B9D6"],[0.543835078210461,"#9FB9D6"],[0.545498125592787,"#9FB9D6"],[0.545636225859367,"#9FB9D6"],[0.546097502490191,"#9FB9D6"],[0.546492046824238,"#9FB9D6"],[0.549827049709815,"#9EB8D6"],[0.550274338581659,"#9EB8D6"],[0.550889676006611,"#9EB8D6"],[0.551057364093343,"#9EB8D6"],[0.552972791500579,"#9EB8D5"],[0.553774535903901,"#9EB8D5"],[0.554588600436476,"#9DB8D5"],[0.555331353031883,"#9DB8D5"],[0.556153640210605,"#9DB7D5"],[0.556257090452819,"#9DB7D5"],[0.556869469360607,"#9DB7D5"],[0.55733207665223,"#9DB7D5"],[0.558029795279312,"#9DB7D5"],[0.558089043876686,"#9DB7D5"],[0.559376905887907,"#9DB7D5"],[0.562074972001972,"#9CB7D5"],[0.562352017003939,"#9CB7D5"],[0.563547807963217,"#9CB6D5"],[0.563607806232553,"#9CB6D5"],[0.564281004589574,"#9CB6D5"],[0.565304090864387,"#9BB6D4"],[0.565482401943123,"#9BB6D4"],[0.567710420689361,"#9BB6D4"],[0.567808411660331,"#9BB6D4"],[0.567865444221196,"#9BB6D4"],[0.568180610110601,"#9BB6D4"],[0.569874459363456,"#9BB6D4"],[0.570208066026532,"#9BB6D4"],[0.571558208123701,"#9AB5D4"],[0.572772096427708,"#9AB5D4"],[0.57280115030542,"#9AB5D4"],[0.572867313936438,"#9AB5D4"],[0.573358754680082,"#9AB5D4"],[0.574494493606608,"#9AB5D4"],[0.574530122692582,"#9AB5D4"],[0.575612253320483,"#9AB5D4"],[0.575700490762488,"#9AB5D4"],[0.57586817393437,"#9AB5D4"],[0.577969124451492,"#99B5D4"],[0.578401773577511,"#99B5D3"],[0.579634967152385,"#99B4D3"],[0.579861572331044,"#99B4D3"],[0.580948089122947,"#99B4D3"],[0.581376667161901,"#99B4D3"],[0.581949534637277,"#99B4D3"],[0.582565146261242,"#98B4D3"],[0.583986577187491,"#98B4D3"],[0.584170349135422,"#98B4D3"],[0.58430437712817,"#98B4D3"],[0.586028626332395,"#98B4D3"],[0.586740952670893,"#98B4D3"],[0.58717991825187,"#98B4D3"],[0.58771159528582,"#97B3D3"],[0.589171606168958,"#97B3D3"],[0.589518800937647,"#97B3D3"],[0.58984770503378,"#97B3D3"],[0.59009457556351,"#97B3D3"],[0.590801387843184,"#97B3D3"],[0.590831104027673,"#97B3D3"],[0.591318729012414,"#97B3D3"],[0.592277362533382,"#97B3D2"],[0.593989621024169,"#96B3D2"],[0.595327317992993,"#96B3D2"],[0.595457154972357,"#96B3D2"],[0.596891877328639,"#96B2D2"],[0.596985464881574,"#96B2D2"],[0.597055586894735,"#96B2D2"],[0.597859669530448,"#96B2D2"],[0.598558160043415,"#96B2D2"],[0.598621552800625,"#96B2D2"],[0.599733001698897,"#95B2D2"],[0.600176135847804,"#95B2D2"],[0.600283548476785,"#95B2D2"],[0.602392941736808,"#95B2D2"],[0.603653821700536,"#95B2D2"],[0.603912125227235,"#95B1D2"],[0.604468849541271,"#94B1D2"],[0.605607169896045,"#94B1D1"],[0.607931874708565,"#94B1D1"],[0.608180460088886,"#94B1D1"],[0.608928629230858,"#94B1D1"],[0.609062123216108,"#94B1D1"],[0.609195714860071,"#94B1D1"],[0.609221585637647,"#94B1D1"],[0.610836972872827,"#93B1D1"],[0.613479922335332,"#93B0D1"],[0.614214791039563,"#93B0D1"],[0.616775301490517,"#92B0D1"],[0.619493249943867,"#92B0D0"],[0.61962158335624,"#92B0D0"],[0.619875079586083,"#92B0D0"],[0.621073843017701,"#91AFD0"],[0.621996537663815,"#91AFD0"],[0.623250508309066,"#91AFD0"],[0.623857869429435,"#91AFD0"],[0.623866721631853,"#91AFD0"],[0.625392986094369,"#91AFD0"],[0.626647575566108,"#90AFD0"],[0.627237999538152,"#90AFD0"],[0.62784048459495,"#90AFD0"],[0.632726314152218,"#8FAECF"],[0.633089126140143,"#8FAECF"],[0.633827978387674,"#8FAECF"],[0.634248478232573,"#8FAECF"],[0.634550441195705,"#8FAECF"],[0.634794475557892,"#8FAECF"],[0.637256979754957,"#8FADCF"],[0.63739234056839,"#8EADCF"],[0.637821873284797,"#8EADCF"],[0.638045315777653,"#8EADCF"],[0.639697946645938,"#8EADCF"],[0.641409490920406,"#8EADCF"],[0.643297428525911,"#8DADCF"],[0.64357784007719,"#8DADCF"],[0.647006463720694,"#8DACCE"],[0.647221123723123,"#8DACCE"],[0.647744337997379,"#8DACCE"],[0.648687350083259,"#8CACCE"],[0.648720624400598,"#8CACCE"],[0.651327145234633,"#8CACCE"],[0.652054612710472,"#8CACCE"],[0.652717250650482,"#8CABCE"],[0.655086721373222,"#8BABCE"],[0.656801276150699,"#8BABCE"],[0.656858717124674,"#8BABCE"],[0.660207802572503,"#8AABCD"],[0.663832881421335,"#8AAACD"],[0.667574575464338,"#89AACD"],[0.667787296541759,"#89AACD"],[0.668615273454122,"#89AACD"],[0.669256780710413,"#89A9CD"],[0.673071253726068,"#88A9CC"],[0.673629190533724,"#88A9CC"],[0.673999580002122,"#88A9CC"],[0.690746559003333,"#85A7CB"],[0.690960648861609,"#85A7CB"],[0.698153892217031,"#83A6CB"],[0.702814538487751,"#83A5CA"],[0.722233517303795,"#7FA3C9"],[0.726485800440648,"#7EA2C8"],[0.754505414897274,"#799FC6"],[0.789190650924692,"#729BC4"],[0.795598492590613,"#719AC3"],[0.798113980690646,"#719AC3"],[0.817824495476734,"#6D97C2"],[0.867401062008363,"#6392BE"],[0.867922495060666,"#6391BE"],[1,"#4682B4"]],"type":"heatmap","showscale":false,"autocolorscale":false,"showlegend":false,"xaxis":"x","yaxis":"y","hoverinfo":"text","name":[],"frame":null},{"x":[0.4,27.6],"y":[0.4,27.6],"name":"99_2b4d1ee098a39940fde4dfc17aa17ad5","type":"scatter","mode":"markers","opacity":0,"hoverinfo":"none","showlegend":false,"marker":{"color":[0,1],"colorscale":[[0,"#FCFDFE"],[0.04,"#F5F8FB"],[0.0800000000000001,"#EFF3F8"],[0.12,"#E8EEF5"],[0.16,"#E1E9F2"],[0.2,"#DAE4EF"],[0.24,"#D4DFEC"],[0.28,"#CDDAE9"],[0.32,"#C6D5E7"],[0.36,"#BFD0E4"],[0.4,"#B9CBE1"],[0.44,"#B2C6DE"],[0.48,"#ABC1DB"],[0.52,"#A4BCD8"],[0.56,"#9DB7D5"],[0.6,"#96B3D2"],[0.64,"#8FAECF"],[0.68,"#88A9CC"],[0.72,"#81A4CA"],[0.76,"#7AA0C7"],[0.8,"#739BC4"],[0.84,"#6B97C1"],[0.88,"#6392BE"],[0.92,"#5C8DBB"],[0.96,"#5389B8"],[1,"#4B84B5"]],"colorbar":{"bgcolor":"rgba(255,255,255,1)","bordercolor":"transparent","borderwidth":1.88976377952756,"thickness":23.04,"title":"ave_tip","titlefont":{"color":"rgba(0,0,0,1)","family":"","size":14.6118721461187},"tickmode":"array","ticktext":["0.06","0.09","0.12","0.15","0.18"],"tickvals":[0,0.24,0.48,0.72,0.96],"tickfont":{"color":"rgba(0,0,0,1)","family":"","size":11.689497716895},"ticklen":2,"len":0.5}},"xaxis":"x","yaxis":"y","frame":null}],"layout":{"margin":{"t":26.2283105022831,"r":7.30593607305936,"b":87.1525845003701,"l":136.62100456621},"plot_bgcolor":"rgba(255,255,255,1)","paper_bgcolor":"rgba(255,255,255,1)","font":{"color":"rgba(0,0,0,1)","family":"","size":14.6118721461187},"xaxis":{"domain":[0,1],"type":"linear","autorange":false,"tickmode":"array","range":[0.4,27.6],"ticktext":["Battery Park","Central Park","Chelsea","Chinatown","Clinton","East Harlem","East Village","Financial District","Garment District","Gramercy","Greenwich Village","Hamilton Heights","Harlem","Inwood","Little Italy","Lower East Side","Midtown","Morningside Heights","Murray Hill","North Sutton Area","Soho","Tribeca","Upper East Side","Upper West Side","Washington Heights","West Village","Yorkville"],"tickvals":[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27],"ticks":"outside","tickcolor":"rgba(51,51,51,1)","ticklen":3.65296803652968,"tickwidth":0.66417600664176,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":11.689497716895},"tickangle":-45,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(235,235,235,1)","gridwidth":0.66417600664176,"zeroline":false,"anchor":"y","title":"pickup_nhood","titlefont":{"color":"rgba(0,0,0,1)","family":"","size":14.6118721461187},"hoverformat":".2f"},"yaxis":{"domain":[0,1],"type":"linear","autorange":false,"tickmode":"array","range":[0.4,27.6],"ticktext":["Battery Park","Central Park","Chelsea","Chinatown","Clinton","East Harlem","East Village","Financial District","Garment District","Gramercy","Greenwich Village","Hamilton Heights","Harlem","Inwood","Little Italy","Lower East Side","Midtown","Morningside Heights","Murray Hill","North Sutton Area","Soho","Tribeca","Upper East Side","Upper West Side","Washington Heights","West Village","Yorkville"],"tickvals":[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27],"ticks":"outside","tickcolor":"rgba(51,51,51,1)","ticklen":3.65296803652968,"tickwidth":0.66417600664176,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":11.689497716895},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(235,235,235,1)","gridwidth":0.66417600664176,"zeroline":false,"anchor":"x","title":"dropoff_nhood","titlefont":{"color":"rgba(0,0,0,1)","family":"","size":14.6118721461187},"hoverformat":".2f"},"shapes":[{"type":"rect","fillcolor":"transparent","line":{"color":"rgba(51,51,51,1)","width":0.66417600664176,"linetype":"solid"},"yref":"paper","xref":"paper","x0":0,"x1":1,"y0":0,"y1":1}],"showlegend":false,"legend":{"bgcolor":"rgba(255,255,255,1)","bordercolor":"transparent","borderwidth":1.88976377952756,"font":{"color":"rgba(0,0,0,1)","family":"","size":11.689497716895}},"hovermode":"closest","dragmode":"zoom"},"config":{"doubleClick":"reset","modeBarButtonsToAdd":[{"name":"Collaborate","icon":{"width":1000,"ascent":500,"descent":-50,"path":"M487 375c7-10 9-23 5-36l-79-259c-3-12-11-23-22-31-11-8-22-12-35-12l-263 0c-15 0-29 5-43 15-13 10-23 23-28 37-5 13-5 25-1 37 0 0 0 3 1 7 1 5 1 8 1 11 0 2 0 4-1 6 0 3-1 5-1 6 1 2 2 4 3 6 1 2 2 4 4 6 2 3 4 5 5 7 5 7 9 16 13 26 4 10 7 19 9 26 0 2 0 5 0 9-1 4-1 6 0 8 0 2 2 5 4 8 3 3 5 5 5 7 4 6 8 15 12 26 4 11 7 19 7 26 1 1 0 4 0 9-1 4-1 7 0 8 1 2 3 5 6 8 4 4 6 6 6 7 4 5 8 13 13 24 4 11 7 20 7 28 1 1 0 4 0 7-1 3-1 6-1 7 0 2 1 4 3 6 1 1 3 4 5 6 2 3 3 5 5 6 1 2 3 5 4 9 2 3 3 7 5 10 1 3 2 6 4 10 2 4 4 7 6 9 2 3 4 5 7 7 3 2 7 3 11 3 3 0 8 0 13-1l0-1c7 2 12 2 14 2l218 0c14 0 25-5 32-16 8-10 10-23 6-37l-79-259c-7-22-13-37-20-43-7-7-19-10-37-10l-248 0c-5 0-9-2-11-5-2-3-2-7 0-12 4-13 18-20 41-20l264 0c5 0 10 2 16 5 5 3 8 6 10 11l85 282c2 5 2 10 2 17 7-3 13-7 17-13z m-304 0c-1-3-1-5 0-7 1-1 3-2 6-2l174 0c2 0 4 1 7 2 2 2 4 4 5 7l6 18c0 3 0 5-1 7-1 1-3 2-6 2l-173 0c-3 0-5-1-8-2-2-2-4-4-4-7z m-24-73c-1-3-1-5 0-7 2-2 3-2 6-2l174 0c2 0 5 0 7 2 3 2 4 4 5 7l6 18c1 2 0 5-1 6-1 2-3 3-5 3l-174 0c-3 0-5-1-7-3-3-1-4-4-5-6z"},"click":"function(gd) { \n        // is this being viewed in RStudio?\n        if (location.search == '?viewer_pane=1') {\n          alert('To learn about plotly for collaboration, visit:\\n https://cpsievert.github.io/plotly_book/plot-ly-for-collaboration.html');\n        } else {\n          window.open('https://cpsievert.github.io/plotly_book/plot-ly-for-collaboration.html', '_blank');\n        }\n      }"}],"modeBarButtonsToRemove":["sendDataToCloud"]},"source":"A","attrs":{"73732187a289":{"fill":{},"x":{},"y":{},"type":"ggplotly"}},"cur_data":"73732187a289","visdat":{"73732187a289":["function (y) ","x"]},"highlight":{"on":"plotly_selected","off":"plotly_relayout","persistent":false,"dynamic":false,"color":null,"selectize":false,"defaultValues":null,"opacityDim":0.2,"hoverinfo":null,"showInLegend":false},"base_url":"https://plot.ly"},"evals":["config.modeBarButtonsToAdd.0.click"],"jsHooks":{"render":[{"code":"function(el, x) {\n    var ctConfig = crosstalk.var('plotlyCrosstalkOpts').set({\"on\":\"plotly_selected\",\"off\":\"plotly_relayout\",\"persistent\":false,\"dynamic\":false,\"color\":{},\"selectize\":false,\"defaultValues\":{},\"opacityDim\":0.2,\"hoverinfo\":{},\"showInLegend\":false});\n  }","data":null}]}}</script><!--/html_preserve-->

# Split and Combining Operations with doXdf

## Custom functions across groups

The `do` verb is an exception to the rule that dplyrXdf verbs write their output as xdf files. This is because do executes arbitrary R code, and can return arbitrary R objects; while a data frame is capable of storing these objects, an xdf file is limited to character and numeric vectors only.

## Custom functions across groups

The doXdf verb is similar to do, but where do splits its input into one data frame per group, doXdf splits it into one xdf file per group. This allows do-like functionality with grouped data, where each group can be arbitrarily large. The syntax for the two functions is essentially the same, although the code passed to doXdf must obviously know how to handle xdfs.

---


```r
taxi_models <- taxi_xdf %>% group_by(pickup_dow) %>% doXdf(model = rxLinMod(tip_amount ~ fare_amount, data = .))
```


```r
taxi_models
```

```
## Source: local data frame [7 x 2]
## Groups: <by row>
## 
## # A tibble: 7 × 2
##   pickup_dow          model
## *     <fctr>         <list>
## 1        Fri <S3: rxLinMod>
## 2        Mon <S3: rxLinMod>
## 3        Sat <S3: rxLinMod>
## 4        Sun <S3: rxLinMod>
## 5        Thu <S3: rxLinMod>
## 6        Tue <S3: rxLinMod>
## 7        Wed <S3: rxLinMod>
```

```r
taxi_models$model[[1]]
```

```
## Call:
## rxLinMod(formula = tip_amount ~ fare_amount, data = .)
## 
## Linear Regression Results for: tip_amount ~ fare_amount
## Data: . (RxXdfData Data Source)
## File name: /tmp/RtmphytGxr/file73731f59af6.pickup_dow.Fri.xdf
## Dependent variable(s): tip_amount
## Total independent variables: 2 
## Number of valid observations: 5885510
## Number of missing observations: 0 
##  
## Coefficients:
##               tip_amount
## (Intercept) 1.6567742764
## fare_amount 0.0007725297
```


## Memory Issues

All the caveats that go with working with `data.frames` apply here. While each grouped partition is it's own `RxXdfData` object, the return value must be a `data.frame`, and hence, must fit in memory.
Moreover, the function you apply against the splits will determine how they are operated. If you use an `rx` function, you'll get the nice fault-tolerant, parallel execution strategies the `RevoScaleR` package provides, but for any vanilla/CRAN function will work with data.frames and can easily cause your session to crash.

---


```r
library(broom)
taxi_broom <- taxi_xdf %>% group_by(pickup_dow) %>% doXdf(model = lm(tip_amount ~ fare_amount, data = .))
```
Now we can apply the `broom::tidy` function at the row level to get summary statistics:


```r
library(broom)
tbl_df(taxi_broom) %>% tidy(model)
```

```
## Source: local data frame [14 x 6]
## Groups: pickup_dow [7]
## 
##    pickup_dow        term     estimate    std.error    statistic
##        <fctr>       <chr>        <dbl>        <dbl>        <dbl>
## 1         Sun (Intercept) 2.3135094526 7.571328e-01    3.0556190
## 2         Sun fare_amount 0.0004142143 3.428908e-03    0.1208006
## 3         Mon (Intercept) 0.0874830714 1.422496e-03   61.4996928
## 4         Mon fare_amount 0.1273401404 8.615129e-05 1478.0991027
## 5         Tue (Intercept) 1.6038100602 1.087692e-03 1474.5078486
## 6         Tue fare_amount 0.0071964814 2.400197e-05  299.8287270
## 7         Wed (Intercept) 0.0115389375 1.377781e-03    8.3750150
## 8         Wed fare_amount 0.1386170412 8.666624e-05 1599.4352913
## 9         Thu (Intercept) 0.2319764306 1.340523e-03  173.0491740
## 10        Thu fare_amount 0.1180815950 8.138576e-05 1450.8876936
## 11        Fri (Intercept) 1.6567742764 1.035926e-03 1599.3176836
## 12        Fri fare_amount 0.0007725297 7.730892e-06   99.9276322
## 13        Sat (Intercept) 1.4252806941 8.801076e-04 1619.4390909
## 14        Sat fare_amount 0.0025861524 1.405561e-05  183.9943833
## # ... with 1 more variables: p.value <dbl>
```

