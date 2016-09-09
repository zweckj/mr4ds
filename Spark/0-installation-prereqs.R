
# Update CRAN Mirror ------------------------------------------------------

r <- getOption('repos')
# set mirror to something a bit more recent
r["CRAN"] <- "https://mran.revolutionanalytics.com/snapshot/2016-07-05/"
options(repos = r)


# Install magrittr and ggplot2 --------------------------------------------

install.packages('magrittr')
install.packages('ggplot2')



# Install curl and gnutls for devtools ------------------------------------

system("sudo apt-get -y build-dep libcurl4-gnutls-dev")
system("sudo apt-get -y install libcurl4-gnutls-dev")
install.packages('devtools')



# Install sparkapi and sparklyr packages ----------------------------------

devtools::install_github("rstudio/sparkapi")
devtools::install_github("rstudio/sparklyr")
devtools::install_github('ropensci/plotly')
