

#  p1 <- "hdfs:///user/dsg/iris/iris.csv"
#  p2 <- "hdfs:///user/dsg/iris/res1/"  #file path
#  filename <- "dsg_summary.csv"
source('www/statistics-part1.R', local = TRUE)  #调用dsg_summary()
setwd("/var/lib/hadoop-hdfs/mytomcat/tomcat/webapps/")
spark_hdfs <- function(p1,filename,p2){
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

df_r <- ir %>% collect
summ_r <- dsg_summary(df_r) %>% data.frame()  
row_names <- c("colnames","type","min","max","median","mean","var","sd","q1","q3","zero","norm","NA","NA_p","cv","skewness","kurtosis")
summ_r <- cbind(row_names,summ_r)
write.csv(summ_r,filename)

hadoop_cmd <- "/opt/cloudera/parcels/CDH/bin/hadoop"
system2(hadoop_cmd, paste("fs -put",filename,p2,sep = " "))

spark_disconnect(sc)
return(appid)
}




# system2(hadoop_cmd, "fs -put dsg_summary.csv /user/dsg/iris/")
# 
# summ_r <- summary(df_r) %>% data.frame() # function in R
# 
# df_sp <- copy_to(sc,summ_r,"temp2") # r_df to spark memory 
# spark_write_csv(df_sp,p2) # df in spark memory to hdfs





# system.time(spark_hdfs(p1,p2))
#  spark_hdfs(p1,p2)
# sudo -uhdfs hadoop dfsadmin -safemode leave 