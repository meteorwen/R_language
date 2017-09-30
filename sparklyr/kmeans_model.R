#!/usr/bin/Rscript --slave 
argv <- commandArgs(TRUE)
trainpath <- as.character(argv[1])      #训练数据路径与文件名称
modelpath <- as.character(argv[2])      #模型保存的路径
modelname <- as.character(argv[3])      #模型名称
k <- as.numeric(argv[4])                #聚类数量
max <- as.numeric(argv[5])              #最大迭代次数
tolerance <-  as.numeric(argv[6])


# trainpath <- 'hdfs:///user/dsg/iris/iris_training.csv'
# modelpath <- 'hdfs:///user/dsg/model/'
# modelname <- 'kmeans_model4.rda'
# k <-3 
# max <- 100
# tolerance <-  1e-06

require(sparklyr)
require(dplyr)
require(magrittr)
config <- spark_config()
config$spark.driver.cores <- 4
config$spark.executor.cores <- 4
config$spark.executor.memory <-"4g"

sc <- spark_connect(master = "yarn-client",
                    version="1.6.0", 
                    config = config,
                    spark_home = '/opt/cloudera/parcels/CDH/lib/spark/')

dt <- spark_read_csv(sc, "train_data", trainpath,header = TRUE)

kmeans_model <- dt %>%  ml_kmeans(centers = k,iter.max = max,tolerance = tolerance)
print(kmeans_model)

library(rJava)
Sys.setenv("HADOOP_CMD"="/opt/cloudera/parcels/CDH-5.8.0-1.cdh5.8.0.p0.42/bin/hadoop")
library(rhdfs)
hdfs.init()
modelfilename <- paste0(modelpath,modelname)            #"/user/dsg/models/kmeans_model2"
modelfile <- hdfs.file(modelfilename, "w")
hdfs.write(kmeans_model, modelfile)
hdfs.close(modelfile)

# sudo -udsg Rscript kmeans_model.R hdfs:///user/dsg/iris/iris1.csv hdfs:///user/dsg/model/ kmeans_model4.rda 3 100 1e-06