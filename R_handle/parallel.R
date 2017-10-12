library(parallel)
x=y=64
detectCores() #当前计算机有几个核

library(magrittr)
path <- "/home/dsg/Rspace/datasets/testt/"
imagepath <- list.files(path) %>% paste(path, ., sep = "")

fun <- function(path,x,y){
  library(imager)
  library(magrittr)
  library(dplyr)
  res <- data.frame()
  return(
    res <- path %>% 
      load.image() %>% 
      imager::resize(x,y,1,1) %>% 
      as.vector() %>% 
      rbind(res, .)
  )
}

system.time(data1 <- sapply(imagepath,fun,x,y))
# 用system.time来返回计算所需时间
system.time({
  cl <- makeCluster(detectCores()) # 初始化16核心集群
  data2 <- parLapply(cl,imagepath,fun,x,y) %>% 
    unlist %>% 
    matrix(length(imagepath),x*y,byrow=T)
  stopCluster(cl) # 关闭集群
})
# data2[25,] %>% array(c(x,y,1,1)) %>% as.cimg %>% plot
