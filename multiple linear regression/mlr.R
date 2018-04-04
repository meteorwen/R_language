setwd("C:\\Users\\Administrator\\Desktop\\multiple linear regression")
library(magrittr)
insurance <- read.csv("insurance.csv",stringsAsFactors = TRUE)

id <- sample(2, nrow(insurance), replace=T, prob=c(0.7,0.3))
train <- insurance[id ==1,]
test <- insurance[id ==2,]

summary(train$charges)
hist(train$charges)

str(train)
summary(train$charges) #了解医疗开销分布情况
hist(train$charges) #图形展示医疗开销频次分布

cor(train[c("age","bmi","children","charges")]) #评判特征之间的影响结果




pairs(train[c("age","bmi","children","charges")])
library(psych)
pairs.panels(train[c("age","bmi","children","charges")])


ins_model <- lm(charges~age+children+bmi+sex+smoker+region,data=train)

sink("ins_model.txt")
summary(ins_model) 
sink(NULL)  #关闭sink 输入
unlink("ins_model.txt") #磁盘中删除ins_model.txt文件

res <- predict(ins_model,test[,-7])

df <- data.frame(test[,7],res)
cor(test[,7],res)

par(mfrow=c(1,1))  #设置画面布局


# 1、调整模型观测检验指标
# 根据业务知识来，去掉一些因变量来提高R方的值和T检验观测因变量贡献程度
pairs(train)

lm2<-update(ins_model, .~. -sex )
summary(lm2)# 效果不好 

lm3<-update(ins_model, .~. + bmi*smoker)
summary(lm3)

lm4<-update(ins_model, .~. + bmi*smoker -sex -bmi)
summary(lm4)
#从调整后的结果来看，效果还不错。不过，也并没有比最初的模型有所提高。

# 2、逐步回归，提高检验指标
step(ins_model)
# 通过计算AIC指标，ins_model的模型AIC最小时为16625.95，
# 每次去掉一个自变量都会让AIC的值变化不大，所以我们还是不调整比较好。
step(lm3)
# 通过AIC的判断，变化不大 AIC=16227.62 ~ AIC=16226.26


library(MASS)

stepAIC(ins_model,direction = "both") 
# “forward”为向前选择，"backward"为向后选择，"both"为混合选择







# age2 划分年纪：老年人/其他
# bmi30*smoker bmi30体脂大于30，肥胖人群与抽烟人群比对相互作用的影响
library(dplyr)
insurance1 <- mutate(insurance,bmi30=ifelse(bmi>30,1,0), 
       age2 =age^2)

train1 <- insurance1[id ==1,]
test1 <- insurance1[id ==2,]

# #bmi30\smoker交互项
ins_model2 <-lm(charges~age+age2+children+bmi+sex+bmi30*smoker+region,
                data=train1)
summary(ins_model2)
#相关系统检验
# T检验：所自变量都是非常显著***
# F检验：同样是非常显著，p-value < 2.2e-16
# 调整后的R^2：相关性非常强为0.8581

# 残差分析和异常点检测
# 在得到的回归模型进行显著性检验后，还要在做残差分析(预测值和实际值之间的差)，
# 检验模型的正确性，残差必须服从正态分布N(0,σ^2)。
# 直接用plot()函数生成4种用于模型诊断的图形，进行直观地分析。

par(mfrow=c(2,2)) #设置画面布局
plot(ins_model2)
# 残差和拟合值(左上)，残差和拟合值之间数据点均匀分布在y=0两侧，呈现出随机的分布，
#红色线呈现出一条平稳的曲线并没有明显的形状特征。

# 残差QQ图(右上)，数据点按对角直线排列，趋于一条直线，并被对角直接穿过，
#直观上符合正态分布。

# 标准化残差平方根和拟合值(左下)，数据点均匀分布在y=0两侧，呈现出随机的分布，
#红色线呈现出一条平稳的曲线并没有明显的形状特征。

# 标准化残差和杠杆值(右下)，没有出现红色的等高线，
#则说明数据中没有特别影响回归结果的异常点。
# 结论，没有明显的异常点，残差符合假设条件。






stepAIC(ins_model2,direction = "both") 

res1 <- predict(ins_model2,test1[,-7])

df1 <- data.frame(test1[,7],res1)
cor(test1[,7],res1)



plot(predict(ins_model,type = "response"),
     residuals(ins_model,type = "deviance"))

plot(predict(ins_model2,type = "response"),
     residuals(ins_model2,type = "deviance"))





# 交叉验证
shrinkage <- function(fit, k = 10) {
  require(bootstrap)
  # define functions
  theta.fit <- function(x, y) {
    lsfit(x, y)
  }
  theta.predict <- function(fit, x) {
    cbind(1, x) %*% fit$coef
  }
  # matrix of predictors
  x <- fit$model[, 2:ncol(fit$model)]
  # vector of predicted values
  y <- fit$model[, 1]
  results <- crossval(x, y, theta.fit, theta.predict, ngroup = k)
  r2 <- cor(y, fit$fitted.values)^2
  r2cv <- cor(y, results$cv.fit)^2
  cat("Original R-square =", r2, "\n")
  cat(k, "Fold Cross-Validated R-square =", r2cv, "\n")
  cat("Change =", r2 - r2cv, "\n")
}

shrinkage(ins_model)

lsfit(ins_model$model[,2:ncol(ins_model$model)] , ins_model$model[,1] )





















