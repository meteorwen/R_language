# judge type of df  to vector
judge_df <- function(df){
  a <- sapply(df,class)
  b <- vector()
  for(i in 1:length(a)){
    if(a[i]=="integer" | a[i]=="numeric"){
      b[i]=T
    }else{
      b[i]=F
    }
  } 
  return(b)
}

# judge_df(train)

#----------------------------------------------------------------------------
# read file in hdfs 
require(rJava)
require(magrittr)
Sys.setenv(HADOOP_CMD="/opt/cloudera/parcels/CDH/bin/hadoop")
Sys.setenv(HADOOP_STREAMING="/opt/cloudera/parcels/CDH/lib/hadoop-0.20-mapreduce/contrib/streaming/hadoop-streaming-2.6.0-mr1-cdh5.8.5.jar")

require(rhdfs)
hdfs.init()

readh <- function(hpath){
  df <- hdfs.cat(hpath) %>% 
    textConnection(.) %>% 
    read.csv(head=T,stringsAsFactors = TRUE) 
  return(df)
}
# readh("/user/dsg/mlr/train.csv")

#----------------------------------------------------------------------------
# save txt pic  in hdfs

save_t <- function(wd,hwd,x){
  sink("temp.txt",split=F)
  print(x)
  sink()
  temp = tempfile()
  hdfs.put(paste0(wd,"temp.txt"),paste0(hwd,temp))
  unlink(paste0(wd,"temp.txt"))
  return(paste0(hwd,temp))
}
# save_t(iris)

save_p <- function(wd,hwd,x){
  jpeg(file= "temp.jpg")
  x
  dev.off()
  temp = tempfile()
  hdfs.put(paste0(wd,"temp.jpg"),paste0(hwd,temp,".jpg"))
  unlink(paste0(wd,"temp.jpg"))
  return(paste0(hwd,temp,"temp.jpg"))
}
# save_p(hist(train$charges))


#----------------------------------------------------------------------------
# save model  in hdfs
# save_m <- function(x,hwd){
#   temp <- tempfile() %>%  paste0(hwd,.)
#   modelfile <-hdfs.file(temp,"w")
#   hdfs.write(model, modelfile)
#   hdfs.close(modelfile)
#   return(temp)
# }


save_m <- function(wd,hwd,x){
  saveRDS(x,"temp.rds")
  temp <- tempfile() %>%  paste0(hwd,.,".rds")
  hdfs.put(paste0(wd,"temp.rds"),temp)
  unlink("temp.rds")
  return(temp)
}
# save_m(wd,hwd,model)


# save_m(model,hwd)

# read model  in hdfs
# read_m <- function(p){
#   path <- hdfs.file(temp, "r")
#   m <- hdfs.read(path)
#   model <- unserialize(m)
#   hdfs.close(path)
# }
# p = "/user/dsg/mlr/tmp/RtmpJpIoKx/filed18419d86822.rds"
read_m <- function(wd,p){
  hdfs.get(p,wd)
  readRDS(strsplit(p, "/") %>%  unlist %>% tail(1)) %>% 
    return()
}
# read_m(wd,p)


# 数据拆分成训练集和测试集，返回list类型
split_dt <- function(dt,proportion){
  index  <- sample(2, nrow(dt), replace=T, 
                   prob=c(proportion,(1-proportion)))
  train <- dt[index==1,]
  test <- dt[index==2,]
  data <- list(train=train,test=test)
  return(data)
}

#验证两个向量的异同，最后得出相同的比率
# x <- c(1,1,1,1,2,2,3,3,4,4)
# y <- c(1,1,1,1,2,1,5,3,4,4)

ver_ratio <- function(x,y){
  require(magrittr)
  table(x,y) %>% 
    prop.table %>% 
    diag %>% 
    sum %>% 
    return()
}
# ver_ratio(x,y)
# ver_ratio(y,x)
# 重名了列名，dt 是df 类型，y是指定自变量（单列），剩余因变量
def_rename <- function(dt,y){
  require(magrittr)
  colnames(dt)[y] <- "y"
  colnames(dt)[-y] <- rep("x",(ncol(dt)-1)) %>% 
    paste0(c(1:(ncol(dt)-1))) 
  return(dt)
}






