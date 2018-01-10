#!/usr/bin/Rscript --slave 
argv <- commandArgs(TRUE)

targetpath <- as.character(argv[1])     
savefile <- as.character(argv[2])      

library(rJava)
library(magrittr)
Sys.setenv(HADOOP_CMD="/opt/cloudera/parcels/CDH-5.8.5-1.cdh5.8.5.p0.5/bin/hadoop")
Sys.setenv(HADOOP_STREAMING="/opt/cloudera/parcels/CDH-5.8.5-1.cdh5.8.5.p0.5/lib/hadoop-0.20-mapreduce/contrib/streaming/hadoop-streaming-2.6.0-mr1-cdh5.8.5.jar")

library(rhdfs)
hdfs.init()

path <- hdfs.file(targetpath, "r")
h_text <- hdfs.read(path)
result <- unserialize(h_text)
summ <- summary(result)
print(summ)
hdfs.close(path)


path <- hdfs.file(savefile, "w")
hdfs.write(summ, path)
hdfs.close(path)


# sudo -udsg Rscript  hdfs_test.R hdfs:///user/dsg/iris.txt hdfs:///user/dsg/result.txt