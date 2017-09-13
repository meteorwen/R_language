#!/usr/bin/Rscript --slave 
argv <- commandArgs(TRUE)
x <- as.numeric(argv[1])
y <- as.numeric(argv[2])
path1 <- as.character(argv[3])
path2 <- as.character(argv[4])
savepath <- as.character(argv[5])
filename <- as.character(argv[6])
library(imager)
library(magrittr)
library(plyr)
read.imags <- function(path = "./",x,y) {
  fns <- list.files(path)
  res <- NULL
  for(i in fns) {
    fn <- paste(path, i, sep = "")
    im <- load.image(fn)                               #loading image
    im <- resize(im, size_x = x, size_y = y,       #cut image
                 size_z = 1L, size_c = 1L)
    im <- as.array(im)
    im <- matrix(im, 1,dim(im))
    ifelse(!is.null(res),
           res <- rbind(res, im), res <- im)
  }
  return(res)
}

tep1 <- read.imags(path1,x,y)
tep2 <- read.imags(path2,x,y)
lab1 <- rep(0,nrow(tep1))
lab2 <- rep(1,nrow(tep2)) 
dt1 <- cbind(lab1,tep1)
dt2 <- cbind(lab2,tep2)   
dt <- rbind(dt1,dt2)

chage.libsvm <- function(y,x) {
  dt <- vector()
  for ( i in 1:nrow( x )) {
    indexes <- which( as.logical( x[i,] ))
    values <-  x[i, indexes]
    iv_pairs <-  paste( indexes, values, sep = ":", collapse = " " )
    output_line <- paste0( y[i], " ", iv_pairs)
    dt[i] <- output_line
  }
  return(dt)
}

dt_libsvm <- chage.libsvm (dt[,1],dt[,2:ncol(dt)])

write.table(dt_libsvm,filename,quote = FALSE,row.names = FALSE,col.names = FALSE)  #save txt as libsvm format at location
# tep <- read.table("training.txt",sep = "\t")

hadoop_cmd <- "/opt/cloudera/parcels/CDH-5.8.0-1.cdh5.8.0.p0.42/bin/hadoop"
# copy csv from to hdfs
system2(hadoop_cmd, paste("fs -copyFromLocal",filename,savepath,sep = " ")) #save txt as libsvm format at hdfs



# in shell action:  
#Rscript test.R 28 28 /home/dsg/Rspace/datasets/train/cat/ /home/dsg/Rspace/datasets/train/dog/ /user/dsg/jpg/ train_cd.txt 
# library(rhdfs)
# Sys.setenv("HADOOP_CMD"="/usr/bin/hadoop")
# hdfs.init()
# training_path <- hdfs.file(paste0(savepath,'training.txt'), "w")
# hdfs.write(tep,training_path)
# hdfs.close(training_path)

