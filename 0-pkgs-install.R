
# package insallation -----------------------------------------------------

# update cran
r <- getOption('repos')
# set mirror to something a bit more recent
r["CRAN"] <- "https://mran.revolutionanalytics.com/snapshot/2016-10-09/"
options(repos = r)

# If you have issues installing the rgeos package on linux:
# on RHEL, centos `sudo yum install geos geos-devel`
# on ubuntu `sudo apt-get install libgeos libgeos-dev`
pkgs_to_install <- c("devtools", 
                     # "data.table",
                     "stringr", 
                     "broom", "magrittr", "dplyr",
                     "lubridate",
                     # "rgeos", "sp", "maptools",
                     # "seriation",
                     "ggplot2",
                     # "gridExtra",
                     # "ggrepel",
                     "tidyr", "revealjs"
                     )
pks_missing <- pkgs_to_install[!(pkgs_to_install %in% installed.packages()[, 1])]

install.packages(c(pks_missing, 'knitr'))


# install-dplyrXdf --------------------------------------------------------

dev_pkgs <- c("RevolutionAnalytics/dplyrXdf",
              "ropensci/plotly")
devtools::install_github(dev_pkgs)
