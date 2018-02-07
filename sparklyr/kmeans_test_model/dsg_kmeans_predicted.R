# modelpath <- "hdfs:///user/dsg/iris/model/"      #模型保存的路径
# testpath <- "hdfs:///user/dsg/iris/test_data.csv"        #测试数据路径与文件名称
# predicted_path <- "hdfs:///user/dsg/iris/kmeans_pre"               #预测结果保存路径



dsg_kmeans_predict<- function(modelpath,modelname,testpath,predicted_path,predicted_name){
  
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
  
  model <- ml_load(sc,modelpath)
  
  test <- spark_read_csv(sc, "test_data", testpath)
  
  
  Predicted <- sdf_predict(test,model) %>%
    select(-features) %>% 
    as.data.frame() %>% 
    copy_to(sc,.,"Predicted")
  spark_write_csv(Predicted,predicted_path,overwrite = TRUE)
  
  
  return(appid)
  spark_disconnect(sc)
  
}