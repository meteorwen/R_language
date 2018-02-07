# trainpath <- "hdfs:///user/dsg/iris/lm/train_dt.csv"             #训练数据路径与文件名称
# modelpath <- "hdfs:///user/dsg/iris/lm/lm_model"      #模型保存的路径
# filepath  <- "hdfs:///user/dsg/iris/res_lm"         #存储斜率和截距


dsg_lm <- function(trainpath,modelpath,modelname){
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

  lm_model <- dt %>%
  ml_linear_regression(response = colnames(dt)[1] , 
                      features = colnames(dt)[2:length(colnames(dt))])  #dt第一列作为Y传入，其余当做xn传入
  
  ml_save(lm_model, modelpath,overwrite = T)
  
  res1 <- coef(lm_model)  %>%    #求模型系数
    t() %>% 
    data.frame(id=c(1:nrow(.)),.)
  res2 <- lm_model[[8]][[15]] %>%
    data.frame(squared=(.)) %>%       
    select(squared) %>% 
    data.frame(id=c(1:nrow(.)),.)
  res3 <- lm_model[[8]]$root_mean_squared_error %>% 
    data.frame(mean_squared_error=(.)) %>% 
    select(mean_squared_error) %>% 
    data.frame(id=c(1:nrow(.)),.)
  df <- merge(res1,res2,all=T) %>% 
    merge(res3,all=T)
  
  res <-copy_to(sc,df,"res")
  spark_write_csv(res,filepath)
  return(appid)
  spark_disconnect(sc)
}
  