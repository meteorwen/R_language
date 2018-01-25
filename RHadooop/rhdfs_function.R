text <- function(p1,p2){
  require(rJava)
  require(magrittr)
  Sys.setenv(HADOOP_CMD="/opt/cloudera/parcels/CDH/bin/hadoop")
  Sys.setenv(HADOOP_STREAMING="/opt/cloudera/parcels/CDH/lib/hadoop-0.20-mapreduce/contrib/streaming/hadoop-streaming-2.6.0-mr1-cdh5.8.5.jar")
  Sys.setenv(HADOOP_COMMON_LIB_NATIVE_DIR="/opt/cloudera/parcels/CDH/lib/hadoop/lib/native/")
  Sys.setenv(HADOOP_CONF_DIR='/etc/hadoop/conf.cloudera.hdfs')
  Sys.setenv(YARN_CONF_DIR='/etc/hadoop/conf.cloudera.yarn')
  require(rhdfs)
  hdfs.init()
  path1 <- hdfs.file(p1, "r")
  summ <- hdfs.read(path) %>%
    rawToChar() %>%  
    textConnection() %>% 
    read.table(sep = ",")
    summary()
  print(summ)
  return(summ)
  hdfs.close(path1)
  
  path2 <- hdfs.file(p2, "w")
  hdfs.write(summ, path2)
  hdfs.close(path2)
  
}


# sudo -uhdfs hadoop dfsadmin -safemode leave         强制hdfs离开安全模式
# hdfs fsck -move  /   hdfs fdck -delete   删除有问题的hfds有问题的块