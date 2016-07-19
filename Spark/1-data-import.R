# Create Spark Context ----------------------------------------------------

library(sparklyr)
sc <- spark_connect(master = "yarn-client")



# Import-Data -------------------------------------------------------------

taxi <- spark_read_csv(sc,
                       path = "wasb://training@alizaidi.blob.core.windows.net/sample_taxi.csv",
                       "taxisample",
                       header = TRUE)
