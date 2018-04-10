# 3 基于数据训练模型
# 4 评估模型的性能

wd <- "/home/dsg/Rspace/mlr/" #本地工作环境
hwd <- "/user/dsg/mlr"        #hdfs工作环境（训练集测试集该目录下）
h_filename <- '/train.csv'    #hdfs上训练数据名字

eva_m <- function(wd,hwd,h_filename){
  setwd(wd)
  source(paste0(wd,"procedure_fun.R")) #本地工作环境下
  train <- readh(paste0(hwd,h_filename))
  model <- lm(train[,ncol(train)]~.,data=train)
  temp_0 <- save_m(wd,hwd,model)
#评估模型： 
  # 1） Residuals（残差）部分提供了预测误差的主要统计量；
  # 2） 星号（例如，*）表示模型中每个特征的预测能力；
  # 3） 多元R方值（也称为判定系数）提供度量模型性能的方式，即从整体上，模型能多大程度解释因变量的值。
  temp_6 <- save_t(wd,hwd,summary(model)) 
#模型的图片保存结果。
  jpeg(file= "model.jpg")
  par(ask=F)
  par(mfrow=c(2,2))
  plot(model)
  dev.off()
  temp_7 = tempfile()
  hdfs.put(paste0(wd,"model.jpg"),paste0(hwd,temp_7,".jpg"))
  unlink(paste0(wd,"model.jpg"))
 data.frame(temp_0,
            temp_6,
            paste0(hwd,temp_7,".jpg")) %>%
   return()
}

# eva_m(wd,hwd,h_filename)




