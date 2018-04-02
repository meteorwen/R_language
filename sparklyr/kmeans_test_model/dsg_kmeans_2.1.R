dsg_kmeans <- function(trainpath,featrues,k,modelpath,filepath){
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
    ml_kmeans(.,centers = k,features = features %>% strsplit(",") %>% unlist()) 
  ml_save(kmeans_model, modelpath,overwrite = T)
  
  center <- kmeans_model[[1]] %>% 
    data.frame(id=c(1:nrow(.)),.) 
  
  Squared_Errors <- data.frame(id = length(kmeans_model[[6]]),
                               Squared_Errors=kmeans_model[[6]]) 
  df <- merge(center,Squared_Errors,all=T)

  
  copy_to(sc,df,"res") %>% 
  	spark_write_csv(filepath)
  
  return(appid)
  spark_disconnect(sc)
}
