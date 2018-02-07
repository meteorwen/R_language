# trainpath <- "hdfs:///user/dsg/iris/train_data.csv"       #训练数据路径与文件名称
# k =2
# modelpath <- "hdfs:///user/dsg/iris/ml_test/model/"       #模型保存的路径
# filepath  <- "hdfs:///user/dsg/iris/res_kmean"           #模型摘要信息



dsg_kmeans <- function(trainpath,modelpath,k){
  require(sparklyr)
  require(dplyr)
  require(magrittr)
  
  sc <- spark_connect(master = "yarn",
                      version="2.1.0", 
                      app_name = "sparklyr2.1.0",
                      # spark_home = '/opt/cloudera/parcels/SPARK2/lib/spark2/'
                      spark_home = '/opt/cloudera/parcels/SPARK2-2.2.0.cloudera1-1.cdh5.12.0.p0.142354b/spark2'
                      ) 
  
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
  
  kmeans_model <- dt  %>% 
    ml_kmeans(.,centers = k,features = colnames(.)) 
  ml_save(kmeans_model, modelpath,overwrite = T)
  
 res1 <- kmeans_model[[8]][3] %>% 
   as.data.frame() %>% 
   data.frame(id=c(1:nrow(.)),.) #训练阶段的聚类情况
 res2 <- kmeans_model[[6]] %>% 
   data.frame(id=c(1:nrow(.)),.) #训练阶段各特征的聚类中心点
 res3 <- data.frame(id=length(kmeans_model[[7]]),Squared_Errors=kmeans_model[[7]]) #within Set Sum of Squared Errors 族内误差平方和
 df <- merge(res1,res2,all=T) %>% 
   merge(res3,all=T)
  
  res <-copy_to(sc,df,"res")
  spark_write_csv(res,filepath)
  
  return(appid)
  spark_disconnect(sc)
}