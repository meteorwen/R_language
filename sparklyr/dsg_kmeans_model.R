dsg_kmeans <- function(trainpath,k,modelpath,modelname,outpath){
require(sparklyr)
require(dplyr)
require(magrittr)
# config <- spark_config()
# config$spark.driver.cores <- 4
# config$spark.executor.cores <- 4
# config$spark.executor.memory <-"4g"

sc <- spark_connect(master = "yarn-client",
                    version="1.6.0", 
                    # config = config,
                    spark_home = '/opt/cloudera/parcels/CDH/lib/spark/')
require(stringr)
require(magrittr)
lab <- "Submitted application application_"
ss <- spark_log(sc, n = 10000) %>% 
  as.vector() 
appid <- grep(lab,ss) %>% 
  ss[.] %>% 
  strsplit( " ") %>% 
  unlist %>% 
  tail(1) 

dt <- spark_read_csv(sc, "train_data", trainpath)

kmeans_model <- dt %>% ml_kmeans(centers = k)

res <- kmeans_model[[1]] %>% 
  as.data.frame()  
res <- copy_to(sc,res,"res", overwrite = TRUE)
spark_write_csv(res,outpath)  #聚类中心点


Sys.setenv(HADOOP_CMD="/opt/cloudera/parcels/CDH/bin/hadoop")
Sys.setenv(HADOOP_STREAMING="/opt/cloudera/parcels/CDH/lib/hadoop-0.20-mapreduce/contrib/streaming/hadoop-streaming-2.6.0-mr1-cdh5.8.5.jar")
Sys.setenv(HADOOP_COMMON_LIB_NATIVE_DIR="/opt/cloudera/parcels/CDH/lib/hadoop/lib/native/")
Sys.setenv(HADOOP_CONF_DIR='/etc/hadoop/conf.cloudera.hdfs')
Sys.setenv(YARN_CONF_DIR='/etc/hadoop/conf.cloudera.yarn')
require(rhdfs)
require(rJava)
hdfs.init()

modelfile = hdfs.file(paste0(modelpath,modelname,".rda"), "w")
hdfs.write(kmeans_model, modelfile)
hdfs.close(modelfile)
return(appid)
spark_disconnect(sc)
}