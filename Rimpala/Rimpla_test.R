library(rJava)
library(RImpala)
-----------------------------------------------------------------------------------------------
rimpala.init(libs="/opt/impala_jar")  #主节点下载官方的impala-jdbc-cdh5.zip文件解压值该路径
#https://www.cloudera.com/downloads/connectors/impala/jdbc/2-5-5.html
rimpala.connect(IP="192.168.1.117",port="21050")  #cdh的主节点是不能访问implala，任意从节点即可
# ri <- rimpala.query(Q="select * from flights LIMIT 10",isDDL="false")
# ri <- rimpala.query(Q="select * from flights",isDDL="false",fetchSize="10000")
rimpala.refresh(table="flights")
rimpala.showdatabases()
rimpala.showtables()
rimpala.usedatabase(db="dsg")

rimpala.query("select *  from customers limit 10")
rimpala.query("select *  from customers where id >60000")
rimpala.query("create database cdh",isDDL="true")
rimpala.query("create database dsg",isDDL="true")
rimpala.query("drop table dsg.iris",isDDL="true")
rimpala.query("create table dsg.iris
              (id int,
              Sepal_Length double,
              Sepal_Width double,
              Petal_Length double,
              Petal_Width double,
              Species string) 
              ROW FORMAT DELIMITED 
              FIELDS TERMINATED BY '\t'
              STORED AS TEXTFILE;",isDDL="true")

write.table(iris,"iris1.csv",sep = ",",row.names = TRUE,col.names=FALSE,fileEncoding = "utf-8")
write.csv(iris,"iris.csv",row.names = TRUE,fileEncoding = "utf-8")
write.csv(mtcars,"mtcars.csv",row.names = TRUE,fileEncoding = "utf-8")

#因为是集群模式，不能使用本地上传文档
rimpala.query("load data local inpath '/home/dsg/iris.txt' into table dsg.iris;")
rimpala.query("select count(*) from dsg.iris")
rimpala.invalidate()
rimpala.close()






































-----------------------------------------------------------------------------------------------------------------
##test
  devtools::install_github("jwills/dplyrimpaladb")
library(dplyrimpaladb)
# Set the classpath for a local install:
options(dplyr.jdbc.classpath = "/usr/lib/impala")
# Alternatively, set the classpath for the ImpalaDB JDBC connector on a CDH cluster node:
options(dplyr.jdbc.classpath = "/opt/cloudera/parcels/CDH/lib/hive/lib/:/opt/cloudera/parcels/CDH/lib/hadoop/lib")

# To connect to a database first create a src:
gdelt <- src_impaladb(dbname='gdelt', host='localhost')
gdelt

# Simple Impala table retrieval
events <- tbl(gdelt, 'events')
events