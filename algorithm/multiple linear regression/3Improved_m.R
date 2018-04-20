
# 提高模型的性能
wd <- "/home/dsg/Rspace/mlr/" #本地工作环境
hwd <- "/user/dsg/mlr"        #hdfs工作环境（训练集测试集该目录下）
h_filename <- '/train1.csv'    #hdfs上训练数据名字
y = 'charges ~'               #自变量
x = 'age+age2+children+bmi+sex+bmi30*smoker+region'   #因变量


Improved_m <- function(wd,hwd,h_filename,y,x){
  setwd(wd)
  source(paste0(wd,"procedure_fun.R")) #本地工作环境下
  train <- readh(paste0(hwd,h_filename))
  ml_formula <-  as.formula(paste0(y,x))
  model2 <-lm(ml_formula,data=train)
  temp_8 <- save_t(wd,hwd,summary(model2)) 
  temp_10 <- save_m(wd,hwd,model2)
  jpeg(file= "model2.jpg")
  par(ask=F)
  par(mfrow=c(2,2))
  plot(model)
  dev.off()
  temp_9 = tempfile()
  hdfs.put(paste0(wd,"model2.jpg"),paste0(hwd,temp_9,".jpg"))
  unlink(paste0(wd,"model.jpg"))
  data.frame(temp_10,
             temp_8,
             paste0(hwd,temp_9,".jpg")) %>%
    return()
}




















































