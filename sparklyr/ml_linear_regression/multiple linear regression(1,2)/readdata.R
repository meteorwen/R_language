# 1收集/观察数据；
# 2探索和准备数据；

# wd <- "/home/dsg/Rspace/mlr/" #本地工作环境
# hwd <- "/user/dsg/mlr"        #hdfs工作环境（训练集测试集该目录下）
# h_filename <- '/train.csv'    #hdfs上训练数据名字
# obs_dt(wd,hwd,h_filename)     #调用函数 返回hdfs上文件存储地址。

obs_dt <- function(wd,hwd,h_filename){
  setwd(wd)
  source(paste0(wd,"procedure_fun.R")) #本地工作环境下
  require(rJava)
  require(magrittr)
  Sys.setenv(HADOOP_CMD="/opt/cloudera/parcels/CDH/bin/hadoop")
  Sys.setenv(HADOOP_STREAMING="/opt/cloudera/parcels/CDH/lib/hadoop-0.20-mapreduce/contrib/streaming/hadoop-streaming-2.6.0-mr1-cdh5.8.5.jar")
  
  require(rhdfs)
  hdfs.init()
  train <- data.frame()
  train <- hdfs.cat(paste0(hwd,h_filename)) %>% 
    textConnection(.) %>% 
    read.csv(head=T,stringsAsFactors = TRUE)
# 了解训练集的情况并生成表保存在hdfs指定路径中  
  sink("summ_t.txt")
  summary(train)
  sink(NULL) 
  temp_1 = tempfile()
  hdfs.put(paste0(wd,"summ_t.txt"),paste0(hwd,temp_1)) 
  unlink(paste0(wd,"summ_t.txt"))
# 了解自变量（y）的情况并生成图、表保存在hdfs指定路径中   
  sink("y.txt")
  summary(train[,ncol(train)]) #了解医疗开销分布情况
  sink(NULL) 
  temp_2 = tempfile()
  hdfs.put(paste0(wd,"y.txt"),paste0(hwd,temp_2)) 
  unlink(paste0(wd,"y.txt"))
  jpeg(file= "y.jpg")
  hist(train$charges) #图形展示医疗开销频次分布
  dev.off()
  temp_3 = tempfile()
  hdfs.put(paste0(wd,"y.jpg"),paste0(hwd,temp_3,".jpg"))
  unlink(paste0(wd,"y.jpg"))
# 了解数值型因变量之间的影响关系并生成图、表保存在hdfs指定路径中 
  sink("cor_t.txt")
  cor(train[judge_df(train)]) #评判特征之间的影响结果
  sink(NULL)
  temp_4 = tempfile()
  hdfs.put(paste0(wd,"cor_t.txt"),paste0(hwd,temp_4))
  unlink(paste0(wd,"cor_t.txt"))
  temp_5 = tempfile()
  jpeg(file= "cor_p.jpg")
  require(psych)
  pairs.panels(train[judge_df(train)])
  dev.off()
  hdfs.put(paste0(wd,"cor_p.jpg"),paste0(hwd,temp_5,".jpg"))
  unlink(paste0(wd,"cor_p.jpg"))
  
  p <-  data.frame(
    paste0(hwd,temp_1),
    paste0(hwd,temp_2),
    paste0(hwd,temp_3,".jpg"),
    paste0(hwd,temp_4),
    paste0(hwd,temp_5,".jpg")
  )
  return(p)
}













