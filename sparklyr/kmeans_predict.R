#!/usr/bin/Rscript --slave 
argv <- commandArgs(TRUE)
modelpath <- as.character(argv[1])      #模型保存的路径
modelname <- as.character(argv[2])      #模型名称
testdata <- as.character(argv[3])       #测试数据集存储路径及文件名称
savefile <- as.character(argv[4])       #预测后存放数据
# modelpath <- 'hdfs:///user/dsg/model/'
# modelname <- 'kmeans_model4.rda'
# testdata <- 'hdfs:///user/dsg/iris/iris_testing.csv'
# savefile <- 'hdfs:///user/dsg/iris/iris_result3.csv'
library(rJava)
Sys.setenv("HADOOP_CMD"="/opt/cloudera/parcels/CDH-5.8.0-1.cdh5.8.0.p0.42/bin/hadoop")
library(rhdfs)
hdfs.init()

modelfile = hdfs.file(paste0(modelpath,modelname), "r")
m <- hdfs.read(modelfile)
model <- unserialize(m)
hdfs.close(modelfile)


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

dt <- spark_read_csv(sc, "test_data", testdata,header = TRUE)
testing <- dt %>% collect()
predicted <- sdf_predict(model, dt) %>%
  collect

print(table(testing$lab %>% as.vector,predicted$prediction))
#############   
result <- table(testing$lab,predicted$prediction) %>% 
  as.matrix() %>% 
  as.data.frame() %>% 
  copy_to(sc,.,"result")
spark_write_csv(result,savefile)
#存储hdfs上文件
resultfile <- hdfs.file(savefile, "w")
hdfs.write(result, resultfile)
hdfs.close(resultfile)

#读取hdfs存放的文件
resultfile = hdfs.file(savefile, "r")
m <- hdfs.read(resultfile)
result <- unserialize(m) #序列化形式
hdfs.close(resultfile)


































