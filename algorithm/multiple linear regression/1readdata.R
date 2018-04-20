# 1收集/观察数据；
# 2探索和准备数据；

# wd <- "/home/dsg/Rspace/mlr/" #本地工作环境
# hwd <- "/user/dsg/mlr"        #hdfs工作环境（训练集测试集该目录下）
# h_filename <- '/train.csv'    #hdfs上训练数据名字


obs_dt <- function(wd,hwd,h_filename){
  setwd(wd)
  source(paste0(wd,"procedure_fun.R")) #本地工作环境下
  train <- readh(paste0(hwd,h_filename))
# 了解训练集的情况并生成表保存在hdfs指定路径中  
  temp_1 <- save_t(wd,hwd,summary(train))
# 了解自变量（y）的情况并生成图、表保存在hdfs指定路径中   
  temp_2 <- save_t(wd,hwd,summary(train[,ncol(train)]))
  temp_3 <- save_p(wd,hwd,hist(train$charges))
# 了解数值型因变量之间的影响关系并生成图、表保存在hdfs指定路径中 
  temp_4 <- save_t(wd,hwd,cor(train[judge_df(train)]))
  require(psych)
  temp_5 <- save_p(wd,hwd,pairs.panels(train[judge_df(train)]))
  data.frame(temp_1,temp_2,temp_3,temp_4,temp_5) %>% 
    return()
}
obs_dt(wd,hwd,h_filename)     #调用函数 返回hdfs上文件存储地址。












