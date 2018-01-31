dsg_kmeans_predict<- function(modelpath,modelname,testpath,predicted_path,predicted_name){
  
  require(sparklyr)
  require(dplyr)
  require(magrittr)
  require(ggplot2)
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
  
  
  
  
  Sys.setenv(HADOOP_CMD="/opt/cloudera/parcels/CDH/bin/hadoop")
  Sys.setenv(HADOOP_STREAMING="/opt/cloudera/parcels/CDH/lib/hadoop-0.20-mapreduce/contrib/streaming/hadoop-streaming-2.6.0-mr1-cdh5.8.5.jar")
  Sys.setenv(HADOOP_COMMON_LIB_NATIVE_DIR="/opt/cloudera/parcels/CDH/lib/hadoop/lib/native/")
  Sys.setenv(HADOOP_CONF_DIR='/etc/hadoop/conf.cloudera.hdfs')
  Sys.setenv(YARN_CONF_DIR='/etc/hadoop/conf.cloudera.yarn')
  
  require(rhdfs)
  require(rJava)
  hdfs.init()
  
  modelfile = hdfs.file(paste0(modelpath,modelname), "r")
  m <- hdfs.read(modelfile)
  kmeans_model <- unserialize(m)
  hdfs.close(modelfile)
  
  test <- spark_read_csv(sc, "test_data", testpath)
  predicted <- sdf_predict(kmeans_model, test) %>%
    collect
  table(predicted$Species, predicted$prediction)
  
  predicted <- copy_to(sc,predicted,"predicted", overwrite = TRUE)
  spark_write_csv(predicted,paste0(predicted_path,predicted_name))
  
  return(appid)
  spark_disconnect(sc)
  
}