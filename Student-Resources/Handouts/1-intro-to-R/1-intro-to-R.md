# Introduction to R: _Functional, Object-Based Computing for Data Analysis_
[Ali Zaidi, alizaidi@microsoft.com](mailto:alizaidi@microsoft.com)  
`r format(Sys.Date(), "%B %d, %Y")`  



# Course Logistics

## Day One

### R U Ready?

* Overview of The R Project for Statistical Computing
* The Microsoft R Family
* R's capabilities and it's limitations
* What types of problems R might be useful for
* How to manage data with the exceptionally popular open source package `dplyr`
* How to develop models and write functions in R

## Day Two 

### Scalable Data Analysis with Microsoft R

* Moving the compute to your data
* WODA - Write Once, Deploy Anywhere
* High Performance Analytics
* High Performance Computing
* Machine Learning with Microsoft R

## Day Three

### Distributing Computing on Spark Clusters with R

* Overview of the Apache Spark Project
* Taming the Hadoop Zoo with HDInsight
* Provisioing and Managing HDInsight Clusters
* Spark DataFrames, `SparkR`, and the `sparklyr` package
* Developing Machine Learning Pipelines with `Spark` and Microsoft R

## Prerequisites
### Computing Environments

* R Server 8.0.5 or above
* Azure Credits
* Can use the [Linux DSVM](https://azure.microsoft.com/en-us/documentation/articles/machine-learning-data-science-linux-dsvm-intro/)
* Or the [Windows DSVM](https://azure.microsoft.com/en-us/documentation/articles/machine-learning-data-science-provision-vm/)
* For IDE: use [RTVS](https://www.visualstudio.com/vs/rtvs/), [RStudio Server](https://www.rstudio.com/products/rstudio/download3/), [JupyterHub](https://jupyterhub.readthedocs.io/en/latest/), [JupyterLab](http://jupyterlab-tutorial.readthedocs.io/en/latest/)... 
    + Whatever you're comfortable with!

## Development Environments 
### Where to Write R Code

* The most popular integrated development environment for R is [RStudio](https://www.rstudio.com/)
* The RStudio IDE is entirely html/javascript based, so completely cross-platform
* RStudio Server provides a full IDE in your browser: perfect for cloud instances
* For Windows machines, we have recently announced the general availability of [R Tools for Visual Studio, RTVS](https://www.visualstudio.com/en-us/features/rtvs-vs.aspx)
* RTVS supports connectivity to Azure and SQL Server


## What is R? 
### Why should I care?

* R is the successor to the S Language, originated at Bell Labs AT&T
* It is based on the Scheme interpreter
* Originally designed by two University of Auckland Professors for their introductory statistics course

![Robert Gentleman and Ross Ihaka](http://revolution-computing.typepad.com/.a/6a010534b1db25970b016766fdae38970b-800wi)

## R's Philosophy 
### What R Thou?

R follows the [Unix philosophy](http://en.wikipedia.org/wiki/Unix_philosophy)

* Write programs that do one thing and do it well (modularity)
* Write programs that work together (cohesiveness)
* R is extensible with more than 10,000 packages available at CRAN (http://crantastic.org/packages)


## The aRt of Being Lazy
### Lazy Evaluation in R

![](http://i.imgur.com/5GbW690.gif)


* R, like it's inspiration, Scheme, is a _functional_ programming language
* R evaluates lazily, delaying evaluation until necessary, which can make it very flexible
* R is a highly interpreted dynamically typed language, allowing you to mutate variables and analyze datasets quickly, but is significantly slower than low-level, statically typed languages like C or Java
* R has a high memory footprint, and can easily lead to crashes if you aren't careful

## R's Programming Paradigm
### Keys to R

<span class="fragment">Everything that exist in R is an *object*</span>
<br>
<span class="fragment">Everything that happens in R is a *function call*</span>
<br>
<span class="fragment">R was born to *interface*</span>
<br>

<span class="fragment">_—John Chambers_</span>

## Strengths of R 
### Where R Succeeds

* Expressive
* Open source 
* Extendable -- nearly 10,000 packages with functions to use, and that list continues to grow
* Focused on statistics and machine learning -- cutting-edge algorithms and powerful data manipulation packages
* Advanced data structures and graphical capabilities
* Large user community, both within academia and industry
* It is designed by statisticians 

## Weaknesses of R 
### Where R Falls Short

* It is designed by statisticians
* Inefficient at element-by-element computations
* May make large demands on system resources, namely memory
* Data capacity limited by memory
* Single-threaded

## Some Essential Open Source Packages

* There are over 10,000 R packages to choose from, what do I start with?
* Data Management: `dplyr`, `tidyr`, `data.table`
* Visualization: `ggplot2`, `ggvis`, `htmlwidgets`, `shiny`
* Data Importing: `haven`, `RODBC`, `readr`, `foreign`
* Other favorites: `magrittr`, `rmarkdown`, `caret`

# R Foundations

## Command line prompts

Symbol | Meaning
------ | -------
 `<-`   | assignment operator
  `>`   | ready for a new command
  `+`   | awaiting the completion of an existing command 
  `?`   | get help for following function
  
Can change options either permanently at startup (see `?Startup`) or manually at each session with the `options` function, `options(repos = " ")` for example.

Check your CRAN mirror with `getOption("repos")`.

## I'm Lost! 
### Getting Help for R

* [Stack Overflow](http://stackoverflow.com/questions/tagged/r)
* [R Reference Card](https://cran.r-project.org/doc/contrib/Short-refcard.pdf)
* [RStudio Cheat Sheets](https://www.rstudio.com/resources/cheatsheets/)
* [R help mailing list and archives](https://stat.ethz.ch/mailman/listinfo/r-help)
* [Revolutions Blog](http://blog.revolutionanalytics.com/)
* [R-Bloggers](http://www.r-bloggers.com/)
* [RSeek](rseek.org)
* [RDocumentation](https://www.rdocumentation.org/)

## Quick Tour of Things You Need to Know
### Data Structures

> "Bad programmers worry about the code. 
> Good programmers worry about data structures and their relationships."
> - Linus Torvalds

* R's data structures can be described by their dimensionality, and their type.


|    | Homogeneous   | Heterogeneous |
|----|---------------|---------------|
| 1d | Atomic vector | List          |
| 2d | Matrix        | Data frame    |
| nd | Array         |               |

## Quick Tour of Things You Need to Know 

### Data Types

* Atomic vectors come in one of four types
* `logical` (boolean). Values: `TRUE` | `FALSE`
* `integer`
* `double` (often called numeric)
* `character`
* Rare types:
* `complex` 
* `raw`

## Manipulating Data Structures

### Subsetting Operators

* To create a vector, use `c`: `c(1, 4, 1, 3)`
* To create a list, use `list`: `list(1, 'hi', data.frame(1:10, letters[1:10]))`
* To subset a vector or list, use the `[ ]`
  - inside the brackets: 
    + positive integer vectors for indices you want 
    + negative integer vectors for indices you want to drop
    + logical vectors for indices you want to keep/drop (TRUE/FALSE)
    + character vectors for named vectors corresponding to which named elements you want to keep
    + subsetting a list with a single square bracket always returns a list
+ To subset a list and get back just that element, use `[[ ]]`

### Object Representation

+ To find the type of an object, use `class` (_higher level representation_)
+ To find how the object is stored in memory, use `typeof` (_lower level representation_)
+ Good time to do Lab 0!

# Data Manipulation with the dplyr Package

## Overview

Rather than describing the nitty gritty details of writing R code, I'd like you to get started at immediately writing R code.

As most of you are data scientists/data enthusiasts, I will showcase one of the most useful data manipulation packages in R, `dplyr`.
At the end of this session, you will have learned:

* How to manipulate data quickly with `dplyr` using a very intuitive _"grammar"_
* How to use `dplyr` to perform common exploratory analysis data manipulation procedures
* How to apply your own custom functions to group manipulations `dplyr` with `mutate()`, `summarise()` and `do()`
* Connect to remote databases to work with larger than memory datasets

## Why use dplyr? 
### The Grammar of Data Manipulation

* `dplyr` is currently the [most downloaded package](https://www.rdocumentation.org/packages/dplyr/versions/0.5.0?) from CRAN
* `dplyr` makes data manipulation easier by providing a few functions for the most common tasks and procedures
* `dplyr` achieves remarkable speed-up gains by using a C++ backend
* `dplyr` has multiple backends for working with data stored in various sources: SQLite, MySQL, bigquery, SQL Server, and many more
* `dplyr` was inspired to give data manipulation a simple, cohesive grammar (similar philosophy to `ggplot` - grammar of graphics)
* `dplyr` has inspired many new packages, which now adopt it's easy to understand syntax. 
* The recent packages `dplyrXdf` and `SparkR/sparklyr` brings much of the same functionality of `dplyr` to `XDF`s data and Spark `DataFrames`


## Tidy Data and Happier Coding
### Premature Optimization 

![](https://imgs.xkcd.com/comics/the_general_problem.png)

+ For a dats scientist, the most important parameter to optimize in a data science development cycle is YOUR time
+ It is therefore important to be able to write efficient code, quickly
+ Goals: writing fast code that is: portable, platform invariant, easy to understand, and easy to debug
    - __Be serious about CReUse__!

## Manipulation verbs

`filter`

:    select rows based on matching criteria

`slice`

:    select rows by number

`select`

:    select columns by column names

`arrange`

:    reorder rows by column values

`mutate`

:    add new variables based on transformations of existing variables

`transmute`

:    transform and drop other variables



## Aggregation verbs

`group_by`

:    identify grouping variables for calculating groupwise summary statistics


`count`

:    count the number of records per group


`summarise` | `summarize`

:    calculate one or more summary functions per group, returning one row of results per group (or one for the entire dataset)

## NYC Taxi Data
### Data for Class

* The data we will be examining in this module is dervided from the [NYC Taxi and Limousine Commission](http://www.nyc.gov/html/tlc/html/home/home.shtml)
* Data contains taxi trips in NYC, and includes spatial features (pickup and dropoff neighborhoods), temporal features, and monetary features (fare and tip amounts)
* The dataset for this module is saved as an _rds_ file in a public facing Azure storage blob
* An _rds_ file is a compressed, serialized R object
* Save an object to _rds_ by using the `saveRDS` function; read an _rds_ object with the `readRDS` object

## Viewing Data
### tibble

* `dplyr` includes a wrapper called `tbl_df` that adds an additional class attribute onto `data.frames` that provides some better data manipulation aesthetics (there's now a dedicated package [`tibble`](www.github.com/hadley/tibble) for this wrapper and it's class)
* Most noticeable differential between `tbl_df` and `data.frame`s is the console output: `tbl_df`s will only print what the current R console window can display
* Can change the default setting for number of displayed columns by changing the options parameter: `options(dplyr.width = Inf)` 


```r
library(dplyr)
library(stringr)
taxi_url <- "http://alizaidi.blob.core.windows.net/training/taxi_df.rds"
taxi_df  <- readRDS(gzcon(url(taxi_url)))
(taxi_df <- tbl_df(taxi_df))
```

```
## # A tibble: 3,770,319 × 16
##    VendorID passenger_count trip_distance RateCodeID store_and_fwd_flag
##       <chr>           <int>         <dbl>      <chr>              <chr>
## 1         1               1          1.80          1                  N
## 2         1               2          0.90          1                  N
## 3         1               1          0.90          1                  N
## 4         1               1          0.30          1                  N
## 5         2               1          0.96          1                  N
## 6         2               1          2.01          1                  N
## 7         2               3          3.14          1                  N
## 8         1               1          0.50          1                  N
## 9         2               1          0.67          1                  N
## 10        2               1         15.20          2                  N
## # ... with 3,770,309 more rows, and 11 more variables: payment_type <chr>,
## #   fare_amount <dbl>, tip_amount <dbl>, tolls_amount <dbl>,
## #   pickup_hour <chr>, pickup_dow <chr>, dropoff_hour <chr>,
## #   dropoff_dow <chr>, pickup_nhood <chr>, dropoff_nhood <chr>,
## #   kSplits <chr>
```

# Filtering and Reordering Data

## Subsetting Data

* `dplyr` makes subsetting by rows very easy
* The `filter` verb takes conditions for filtering rows based on conditions
* **every** `dplyr` function uses a data.frame/tbl as it's first argument
* Additional conditions are passed as new arguments (no need to make an insanely complicated expression, split em up!)

## Filter


```r
filter(taxi_df,
       dropoff_dow %in% c("Fri", "Sat", "Sun"),
       tip_amount > 1)
```

```
## # A tibble: 859,165 × 16
##    VendorID passenger_count trip_distance RateCodeID store_and_fwd_flag
##       <chr>           <int>         <dbl>      <chr>              <chr>
## 1         1               2          0.90          1                  N
## 2         1               1          0.90          1                  N
## 3         2               1          2.01          1                  N
## 4         2               3          3.14          1                  N
## 5         2               1          6.08          1                  N
## 6         2               1          1.96          1                  N
## 7         1               1          0.40          1                  N
## 8         1               2          1.70          1                  N
## 9         1               2          0.60          1                  N
## 10        1               2          9.30          1                  N
## # ... with 859,155 more rows, and 11 more variables: payment_type <chr>,
## #   fare_amount <dbl>, tip_amount <dbl>, tolls_amount <dbl>,
## #   pickup_hour <chr>, pickup_dow <chr>, dropoff_hour <chr>,
## #   dropoff_dow <chr>, pickup_nhood <chr>, dropoff_nhood <chr>,
## #   kSplits <chr>
```

## Exercise

Your turn: 

* How many observations started in Harlem?
  - pick both sides of Harlem, including east harlem
* How many observations that started in Harlem ended in the Financial District?

## Solution


```r
library(stringr)
table(taxi_df$pickup_nhood)
```

```
## 
##            Ardon Heights Astoria-Long Island City               Auburndale 
##                        1                    18553                       19 
##             Battery Park                Bay Ridge               Baychester 
##                    31427                      172                        8 
##             Bedford Park       Bedford-Stuyvesant              Bensonhurst 
##                       92                     3179                       95 
##              Boerum Hill             Borough Park              Brownsville 
##                     4400                      521                       85 
##                 Bushwick                 Canarsie            Carnegie Hill 
##                     1645                       85                    43052 
##          Carroll Gardens             Central Park                  Chelsea 
##                     5701                    47925                   257981 
##                Chinatown              City Island                Clearview 
##                    12102                        2                        8 
##                  Clifton                  Clinton              Cobble Hill 
##                        2                   117715                     2099 
##                   Corona             Country Club  Douglastown-Little Neck 
##                      119                       31                       68 
##                 Downtown            Dyker Heights            East Brooklyn 
##                     7148                       32                      120 
##              East Harlem             East Village              Eastchester 
##                    12161                   138604                        8 
##       Financial District                 Flatbush                 Flushing 
##                    76964                        2                      354 
##                  Fordham             Forest Hills               Fort Green 
##                       83                     1227                     9997 
##         Garment District                 Glendale                 Gramercy 
##                   213613                       61                   304905 
## Gravesend-Sheepshead Bay        Greenwich Village                Greenwood 
##                      163                   177965                      516 
##         Hamilton Heights                   Harlem              High Bridge 
##                     7543                    19864                      413 
##             Howland Hook              Hunts Point                   Inwood 
##                        2                       46                      312 
##          Jackson Heights                  Jamaica             Kings Bridge 
##                     3606                      784                      110 
##                Laurelton             Little Italy          Lower East Side 
##                       26                    33178                    89114 
##       Mapleton-Flatlands          Mariners Harbor                  Maspeth 
##                      393                        1                      290 
##           Middle Village            Midland Beach                  Midtown 
##                      100                        3                   625350 
##      Morningside Heights           Morris Heights              Morris Park 
##                    19741                      118                       64 
##               Mott Haven              Murray Hill             New Brighton 
##                     1309                   127663                       12 
##             Nkew Gardens        North Sutton Area                  Oakwood 
##                      459                    39678                        4 
##               Park Slope              Parkchester           Queens Village 
##                     3966                      113                       26 
##          Queensboro Hill             Richmondtown                Ridgewood 
##                       41                        3                      239 
##                Riverdale              Saintalbans                     Soho 
##                       53                       22                    78794 
##                Soundview              South Beach              South Bronx 
##                       89                        4                      421 
##      Springfield Gardens           Spuyten Duyvil                 Steinway 
##                       68                       17                        7 
##               Sunny Side              Sunset Park            The Rockaways 
##                    12493                      269                       34 
##             Throggs Neck                Todt Hill                  Tremont 
##                       33                        3                      109 
##                  Tribeca               Union Port       University Heights 
##                    63171                       58                       95 
##          Upper East Side          Upper West Side                   Utopia 
##                   513594                   313849                      391 
## Wakefield-Williamsbridge       Washington Heights             West Village 
##                       39                     4870                    90656 
##    Westerleigh-Castleton          Williams Bridge             Williamsburg 
##                        2                       26                    15521 
##  Woodhaven-Richmond Hill        Woodlawn-Nordwood                 Woodside 
##                      218                       25                     3151 
##                Yorkville 
##                    25353
```

```r
harlem_pickups <- filter(taxi_df, str_detect(pickup_nhood, "Harlem"))
harlem_pickups
```

```
## # A tibble: 32,025 × 16
##    VendorID passenger_count trip_distance RateCodeID store_and_fwd_flag
##       <chr>           <int>         <dbl>      <chr>              <chr>
## 1         1               1          0.70          1                  N
## 2         1               1          1.10          1                  N
## 3         2               1         18.79          2                  N
## 4         2               1          4.66          1                  N
## 5         2               5          0.67          1                  N
## 6         2               3          0.76          1                  N
## 7         1               1          2.70          1                  N
## 8         2               1          3.19          1                  N
## 9         2               1          0.85          1                  N
## 10        2               2          6.06          1                  N
## # ... with 32,015 more rows, and 11 more variables: payment_type <chr>,
## #   fare_amount <dbl>, tip_amount <dbl>, tolls_amount <dbl>,
## #   pickup_hour <chr>, pickup_dow <chr>, dropoff_hour <chr>,
## #   dropoff_dow <chr>, pickup_nhood <chr>, dropoff_nhood <chr>,
## #   kSplits <chr>
```

## Select a set of columns

* You can use the `select()` verb to specify which columns of a dataset you want
* This is similar to the `keep` option in SAS's data step.
* Use a colon `:` to select all the columns between two variables (inclusive)
* Use `contains` to take any columns containing a certain word/phrase/character

## Select Example


```r
select(taxi_df, pickup_nhood, dropoff_nhood, 
       fare_amount, dropoff_hour, trip_distance)
```

```
## # A tibble: 3,770,319 × 5
##           pickup_nhood      dropoff_nhood fare_amount dropoff_hour
##                  <chr>              <chr>       <dbl>        <chr>
## 1  Morningside Heights   Hamilton Heights         9.5         6-10
## 2              Midtown            Midtown         6.5         6-10
## 3      Lower East Side               Soho         7.0         6-10
## 4   Financial District Financial District         3.0         6-10
## 5              Chelsea       West Village         5.5         6-10
## 6      Upper East Side             Harlem         9.5         10-5
## 7           Fort Green               Soho        12.5         12-4
## 8      Upper East Side    Upper East Side         4.0         12-4
## 9      Upper West Side    Upper West Side         5.0         12-4
## 10                <NA>            Clinton        52.0         12-4
## # ... with 3,770,309 more rows, and 1 more variables: trip_distance <dbl>
```

## Select: Other Options

starts_with(x, ignore.case = FALSE)

:    name starts with `x`

ends_with(x, ignore.case = FALSE)

:    name ends with `x`

matches(x, ignore.case = FALSE)

:    selects all variables whose name matches the regular expression `x`

num_range("V", 1:5, width = 1)

:    selects all variables (numerically) from `V1` to `V5`.

* You can also use a `-` to drop variables.

## Reordering Data

* You can reorder your dataset based on conditions using the `arrange()` verb
* Use the `desc` function to sort in descending order rather than ascending order (default)

## Arrange


```r
select(arrange(taxi_df, desc(fare_amount), pickup_nhood), 
       fare_amount, pickup_nhood)
```

```
## # A tibble: 3,770,319 × 2
##    fare_amount    pickup_nhood
##          <dbl>           <chr>
## 1      3130.30    Borough Park
## 2      3130.30 Upper West Side
## 3       990.00            <NA>
## 4       900.00    Little Italy
## 5       900.00            <NA>
## 6       630.01         Chelsea
## 7       600.00    Throggs Neck
## 8       500.00       Chinatown
## 9       500.00       Chinatown
## 10      500.00         Clinton
## # ... with 3,770,309 more rows
```

## Exercise
Use `arrange()` to  sort on the basis of `tip_amount`, `dropoff_nhood`, and `pickup_dow`, with descending order for tip amount

## Summary

filter

:    Extract subsets of rows. See also `slice()`

select

:    Extract subsets of columns. See also `rename()`

arrange

:    Sort your data

# Data Aggregations and Transformations

## Transformations

* The `mutate()` verb can be used to make new columns


```r
taxi_df <- mutate(taxi_df, tip_pct = tip_amount/fare_amount)
select(taxi_df, tip_pct, fare_amount, tip_amount)
```

```
## # A tibble: 3,770,319 × 3
##      tip_pct fare_amount tip_amount
##        <dbl>       <dbl>      <dbl>
## 1  0.0000000         9.5       0.00
## 2  0.2384615         6.5       1.55
## 3  0.2371429         7.0       1.66
## 4  0.0000000         3.0       0.00
## 5  0.2363636         5.5       1.30
## 6  0.2273684         9.5       2.16
## 7  0.2000000        12.5       2.50
## 8  0.2500000         4.0       1.00
## 9  0.2000000         5.0       1.00
## 10 0.2755769        52.0      14.33
## # ... with 3,770,309 more rows
```

## Summarise Data by Groups

* The `group_by` verb creates a grouping by a categorical variable
* Functions can be placed inside `summarise` to create summary functions


```r
summarise(group_by(taxi_df, dropoff_nhood), 
          Num = n(), ave_tip_pct = mean(tip_pct))
```

```
## # A tibble: 122 × 3
##               dropoff_nhood   Num ave_tip_pct
##                       <chr> <int>       <dbl>
## 1                 Annandale    16  0.16486695
## 2             Ardon Heights    16  0.15149972
## 3  Astoria-Long Island City 34728  0.11710247
## 4                Auburndale   424  0.09363095
## 5              Battery Park 32618  0.14849849
## 6                 Bay Ridge  3171  0.14507851
## 7                Baychester   168  0.06078747
## 8              Bedford Park  1028  0.08187483
## 9        Bedford-Stuyvesant 17382  0.12722678
## 10              Bensonhurst  1081  0.12771086
## # ... with 112 more rows
```

## Group By Neighborhoods Example


```r
summarise(group_by(taxi_df, pickup_nhood, dropoff_nhood), 
          Num = n(), ave_tip_pct = mean(tip_pct))
```

```
## Source: local data frame [5,224 x 4]
## Groups: pickup_nhood [?]
## 
##                pickup_nhood            dropoff_nhood   Num ave_tip_pct
##                       <chr>                    <chr> <int>       <dbl>
## 1             Ardon Heights            Ardon Heights     1  0.00000000
## 2  Astoria-Long Island City Astoria-Long Island City  6714  0.09712743
## 3  Astoria-Long Island City               Auburndale    13  0.06520367
## 4  Astoria-Long Island City             Battery Park    14  0.10140865
## 5  Astoria-Long Island City                Bay Ridge     5  0.15388657
## 6  Astoria-Long Island City             Bedford Park     3  0.05550679
## 7  Astoria-Long Island City       Bedford-Stuyvesant    68  0.09819024
## 8  Astoria-Long Island City              Bensonhurst     2  0.00000000
## 9  Astoria-Long Island City              Boerum Hill    12  0.09941085
## 10 Astoria-Long Island City             Borough Park     9  0.08205749
## # ... with 5,214 more rows
```

## Chaining/Piping

* A `dplyr` installation includes the `magrittr` package as a dependency 
* The `magrittr` package includes a pipe operator that allows you to pass the current dataset to another function
* This makes interpreting a nested sequence of operations much easier to understand

## Standard Code

* Code is executed inside-out.
* Let's arrange the above average tips in descending order, and only look at the locations that had at least 10 dropoffs and pickups.


```r
filter(arrange(summarise(group_by(taxi_df, pickup_nhood, dropoff_nhood), Num = n(), ave_tip_pct = mean(tip_pct)), desc(ave_tip_pct)), Num >= 10)
```

```
## Source: local data frame [2,620 x 4]
## Groups: pickup_nhood [86]
## 
##                pickup_nhood            dropoff_nhood   Num ave_tip_pct
##                       <chr>                    <chr> <int>       <dbl>
## 1              Kings Bridge             Kings Bridge    11   1.2256871
## 2           Upper East Side              Brownsville    23   0.9447013
## 3                 Bay Ridge                Bay Ridge    60   0.7915420
## 4             The Rockaways            The Rockaways    33   0.7828405
## 5  Gravesend-Sheepshead Bay Gravesend-Sheepshead Bay    80   0.5122171
## 6                      <NA>                     <NA> 27834   0.4725437
## 7               Bensonhurst              Bensonhurst    59   0.4512018
## 8           Upper East Side           Spuyten Duyvil    65   0.3463543
## 9                      Soho               Mott Haven    12   0.3239580
## 10             Bedford Park             Bedford Park    30   0.3078915
## # ... with 2,610 more rows
```

--- 

![damn](http://www.ohmagif.com/wp-content/uploads/2015/01/lemme-go-out-for-a-walk-oh-no-shit.gif)

## Reformatted


```r
filter(
  arrange(
    summarise(
      group_by(taxi_df, 
               pickup_nhood, dropoff_nhood), 
      Num = n(), 
      ave_tip_pct = mean(tip_pct)), 
    desc(ave_tip_pct)), 
  Num >= 10)
```

```
## Source: local data frame [2,620 x 4]
## Groups: pickup_nhood [86]
## 
##                pickup_nhood            dropoff_nhood   Num ave_tip_pct
##                       <chr>                    <chr> <int>       <dbl>
## 1              Kings Bridge             Kings Bridge    11   1.2256871
## 2           Upper East Side              Brownsville    23   0.9447013
## 3                 Bay Ridge                Bay Ridge    60   0.7915420
## 4             The Rockaways            The Rockaways    33   0.7828405
## 5  Gravesend-Sheepshead Bay Gravesend-Sheepshead Bay    80   0.5122171
## 6                      <NA>                     <NA> 27834   0.4725437
## 7               Bensonhurst              Bensonhurst    59   0.4512018
## 8           Upper East Side           Spuyten Duyvil    65   0.3463543
## 9                      Soho               Mott Haven    12   0.3239580
## 10             Bedford Park             Bedford Park    30   0.3078915
## # ... with 2,610 more rows
```

## Magrittr

![](https://github.com/smbache/magrittr/raw/master/inst/logo.png)

* Inspired by unix `|`, and F# forward pipe `|>`, `magrittr` introduces the funny character (`%>%`, the _then_ operator)
* `%>%` pipes the object on the left hand side to the first argument of the function on the right hand side
* Every function in `dplyr` has a slot for `data.frame/tbl` as it's first argument, so this works beautifully!

## Put that Function in Your Pipe and...


```r
taxi_df %>% 
  group_by(pickup_nhood, dropoff_nhood) %>% 
  summarize(Num = n(),
            ave_tip_pct = mean(tip_pct)) %>% 
  arrange(desc(ave_tip_pct)) %>% 
  filter(Num >= 10)
```

```
## Source: local data frame [2,620 x 4]
## Groups: pickup_nhood [86]
## 
##                pickup_nhood            dropoff_nhood   Num ave_tip_pct
##                       <chr>                    <chr> <int>       <dbl>
## 1              Kings Bridge             Kings Bridge    11   1.2256871
## 2           Upper East Side              Brownsville    23   0.9447013
## 3                 Bay Ridge                Bay Ridge    60   0.7915420
## 4             The Rockaways            The Rockaways    33   0.7828405
## 5  Gravesend-Sheepshead Bay Gravesend-Sheepshead Bay    80   0.5122171
## 6                      <NA>                     <NA> 27834   0.4725437
## 7               Bensonhurst              Bensonhurst    59   0.4512018
## 8           Upper East Side           Spuyten Duyvil    65   0.3463543
## 9                      Soho               Mott Haven    12   0.3239580
## 10             Bedford Park             Bedford Park    30   0.3078915
## # ... with 2,610 more rows
```

---

![hellyeah](http://i.giphy.com/lF1XZv45kIwMw.gif)

## Pipe + group_by()

* The pipe operator is very helpful for group by summaries
* Let's calculate average tip amount, and average trip distance, controlling for dropoff day of the week and dropoff location
* First filter with the vector `manhattan_hoods`

---


```r
mht_url <- "http://alizaidi.blob.core.windows.net/training/manhattan.rds"
manhattan_hoods <- readRDS(gzcon(url(mht_url)))
taxi_df %>% 
  filter(pickup_nhood %in% manhattan_hoods,
         dropoff_nhood %in% manhattan_hoods) %>% 
  group_by(dropoff_nhood, pickup_nhood) %>% 
  summarize(ave_tip = mean(tip_pct), 
            ave_dist = mean(trip_distance)) %>% 
  filter(ave_dist > 3, ave_tip > 0.05)
```

```
## Source: local data frame [398 x 4]
## Groups: dropoff_nhood [27]
## 
##    dropoff_nhood     pickup_nhood    ave_tip  ave_dist
##            <chr>            <chr>      <dbl>     <dbl>
## 1   Battery Park     Central Park 0.12694563  6.149281
## 2   Battery Park          Clinton 0.11996579  4.016902
## 3   Battery Park      East Harlem 0.07116177 10.124000
## 4   Battery Park     East Village 0.14717019  3.537367
## 5   Battery Park Garment District 0.13463903  3.965532
## 6   Battery Park         Gramercy 0.14396885  4.153174
## 7   Battery Park Hamilton Heights 0.06770436  8.843571
## 8   Battery Park           Harlem 0.13829591  9.039286
## 9   Battery Park           Inwood 0.18235294 11.950000
## 10  Battery Park          Midtown 0.13428280  5.496734
## # ... with 388 more rows
```

## Pipe and Plot

Piping is not limited to dplyr functions, can be used everywhere!


```r
library(ggplot2)
taxi_df %>% 
  filter(pickup_nhood %in% manhattan_hoods,
         dropoff_nhood %in% manhattan_hoods) %>% 
  group_by(dropoff_nhood, pickup_nhood) %>% 
  summarize(ave_tip = mean(tip_pct), 
            ave_dist = mean(trip_distance)) %>% 
  filter(ave_dist > 3, ave_tip > 0.05) %>% 
  ggplot(aes(x = pickup_nhood, y = dropoff_nhood)) + 
    geom_tile(aes(fill = ave_tip), colour = "white") + 
    theme_bw() + 
    theme(axis.text.x = element_text(angle = 45, hjust = 1),
          legend.position = 'bottom') +
    scale_fill_gradient(low = "white", high = "steelblue")
```

---

<img src="/home/alizaidi/mr4ds/Student-Resources/Handouts/1-intro-to-R/1-intro-to-R_files/figure-html/unnamed-chunk-14-1.png" style="display: block; margin: auto;" />


## Piping to other arguments

* Although `dplyr` takes great care to make it particularly amenable to piping, other functions may not reserve the first argument to the object you are passing into it.
* You can use the special `.` placeholder to specify where the object should enter


```r
taxi_df %>% 
  filter(pickup_nhood %in% manhattan_hoods,
         dropoff_nhood %in% manhattan_hoods) %>% 
  group_by(dropoff_nhood, pickup_nhood) %>% 
  summarize(ave_tip = mean(tip_pct), 
            ave_dist = mean(trip_distance)) %>% 
  lm(ave_tip ~ ave_dist, data = .) -> taxi_model
summary(taxi_model)
```

```
## 
## Call:
## lm(formula = ave_tip ~ ave_dist, data = .)
## 
## Residuals:
##       Min        1Q    Median        3Q       Max 
## -0.112258 -0.010882  0.002727  0.014168  0.140976 
## 
## Coefficients:
##               Estimate Std. Error t value Pr(>|t|)    
## (Intercept)  0.1324307  0.0016071  82.402  < 2e-16 ***
## ave_dist    -0.0017345  0.0003004  -5.773 1.15e-08 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 0.02468 on 724 degrees of freedom
## Multiple R-squared:  0.04401,	Adjusted R-squared:  0.04269 
## F-statistic: 33.33 on 1 and 724 DF,  p-value: 1.153e-08
```

## Exercise
  
Your turn: 

* Use the pipe operator to group by day of week and dropoff neighborhood
* Filter to Manhattan neighborhoods 
* Make tile plot with average fare amount in dollars as the fill

# Functional Programming

## Creating Functional Pipelines 
### Too Many Pipes?

![whoaaaaaaaaahhhhh](http://www.ohmagif.com/wp-content/uploads/2015/02/the-scariest-electrical-repair-ever.gif)

---

### Reusable code

* The examples above create a rather messy pipeline operation
* Can be very hard to debug
* The operation is pretty readable, but lacks reusability
* Since R is a functional language, we benefit by splitting these operations into functions and calling them separately
* This allows resuability; don't write the same code twice!

## Functional Pipelines 
### Summarization

* Let's create a function that takes an argument for the data, and applies the summarization by neighborhood to calculate average tip and trip distance

---


```r
taxi_hood_sum <- function(taxi_data = taxi_df) {
  
  mht_url <- "http://alizaidi.blob.core.windows.net/training/manhattan.rds"
  
  manhattan_hoods <- readRDS(gzcon(url(mht_url)))
  taxi_data %>% 
    filter(pickup_nhood %in% manhattan_hoods,
           dropoff_nhood %in% manhattan_hoods) %>% 
    group_by(dropoff_nhood, pickup_nhood) %>% 
    summarize(ave_tip = mean(tip_pct), 
              ave_dist = mean(trip_distance)) %>% 
    filter(ave_dist > 3, ave_tip > 0.05) -> sum_df
  
  return(sum_df)
  
}
```

## Functional Pipelines

### Plotting Function

* We can create a second function for the plot


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

## Calling Our Pipeline

* Now we can create our plot by simply calling our two functions


```r
taxi_hood_sum(taxi_df) %>% tile_plot_hood
```

<img src="/home/alizaidi/mr4ds/Student-Resources/Handouts/1-intro-to-R/1-intro-to-R_files/figure-html/unnamed-chunk-18-1.png" style="display: block; margin: auto;" />

Let's make that baby interactive.

## Creating Complex Pipelines with do

* The `summarize` function is fun, can summarize many numeric/scalar quantities
* But what if you want multiple values/rows back, not just a scalar summary?
* Meet the `do` verb -- arbitrary `tbl` operations

---


```r
taxi_df %>% group_by(dropoff_dow) %>%
  filter(!is.na(dropoff_nhood), !is.na(pickup_nhood)) %>%
  arrange(desc(tip_pct)) %>% 
  do(slice(., 1:2)) %>% 
  select(dropoff_dow, tip_amount, tip_pct, 
         fare_amount, dropoff_nhood, pickup_nhood)
```

```
## Source: local data frame [14 x 6]
## Groups: dropoff_dow [7]
## 
##    dropoff_dow tip_amount    tip_pct fare_amount      dropoff_nhood
##          <chr>      <dbl>      <dbl>       <dbl>              <chr>
## 1          Fri       7.00  116.66667        0.06  Greenwich Village
## 2          Fri     454.00   64.85714        7.00 Bedford-Stuyvesant
## 3          Mon       5.00  100.00000        0.05       West Village
## 4          Mon      55.70   22.28000        2.50      The Rockaways
## 5          Sat      15.00 1500.00000        0.01    Upper West Side
## 6          Sat      10.00 1000.00000        0.01            Midtown
## 7          Sun     100.00   22.22222        4.50    Upper West Side
## 8          Sun     125.25   17.89286        7.00   Garment District
## 9          Thu      66.65   26.66000        2.50    Upper East Side
## 10         Thu      93.18   20.70667        4.50   Hamilton Heights
## 11         Tue      11.99 1199.00000        0.01            Chelsea
## 12         Tue      62.00   24.80000        2.50       Battery Park
## 13         Wed     121.25   26.94444        4.50            Clinton
## 14         Wed      57.00   22.80000        2.50            Midtown
## # ... with 1 more variables: pickup_nhood <chr>
```

## Estimating Multiple Models with do

* A common use of `do` is to calculate many different models by a grouping variable


```r
taxi_df %>% sample_n(10^4) %>% 
  group_by(dropoff_dow) %>% 
  do(lm_tip = lm(tip_pct ~ pickup_nhood + passenger_count + pickup_hour,
     data = .))
```

```
## Source: local data frame [7 x 2]
## Groups: <by row>
## 
## # A tibble: 7 × 2
##   dropoff_dow   lm_tip
## *       <chr>   <list>
## 1         Fri <S3: lm>
## 2         Mon <S3: lm>
## 3         Sat <S3: lm>
## 4         Sun <S3: lm>
## 5         Thu <S3: lm>
## 6         Tue <S3: lm>
## 7         Wed <S3: lm>
```

---

Where are our results? 
![digging](http://i.giphy.com/oEnTTI3ZdK6ic.gif)

## Cleaning Output

* By design, every function in `dplyr` returns a `data.frame`
* In the example above, we get back a spooky `data.frame` with a column of `S3` `lm` objects
* You can still modify each element as you would normally, or pass it to a `mutate` function to extract intercept or statistics
* But there's also a very handy `broom` package for cleaning up such objects into `data.frames`

## Brooming Up the Mess

### Model Metrics

```r
library(broom)
taxi_df %>% sample_n(10^5) %>%  
  group_by(dropoff_dow) %>% 
  do(glance(lm(tip_pct ~ pickup_nhood + passenger_count + pickup_hour,
     data = .)))
```

```
## Source: local data frame [7 x 12]
## Groups: dropoff_dow [7]
## 
##   dropoff_dow   r.squared adj.r.squared     sigma statistic      p.value
##         <chr>       <dbl>         <dbl>     <dbl>     <dbl>        <dbl>
## 1         Fri 0.002181134 -0.0021983135 0.9800599 0.4980386 9.997081e-01
## 2         Mon 0.004426414 -0.0008509215 0.9234499 0.8387593 8.150541e-01
## 3         Sat 0.020558551  0.0162633016 0.1264933 4.7863459 2.813240e-35
## 4         Sun 0.015155660  0.0103526227 0.1350077 3.1554325 2.894260e-16
## 5         Thu 0.014618570  0.0101802325 0.1423255 3.2937039 3.766496e-17
## 6         Tue 0.020096984  0.0151066290 0.1358565 4.0271651 9.497120e-25
## 7         Wed 0.017007050  0.0123188113 0.1471142 3.6275991 8.234866e-20
## # ... with 6 more variables: df <int>, logLik <dbl>, AIC <dbl>, BIC <dbl>,
## #   deviance <dbl>, df.residual <int>
```

### Model Coefficients

The most commonly used function in the `broom` package is the `tidy` function. This will expand our data.frame and give us the model coefficients


```r
taxi_df %>% sample_n(10^5) %>%  
  group_by(dropoff_dow) %>% 
  do(tidy(lm(tip_pct ~ pickup_nhood + passenger_count + pickup_hour,
     data = .)))
```

```
## Source: local data frame [462 x 6]
## Groups: dropoff_dow [7]
## 
##    dropoff_dow                           term     estimate  std.error
##          <chr>                          <chr>        <dbl>      <dbl>
## 1          Fri                    (Intercept)  0.099907629 0.01925017
## 2          Fri       pickup_nhoodBattery Park  0.054637052 0.02316752
## 3          Fri          pickup_nhoodBay Ridge -0.110090384 0.16314868
## 4          Fri       pickup_nhoodBedford Park -0.098063653 0.11614402
## 5          Fri pickup_nhoodBedford-Stuyvesant  0.014239424 0.04879299
## 6          Fri        pickup_nhoodBensonhurst  0.166945209 0.11615125
## 7          Fri        pickup_nhoodBoerum Hill -0.004801717 0.03874847
## 8          Fri       pickup_nhoodBorough Park  0.167423548 0.16316799
## 9          Fri           pickup_nhoodBushwick  0.084462510 0.06417322
## 10         Fri           pickup_nhoodCanarsie -0.098303714 0.16315576
## # ... with 452 more rows, and 2 more variables: statistic <dbl>,
## #   p.value <dbl>
```


## Summary

mutate

:    Create transformations

summarise

:    Aggregate

group_by

:    Group your dataset by levels

do

:    Evaluate complex operations on a tbl

Chaining with the `%>%` operator can result in more readable code.

## What We Didn't Cover

* There are many additional topics that fit well into the `dplyr` and functional programming landscape
* There are too many to cover in one session. Fortunately, most are well documented. The most notable omissions:
  1. Connecting to remote databases, see `vignette('databases', package = 'dplyr')`
  2. Merging and Joins, see `vignette('two-table', package = 'dplyr')`
  3. Programming with `dplyr`,`vignette('nse', package = 'dplyr')`
  4. `summarize_each` and `mutate_each`

## Thanks for Attending!

- Any questions?
