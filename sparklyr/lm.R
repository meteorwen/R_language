# trainpath <- "hdfs:///user/dsg/iris/iris.csv"      #训练数据路径与文件名称
# modelpath <- "hdfs:///user/dsg/iris/lm/"      #模型保存的路径
# modelname <- "lm_model.rda"  
# filepath  <- "hdfs:///user/dsg/iris/lm/"
# filename <- "res_lm.csv"  #存储斜率和截距

dsg_lm <- function(trainpath,modelpath,modelname,filename){
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
  
  dt <- spark_read_csv(sc, "train_data", trainpath)

  lm_model <- dt %>%
  select(Petal_Width, Petal_Length) %>%
  ml_linear_regression(Petal_Length ~ Petal_Width)
  
  
  
  summary(lm_model)
  coef(lm_model)  %>%    #求模型系数
    as.data.frame() %>% 
    write.csv(filename)
  
  hadoop_cmd <- "/opt/cloudera/parcels/CDH/bin/hadoop"
  system2(hadoop_cmd, paste("fs -put",filename,filepath,sep = " "))
  
  spark_disconnect(sc)
  
  Sys.setenv(HADOOP_CMD="/opt/cloudera/parcels/CDH/bin/hadoop")
  Sys.setenv(HADOOP_STREAMING="/opt/cloudera/parcels/CDH/lib/hadoop-0.20-mapreduce/contrib/streaming/hadoop-streaming-2.6.0-mr1-cdh5.8.5.jar")
  Sys.setenv(HADOOP_COMMON_LIB_NATIVE_DIR="/opt/cloudera/parcels/CDH/lib/hadoop/lib/native/")
  Sys.setenv(HADOOP_CONF_DIR='/etc/hadoop/conf.cloudera.hdfs')
  Sys.setenv(YARN_CONF_DIR='/etc/hadoop/conf.cloudera.yarn')
  require(rhdfs)
  require(rJava)
  hdfs.init()
  
  modelfile = hdfs.file(paste0(modelpath,modelname,".rda"), "w")
  hdfs.write(lm_model, modelfile)
  hdfs.close(modelfile)
  
  return(appid)
}
  
  
  
  # plot it
# dt %>%
#     select(Petal_Width, Petal_Length) %>%
#     collect %>%
#     ggplot(aes(Petal_Length, Petal_Width)) +
#     geom_point(aes(Petal_Width, Petal_Length), size = 2, alpha = 0.5) +
#     geom_abline(aes(slope = coef(lm_model)[["Petal_Width"]],
#                     intercept = coef(lm_model)[["(Intercept)"]]),
#                 color = "red") +
#     labs(
#       x = "Petal Width",
#       y = "Petal Length",
#       title = "Linear Regression: Petal Length ~ Petal Width",
#       subtitle = "Use Spark.ML linear regression to predict petal length as a function of petal width."
#     )
#   
  
  
  