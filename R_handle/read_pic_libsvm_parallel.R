#!/usr/bin/Rscript --slave 
argv <- commandArgs(TRUE)
x <- as.numeric(argv[1])            #图片裁剪长
y <- as.numeric(argv[2])            #图片裁剪宽
path1 <- as.character(argv[3])      #读取图片1文件路径地址
path2 <- as.character(argv[4])      #读取图片2文件路径地址
filename <- as.character(argv[5])   #hdfs上路径
savepath <- as.character(argv[6])   #存储文件名


# x <- 64
# y <- 64
# path1 <- '/home/dsg/Rspace/101_ObjectCategories/panda/'
# path2 <- '/home/dsg/Rspace/101_ObjectCategories/lotus/'
# filename <- 'pandalotus1.txt'
# savepath <- '/user/dsg/jpg/'

library(plyr)
library(parallel)
library(magrittr)
imagepath1 <- list.files(path1) %>% paste(path1, ., sep = "")
imagepath2 <- list.files(path2) %>% paste(path2, ., sep = "")
read_pic <- function(path,x,y){
  library(imager)
  library(magrittr)
  library(dplyr)
  res <- data.frame()
  return(
    res <- path %>% 
      imager::load.image() %>% 
      imager::resize(x,y,1,1) %>% 
      as.vector() %>% 
      rbind(res, .)
  )
}



cl <- makeCluster(detectCores()) 

data1 <- parLapply(cl,imagepath1,read_pic,x,y) %>% 
  unlist %>% 
  array(c(length(imagepath1),x*y)) 

lab1 <- rep(0,nrow(data1))
dt1 <- cbind(lab1,data1)

data2 <- parLapply(cl,imagepath2,read_pic,x,y) %>% 
  unlist %>% 
  array(c(length(imagepath2),x*y)) 
lab2 <- rep(1,nrow(data2))
dt2 <- cbind(lab2,data2)
stopCluster(cl)

dt <- rbind(dt1,dt2)
row.names(dt) <- NULL
colnames(dt) <- NULL
dt <- data.frame(lab=dt[,1],dt[,2:ncol(dt)])
###################             libsvm format         ####################
pb <- txtProgressBar(min = 0, max = nrow( dt[,2:ncol(dt)]), style = 3)
libsvm <- vector()
for ( i in 1:nrow( dt[,2:ncol(dt)])) {
  indexes <- which( as.logical( dt[,2:ncol(dt)][i,] ))
  values <-  dt[,2:ncol(dt)][i, indexes]
  iv_pairs <-  paste( indexes, values, sep = ":", collapse = " " )
  output_line <- paste0( dt[,1][i], " ", iv_pairs)
  libsvm[i] <- output_line
  setTxtProgressBar(pb, i)
}
###################             saving local        ####################
write.table(libsvm,filename,quote = FALSE,row.names = FALSE,col.names = FALSE) #save txt as libsvm format at location
# tep <- read.table("training.txt",sep = "\t")
##################             upload hdfs       ####################
hadoop_cmd <- "/opt/cloudera/parcels/CDH-5.8.0-1.cdh5.8.0.p0.42/bin/hadoop"
# copy txt from to hdfs
system2(hadoop_cmd, paste("fs -copyFromLocal",filename,savepath,sep = " ")) #save txt as libsvm format at hdfs


# sudo -udsg Rscript test2.R 64 64 
# /home/dsg/Rspace/101_ObjectCategories/panda/ 
#   /home/dsg/Rspace/101_ObjectCategories/lotus/ 
#   pandalotus2.txt 
# /user/dsg/jpg/