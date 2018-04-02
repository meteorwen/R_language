# pic_name <- " /user/dsg/iris/pic"   in hdfs path,cannot need suffix name
dsg_kmeans_predict<- function(modelpath,modelname,testpath,predicted_path,predicted_name,pic_name){
  
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
  
  
  Predicted <- sdf_predict(model,test) %>%
    mutate(pre = prediction+1) %>% 
    select(pre) %>% 
    copy_to(sc,.,"Predicted")
  
  
  spark_write_csv(Predicted,predicted_path,overwrite = TRUE)
  
  pred <- sdf_predict(model,test) %>% 
    mutate(pre = prediction+1) %>% 
    select(pre) %>% 
    collect %>% 
    unlist
  temp <- pic_path %>%  strsplit("/") %>% unlist
  pic_name <- temp %>% tail(1)
  jpeg(file= paste0(pic_name,".jpg"))
  plot( test %>% collect %>% as.matrix(), col = pred)  
  points(model$centers, col = 1:k, pch = 8, cex = 2) 
  dev.off()
  path <- temp[1:(length(temp)-1)] %>% paste0(collapse="/")
  system(paste("hadoop fs -put",paste0(pic_name,".jpg"),path))
  
  require(amap)
  require(animation)
  require(R2SWF)  
  output = dev2swf({  
    par(mar  = c(3, 3, 1, 1.5), mgp  = c(1.5, 0.5, 0))  
    kmeans.ani(x = test %>% collect %>% data.frame(),
               centers = k, 
               hints = c("Move centers!", "Find cluster?"), pch = 1:k, col = 1:k)  
  }, output = paste0(pic_name,".swf"))
  # swf2html(output)
  system(paste("hadoop fs -put",paste0(pic_name,".swf"),path))
  system(paste("rm -rf", paste0(pic_name,"*")))
  return(appid)
  spark_disconnect(sc)
  
}