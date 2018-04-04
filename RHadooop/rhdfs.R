 # rhdfs other functinos : hdfs.cat hdfs.read.text.file hdfs.put
  require(rJava)
  require(magrittr)
  Sys.setenv(HADOOP_CMD="/opt/cloudera/parcels/CDH/bin/hadoop")
  Sys.setenv(HADOOP_STREAMING="/opt/cloudera/parcels/CDH/lib/hadoop-0.20-mapreduce/contrib/streaming/hadoop-streaming-2.6.0-mr1-cdh5.8.5.jar")
  
  require(rhdfs)
  hdfs.init()
  
  df1 <- hdfs.cat('/user/dsg/iris/111111.csv') %>% 
      textConnection(.) %>% 
        read.csv(head=T)
  
  df2 <- hdfs.read.text.file('/user/dsg/iris/111111.csv') %>% 
    textConnection(.) %>% 
    read.csv(head=T)

  df3 <- hdfs.read.text.file('/user/dsg/iris/222222.txt') %>% 
    textConnection(.) %>% 
    read.table(head=T)
  
  write.table(iris,"222222.txt",row.names = F)
  
  hdfs.put("222222.txt","/user/dsg/iris/") 
  hdfs.ls("/user/dsg/iris/")
  hdfs.test = tempfile()
  