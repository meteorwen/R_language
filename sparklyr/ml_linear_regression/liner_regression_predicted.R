# testpath <- "hdfs:///user/dsg/iris/iris.csv"      #测试数据路径与文件名称
# modelpath <- "hdfs:///user/dsg/iris/lm/lm_model2"      #模型保存的路径
# predicted_path <- "hdfs:///user/dsg/iris/lm/predicted.csv" #前端展示数据

dsg_lm_predict<- function(testpath,modelpath,predicted_path){
  
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
 
  lm_model <- ml_load(sc,modelpath)
  
  test <- spark_read_csv(sc, "test_data", testpath) 
 
  Predicted <- sdf_predict(test,lm_model) %>%
    select(-features) %>% 
    as.data.frame() %>% 
    copy_to(sc,.,"Predicted")
  spark_write_csv(Predicted,predicted_path,overwrite = TRUE)
  
  return(appid)
  spark_disconnect(sc)
  
}