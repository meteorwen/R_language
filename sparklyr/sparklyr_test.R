#  p1 <- "hdfs:///user/dsg/iris/iris.csv"
#  p2 <- "hdfs:///user/dsg/iris/res4"  #file path


spark_hdfs <- function(p1,p2){
require(sparklyr)
require(dplyr)
sc <- spark_connect(master = "yarn-client", version="1.6.0", 
                      spark_home = '/opt/cloudera/parcels/CDH/lib/spark/')  
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
# print(appid) 
ir <- spark_read_csv(sc,"temp1",p1,
                       header = TRUE,
                       delimiter = ",",
                       overwrite = TRUE) 
  
df_r <- tbl_df(ir)  # spark to R memory
summ_r <- summary(df_r) %>% data.frame() # function in R

df_sp <- copy_to(sc,summ_r,"temp2") # r_df to spark memory 
spark_write_csv(df_sp,p2) # df in spark memory to hdfs
spark_disconnect(sc)
return(appid)
rm(list = ls())
}

#  spark_hdfs(p1,p2)
