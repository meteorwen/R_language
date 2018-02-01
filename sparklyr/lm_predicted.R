# testpath <- "hdfs:///user/dsg/iris/iris.csv"      #测试数据路径与文件名称
# modelpath <- "hdfs:///user/dsg/iris/lm/lm_model.rda"      #模型保存的路径
# predicted_path <- "hdfs:///user/dsg/iris/lm/predicted.csv" #前端展示数据





dsg_lm_predict<- function(testpath,modelpath,predicted_path){
  
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
  
  modelfile = hdfs.file(modelpath, "r")
  m <- hdfs.read(modelfile)
  lm_model <- unserialize(m)
  hdfs.close(modelfile)
  
  test <- spark_read_csv(sc, "test_data", testpath)
  predicted <- sdf_predict(lm_model, test) %>%
    collect()

  # table(predicted$Species, predicted$prediction)
  
  predicted_name <- unlist(strsplit(predicted_path,split="/")) %>% .[length(.)]
  fpath <- sub(pattern = filename, replacement = "", predicted_path)
  
  write.csv(predicted,filename)
  
  hadoop_cmd <- "/opt/cloudera/parcels/CDH/bin/hadoop"
  system2(hadoop_cmd, paste("fs -put",predicted_name,fpath,sep = " "))
  # predicted <- copy_to(sc,predicted,"predicted", overwrite = TRUE)
  # spark_write_csv(predicted,paste0(predicted_path,predicted_name))
  
  return(appid)
  spark_disconnect(sc)
  
}
