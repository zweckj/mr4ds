# Create Spark Context ----------------------------------------------------

library(sparklyr)
sc <- spark_connect(master = "yarn-client")

# Download Sample Data ----------------------------------------------

download.file("https://alizaidi.blob.core.windows.net/training/manhattan.RData", "manhattan.RData")
download.file("https://alizaidi.blob.core.windows.net/training/sample_taxi.csv", "sample_taxi.csv")
wasb_taxi <- "/NYCTaxi/sample"
rxHadoopListFiles("/")
rxHadoopMakeDir(wasb_taxi)
rxHadoopCopyFromLocal("sample_taxi.csv", wasb_taxi)
rxHadoopCommand("fs -cat /NYCTaxi/sample/sample_taxi.csv | head")



# Import-Data -------------------------------------------------------------

taxi <- spark_read_csv(sc,
                       path = "wasb://training@alizaidi.blob.core.windows.net/sample_taxi.csv",
                       "taxisample",
                       header = TRUE)
