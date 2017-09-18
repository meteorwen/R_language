#!/usr/bin/Rscript --slave 
argv <- commandArgs(TRUE)
x <- as.numeric(argv[1])            #图片裁剪长
y <- as.numeric(argv[2])            #图片裁剪宽
path1 <- as.character(argv[3])      #读取图片1文件路径地址
path2 <- as.character(argv[4])      #读取图片2文件路径地址
savepath <- as.character(argv[5])   #存储文件名
filename <- as.character(argv[6])   #hdfs上路径

# x <- 64
# y <- 64
# path1 <- '/home/dsg/Rspace/101_ObjectCategories/panda/'
# path2 <- '/home/dsg/Rspace/101_ObjectCategories/lotus/'
# filename <- 'pandalotus.txt'
# savepath <- '/user/dsg/jpg/'
library(imager)
library(magrittr)
library(plyr)
###################             image1         ####################
fns <- list.files(path1)
res1 <- NULL
imagep <- paste(path1, fns, sep = "")
pb <- txtProgressBar(min = 0, max = length(imagep), style = 3)

for(i in 1:length(imagep)) {
  im <- imagep[i] %>% 
    load.image()  %>%                             
    imager::resize(x,y,1,1) %>% 
    as.vector()
  ifelse(!is.null(res1),
         res1 <- rbind(res1, im), res1 <- im)
  # print(i)
  setTxtProgressBar(pb, i)
}

# res[20,] %>% array(c(64,64,1,1)) %>% as.cimg %>% plot

lab1 <- rep(0,nrow(res1))
dt1 <- cbind(lab1,res1)

###################             image2         ####################
fns <- list.files(path2)
res2 <- NULL
imagep <- paste(path2, fns, sep = "")
pb <- txtProgressBar(min = 0, max = length(imagep), style = 3)

for(i in 1:length(imagep)) {
  im <- imagep[i] %>% 
    load.image()  %>%                             
    imager::resize(x,y,1,1) %>% 
    as.vector()
  ifelse(!is.null(res2),
         res2 <- rbind(res2, im), res2 <- im)
  # print(i)
  setTxtProgressBar(pb, i)
}
lab2 <- rep(1,nrow(res2))
dt2 <- cbind(lab2,res2)
dt <- rbind(dt1,dt2)
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
write.table(libsvm,filename,quote = FALSE,row.names = FALSE,col.names = FALSE)  #save txt as libsvm format at location
# tep <- read.table("training.txt",sep = "\t")
###################             upload hdfs       ####################
hadoop_cmd <- "/opt/cloudera/parcels/CDH-5.8.0-1.cdh5.8.0.p0.42/bin/hadoop"
# copy txt from to hdfs
system2(hadoop_cmd, paste("fs -copyFromLocal",filename,savepath,sep = " ")) #save txt as libsvm format at hdfs
















