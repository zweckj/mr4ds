
# Locate RevoShare dir ----------------------------------------------------

rxHadoopListFiles("/user/RevoShare/")
data_path <- "/user/RevoShare/alizaidi"


# Write Sample Taxi to RevoShare ------------------------------------------

library(sparklyr)
spark_write_csv(sample_taxi, 
                path = file.path(data_path, 'sampleTaxi'))


# Remove SUCCESS dir ------------------------------------------------------

rxHadoopListFiles(file.path(data_path, "sampleTaxi"))
file_to_delete <- file.path(data_path, 
                            "sampleTaxi", "_SUCCESS")
delete_command <- paste("fs -rm", file_to_delete)
rxHadoopCommand(delete_command)


# Create HDFS and Spark Contexts for Revo ---------------------------------

myNameNode <- "default"
myPort <- 0
hdfsFS <- RxHdfsFileSystem(hostName = myNameNode, 
                           port = myPort)

taxi_text <- RxTextData(file.path(data_path,
                                  "sampleTaxi"),
                        fileSystem = hdfsFS)

taxi_xdf <- RxXdfData(file.path(data_path, "taxiXdf"),
                      fileSystem = hdfsFS)



# Import to XDF -----------------------------------------------------------

rxImport(inData = taxi_text, taxi_xdf, overwrite = TRUE)
rxGetInfo(taxi_xdf)

# create RxSpark compute context
computeContext <- RxSpark(consoleOutput=TRUE,
                          nameNode=myNameNode,
                          port=myPort,
                          executorCores=6, 
                          executorMem = "3g", 
                          executorOverheadMem = "3g", 
                          persistentRun = TRUE, 
                          extraSparkConfig = "--conf spark.speculation=true")

rxSetComputeContext(computeContext)

taxi_Fxdf <- RxXdfData(file.path(data_path, "taxiXdfFactors"),
                       fileSystem = hdfsFS)


rxFactors(inData = taxi_xdf, outFile = taxi_Fxdf, 
          factorInfo = c("pickup_hour", "pickup_nhood")
)

system.time(linmod <- rxLinMod(tip_pct ~ trip_distance, 
                               data = taxi_xdf, blocksPerRead = 2))
