



dsg_kmeans <- function(trainpath,modelpath,modelname,k){
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

print(kmeans_model)

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
spark_disconnect_all()
}

#  trainpath <- "hdfs:///user/dsg/iris/iris.csv"      #训练数据路径与文件名称(没有lab列，测试只包含iris[,1:2])
#  modelpath <- "hdfs:///user/dsg/iris/"      #模型保存的路径
#  modelname <- "ml_keans_model"      #模型名称
#  k <- 3                #聚类数量(任何值)
#  max <- as.numeric(argv[5])              #最大迭代次数
#  
# modelfilename <- "hdfs:///user/dsg/iris/ml_keans_model.rda"
# modelfile = hdfs.file(modelfilename, "r")
# m <- hdfs.read(modelfile)
# model <- unserialize(m)
# hdfs.close(modelfile)