r <- getOption('repos')
# set mirror to something a bit more recent
r["CRAN"] <- "https://mran.revolutionanalytics.com/snapshot/2016-10-24/"
options(repos = r)

install.packages('magrittr')
install.packages('ggplot2')

system("sudo apt-get -y build-dep libcurl4-gnutls-dev")
system("sudo apt-get -y install libcurl4-gnutls-dev")
system("sudo ln -s /bin/tar /bin/gtar")
system("sudo apt-get -y install git")

install.packages('devtools')

devtools::isntall_github("rstudio/htmltools")
devtools::install_github("rstudio/rmarkdown")
devtools::install_github("rstudio/sparklyr")
devtools::install_github("hadley/tibble")
devtools::install_github("hadley/purrr")
devtools::install_github('ropensci/plotly')
devtools::install_github('yihui/knitr')
devtools::install_github("rstudio/revealjs")
