# 增强后模型预测

wd <- "/home/dsg/Rspace/mlr/" #本地工作环境
hwd <- "/user/dsg/mlr"        #hdfs工作环境（训练集测试集该目录下）
h_filename <- '/test1.csv'    #hdfs上训练数据名字
y = 'charges'
p = "/user/dsg/mlr/tmp/RtmpJpIoKx/filed1846b47ee0f.rds"

predict_t <- function(wd,hwd,h_filename,p,y){
  setwd(wd)
  source(paste0(wd,"procedure_fun.R"))
  test <- readh(paste0(hwd,h_filename))
  model_res <- read_m(wd,p)
  res <- predict(model_res,test[,!(names(test) %in% y)])
  cor <- cor(res,test[,(names(test) %in% y)])^2
}



library(pROC)
#generate ROC for training set
trainroc <- roc(test[,(names(test) %in% y)],res)
plot(trainroc, print.auc=TRUE, auc.polygon=TRUE, grid=c(0.1, 0.2),
     grid.col=c("green", "red"), max.auc.polygon=TRUE,
     auc.polygon.col="skyblue",
     print.thres=TRUE,
     main="训练集的ROC曲线")#ROC curve for training set
#generate ROC for testing set
testroc <-  roc(test[,(names(test) %in% y)],res)
plot(testroc, print.auc=TRUE, auc.polygon=TRUE, grid=c(0.1, 0.2),
     grid.col=c("green", "red"), max.auc.polygon=TRUE,
     auc.polygon.col="skyblue", print.thres=TRUE,
     main="ROC curve for testing set")

# 从图上可以直观看出，训练集上，ROC曲线更靠左上角，并且AUC值也更大，
# 因此我们建立的线性分类器在训练集上的表现要优于测试集。
# 
# 图上还有一条过(0,0)和(1,1)的直线，代表随机判断的情况。
# 如果ROC曲线在这条线的下方，说明分类器的效果不如随机判断。
# 一般是因为把预测符号弄反了，需要认真检查代码。





























# predict(model_res,
#         test[,!(names(test) %in% y)],
#         interval = "confidence")
# 用interval指定返回置信区间（confidence）或者预测区间（prediction），
# 这也反映了统计与机器学习的一个差异——可解释性。注意置信区间考虑的是平均值，
# 而预测区间考虑的是单个观测值，所以预测区间永远比置信区间广，
# 因此预测区间考虑了单个观测值的不可约误差；
# 而平均值同时也把不可约误差给抵消掉了。



# model_res$coefficients
# barplot(model_res$coefficients[2:length(model_res$coefficients)])


relweights <- function(fit, ...) {
  R <- cor(fit$model)
  nvar <- ncol(R)
  rxx <- R[2:nvar, 2:nvar]
  rxy <- R[2:nvar, 1]
  svd <- eigen(rxx)
  evec <- svd$vectors
  ev <- svd$values
  delta <- diag(sqrt(ev))
  # correlations between original predictors and new orthogonal variables
  lambda <- evec %*% delta %*% t(evec)
  lambdasq <- lambda^2
  # regression coefficients of Y on orthogonal variables
  beta <- solve(lambda) %*% rxy
  rsquare <- colSums(beta^2)
  rawwgt <- lambdasq %*% beta^2
  import <- (rawwgt/rsquare) * 100
  lbls <- names(fit$model[2:nvar])
  rownames(import) <- lbls
  colnames(import) <- "Weights"
  # plot results
  barplot(t(import), names.arg = lbls, ylab = "% of R-Square",
          xlab = "Predictor Variables", 
          main = "预测变量的相对重要性",#Relative Importance of Predictor Variables
          sub = paste("R-Square = ", round(rsquare, digits = 3)),
          ...)
  return(import)
}

fit <-lm(charges ~ age + age2 + children + bmi,
            data=train)
relweights(fit, col = "lightgrey")#模型必须接受数值型（因变量类型）











