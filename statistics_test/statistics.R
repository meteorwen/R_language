# ==============================================================================
# -*- coding: utf-8 -*-
#' Created on 2017-1-30
#' @author: qw
# ==============================================================================


 statistics
#1. 描述统计量
library(ggplot2)
str(iris)
attach(iris) #数据库连接到R搜索路径
detach(iris) #分离数据库
summary(iris$Sepal.Length)

str(women)


sp <- sunspots
class(sp)
str(sp)

sp <- matrix(sp, ncol=12, byrow=TRUE)
rownames(sp) <- 1749:1983
colnames(sp) <- 1:12
## 均值，最大值，最小值，求和，中位数，方差，标准差
mean(sp); max(sp); min(sp); sum(sp); median(sp)
summary(sp)
## 方差函数var用1向量、2向量和矩阵获得的结果和意义不一样
## 如果是矩阵数据，还有两个相关函数cov()和cor()
var(sp[,1])
var(sp[,1], sp[,2])
var(sp)

## 标准差sd只能以向量进行计算，如果是矩阵则按行计算
sd(sp)
sd(sp[1,])
sd(sp[,1])

## 求百分位数
quantile(sp)
quantile(sp, probs = c(0.1, 0.2, 0.4))

#2. 数据分布
## 直方图：hist函数
hist(sp)

# jpeg("output.jpg")
# hist(sp)
# dev.off()
#改变breaks参数可以获得更详细的图形
hist(sp, breaks = seq(from=min(sp), to=max(sp), length=1000))

png("output.png")
plot(women$height, women$weight)
dev.off()


## 核密度估计函数density：
d <- density(sp, n=length(sp))
## 密度函数的返回值可以直接作图
plot(d, main="")
## 叠加直方图和密度曲线
hist(sp, breaks = seq(from=min(sp), to=max(sp), length=100), freq=FALSE, main="")
lines(d, col="red")

## 经验分布曲线（与正态分布曲线比较，初步判断数据是否符合正态分布）：
ecd <- ecdf(sp) #获得经验分布函数
plot(ecd) #经验分布函数可以直接绘图
x <- sort(as.vector(sp))
lines(x, pnorm(x,mean(x), sd(x)), col="red") #获取该组数据的正态分布曲线，为图中红线

## QQ图：
## 用QQ图可以直观判断数据是否符合正态分布：如果符合正态分布，qqnorm应该接近qqline
qqnorm(sp, pch=".")
qqline(sp, col="red") #右上图中的红线

## 箱线图：这个用得很多。对于矩阵数据默认按列统计。
boxplot(sp, cex.axis=0.7)
#如果觉得眼花，加点颜色
color <- rainbow(ncol(sp))
boxplot(sp, cex.axis=0.7, col=color)

## 多变量分组比较：dotchart
## sunspots为1749年1月到1983年12月的数据，取其中一部分进行作图：
i <- c(1,21,41,61)
dotchart(sp[i,1:4], pch=1:4, cex=0.8)

# 三个变量的数据可以用coplot分析他们之间的关系，更多变量的数据用pairs()做初步分析，
#或自编绘图函数完成。一些R统计软件包提供了更丰富的函数和参数选项，如需要可自行学习使用。



norm.test(iris[,1:4])

#input.data应为矩阵
normal_test<- function(input.data,alpha=0.05,picplot=TRUE){
  if(picplot==TRUE){#画图形
    dev.new()#新建窗口画图
    par(mfrow=c(2,1))
    
    #Q-Q图法
    qqnorm(input.data,main="qq图")
    qqline(input.data)
    
    #概率密度曲线比较法
    hist(input.data,freq=F,main="直方图和密度估计曲线")
    #如果画出的图缺少尖端部分则使用下面这句代码
    #hist(input.data,freq=F,main="直方图和密度估计曲线",ylim = c(0,0.5))#使用合适的值来避免红蓝线缺少尖端部分，这里根据已经跑出来的图像我得出0.5
    lines(density(input.data),col="blue") #密度估计曲线
    x<-seq(min(input.data),max(input.data),0.0001)
    #使用seq(),若取0.0000001太密集跑大一点的数据就容易死机，建议0.0001
    lines(x,dnorm(x,mean(input.data),sd(input.data)),col="red") 
    #正态分布曲线，思想是根据求每个x应该对应的标准正态y值，然后将x与求出的y放在一起做出所求数据如果按照正态分布应该是怎样的，并于实际密度曲线（蓝线）对比 
  }#sd标准差 mean平均值
  
  #夏皮罗-威尔克（Shapiro-Wilk）检验法【数据不能过大，范围为3~5000，假如有一个300*300的矩阵那么这个方法运行函数时作废】
  shapiro_result<- shapiro.test(input.data)
  if(shapiro_result$p.value>alpha){
    print(paste("success:服从正态分布,p.value=",shapiro_result$p.value,">",alpha))    
  }else{
    print(paste("error:不服从正态分布,p.value=",shapiro_result$p.value,"<=",alpha))
  }
  shapiro_result
}



s <- rnorm(1000)
shapiro.test(s)  # Shapiro-Wilk方法进行正态检验

#检验结果，因为
# W接近1
# p值大于0.05，所以数据为正态分布

shapiro.test(iris$Sepal.Length)
is.na(iris) %>% sum()
lapply(iris[,1:4], shapiro.test)



#方差，方差是表示数之间与均值的离散程度。

s <- rnorm(50)
plot(c(1:50),s)
plot(c(1:50),s,type='b',col='red')
plot(c(1:50),s,type='c',col='red')
plot(c(1:50),s,type='o',col='red',pch=20)
plot(c(1:50),s,type='l',col='red')


colMeans(iris[,1:4])
colSums(iris[,1:4])
colnames(iris)
cov()         #协方差阵  
cor()         #相关矩阵  
cor.test()    #相关系数 


text <- function(p1,p2){
  temp <- read.csv(p1)
  res <- summary(temp)
  write.csv(res,p2)
}




library(fitdistrplus) 
fitdistrplus::descdist(1:10)
fitdistrplus::descdist(rep(1,100))
fitdistrplus::descdist(c(50 ,60 ,70 ,80 ,90 ,100 ,100))
fitdistrplus::descdist(c(79 ,79, 79 ,80, 81, 81, 81))
library(Hmisc)
describe(iris)

library(fBasics)
basicStats(iris$Sepal.Length) #支持纯数据
apply(iris[,1:4],2,function(x){basicStats(x)})





# ------------------------------------------------------------------------------
#  creat df include 0 and NA
library(magrittr)
library(dplyr)
library(tidyr)
set.seed(1)
vec <- c(1:100,rep(0,100),rep(NA,100),rep(NULL,100))
# nanes <- letters[1:20]
a <-  sample(vec,20)
b <-  sample(vec,20)
c <-  sample(vec,20)
d <-  sample(vec,20)
df <- data.frame(a=a,b=b,c=c,d=d)
# ------------------------------------------------------------------------------
# 了解数据

source('www/statistics-part1.R', local = TRUE)
#  dsg_summary 数据摘要

dsg_summary <- function(df){
colnames <- colnames(df)  # colnames
type <- apply(df,2,function(x){class(x) %>% 
    return()})  # type
min <- apply(df,2,function(x){min(x,na.rm=TRUE) %>% 
    round(2) %>% 
    return()})   # min 
max <- apply(df,2,function(x){max(x,na.rm=TRUE) %>% 
    round(2) %>% 
    return()})  # max 
median <- apply(df,2,function(x){median(x,na.rm=TRUE) %>% 
    round(2) %>% 
    return()})  # median
mean <- apply(df,2,function(x){mean(x,na.rm=TRUE) %>% 
    round(2) %>% 
    return()})    # mean
var <- apply(df,2,function(x){var(x,na.rm=TRUE) %>% 
    round(2) %>% 
    return()})     # var
sd <- apply(df,2,function(x){sd(x,na.rm=TRUE) %>% 
    round(2) %>% 
    return()})     # var
q1 <- apply(df,2,function(x){quantile(x,na.rm=TRUE,probs = c(0.25)) %>% 
    round(2) %>% 
    return()}) 
q3 <- apply(df,2,function(x){quantile(x,na.rm=TRUE,probs = c(0.75)) %>% 
    round(2) %>% 
    return()}) 
zero <- apply(df,2,function(x){sum(x==0,na.rm=TRUE) %>% 
    round(2) %>% 
    return()})  #count how many 0
norm <- apply(df,2,function(x){if(shapiro.test(x)[[2]]>0.05)
  return("从正态分布")
  else return("不服从正态分布")}) #p值大于0.05，所以数据为正态分布(Shapiro–Wilk正态检验)
na <- apply(df,2,function(x){sum(is.na(x)) %>% 
    round(2) %>% 
    return()}) #count how many NA
na_p <- apply(df,2,function(x){sum(is.na(x)/length(x)) %>% 
    round(2) %>% 
    return()}) 
cv <- apply(df,2,function(x){sd(x,na.rm=TRUE)/mean(x,na.rm=TRUE) %>% 
    round(2) %>% 
    return()}) # 变异系数(CV) 数据的类散程度表现
library(moments)# 统计偏度和峰度
skewness <- apply(df,2,function(x){skewness(x,na.rm=TRUE) %>% 
    round(2) %>% 
    return()})   #偏度skewness
kurtosis <- apply(df,2,function(x){kurtosis(x,na.rm=TRUE) %>% 
    round(2) %>% 
    return()})  #峰度kurtosis
summ <- data.frame(
  colnames=colnames,
  type=type,
  min=min,
  max=max,
  median=median,
  mean=mean,
  var=var,
  sd=sd,
  q1=q1,
  q3=q3,
  zero=zero,
  norm=norm,
  na=na,
  na_p=na_p,
  cv =cv,
  skewness=skewness,
  kurtosis=kurtosis
) %>% 
  t()
return(summ)
}
#  要求穿入df必须是数值型的df 不能传入字符串类型的 变量
# dsg_summary(iris[,1:3])     dsg_summary(mtcars)
# ------------------------------------------------------------------------------
#  百分位统计
dsg_quantile <- function(df){apply(df,2,
                  function(x){quantile(x, seq(0, 1, by = 0.1),na.rm=TRUE)})}
dsg_quantile(df)
q_interval <- function(df){apply(df,2,function(x){
  cut(x,unique(x %>% quantile(seq(0, 1, by = 0.1),na.rm=TRUE)))
})}
#向量中的一个元素，得到它在向量中的百分位数(区间)
q_interval(df)

# eg:
# x <- rnorm(100)
# z <- quantile(x, seq(0, 1, by = 0.1))
# m <- cut(x, z)  #向量中的一个元素，得到它在向量中的百分位数(区间)
# ------------------------------------------------------------------------------
# 缺失值分析
dsg_na <- function(df){apply(df,2,function(x){sum(is.na(x)) %>% 
    round(2) %>% 
    return()})} #count how many NA
dsg_na(df)

na_p <- function(df){apply(df,2,function(x){sum(is.na(x)/length(x)) %>% 
    round(2) %>% 
    return()})} 
na_p(df)

# 缺失值的补充方法
## 1、均值填补
ddf <-df
ddf$a[is.na(ddf$a)]= mean(ddf$a,na.rm=T)
## 2、中位数填补
ddf$b[is.na(ddf$b)]= median(ddf$b,na.rm=T)
## 3、 中心趋势值填补(众数)  centralImputation()
ddf$c %>% table %>% as.vector() %>% max()  #众数
ddf$c[is.na(ddf$c)]= (ddf$c %>% table %>% as.vector() %>% max() )
library(DMwR)
# 该函数用中心性统计(由相应列的函数集中度())填充数据帧所有列中的任何NA值。
DMwR:: centralImputation()  # 接受的参数必须是df
centralImputation(matrix(c(1:5,NA,3,3),2,4))

# ------------------------------------------------------------------------------
# 频率分布分析
apply(df,2,function(x){table(x)})
table(cut(df$a,5))

table(df$a)   #频数
df$a %>% na.omit()  #剔除缺失部分
library(DMwR)
ddf <- df %>% centralImputation

apply(df %>% centralImputation,2,
    function(x){prop.table(x) %>% 
    round(digits=2) %>% 
    return()}) #先将df重点NA进行集中度填充，在将每列上的值进行频率统计
# ------------------------------------------------------------------------------
# 异常值分析
## 异常值大概包括缺失值、离群值、重复值,数据不一致。
## 异常值处理方法主要有：删除法、插补法、替换法。
## 箱型图检验离群值
## 原理是超出上下箱体 1.5 倍的四分位间距为异常值，超出 3 倍则为极端值。

vec <- c(c(8:20),35,1,35,9,50)
abnormal <- function(x){
  q <- quantile(x, na.rm = TRUE)
  IQR <- q[4] - q[2]
  id <- which(x < q[2] - 1.5 * IQR | x > q[4] + 1.5 * IQR)
  val <- x[id] 
  return(data.frame(id =id ,value =val))
}

abnormal(vec)   #返回异常值的再原向量中的位置id和具体的值
boxplot(vec)
dev.off()

outlier.IQR <- function(x, multiple = 1.5, replace = FALSE, revalue = NA) { 
  q <- quantile(x, na.rm = TRUE) #四分位间距3倍间距以外的认为是离群值
  IQR <- q[4] - q[2]
  x1 <- which(x < q[2] - multiple * IQR | x > q[4] + multiple * IQR)
  x2 <- x[x1]
  if (length(x2) > 0) outlier <- data.frame(location = x1, value = x2)
  else outlier <- data.frame(location = 0, value = 0)
  if (replace == TRUE) {
    x[x1] <- revalue
  }
  return(list(new.value = x, outlier = outlier))
}
outlier.IQR(vec )
# outlier.IQR()$new.value  异常值替换后的新向量
# outlier.IQR()$outlier    原向量中异常值及其所在位置

## 箱线图
boxplot(mpg ~ cyl, data = mtcars, xlab = "气缸数",
        ylab = "每加仑里程", main = "里程数据")
dev.off()


# Plot the chart.
boxplot(mpg ~ cyl, data = mtcars, 
        xlab = "气缸数",
        ylab = "每加仑里程", 
        main = "里程数据",
        notch = TRUE, 
        varwidth = TRUE, 
        col = c("green","yellow","purple"),
        names = c("高","中","低")
)
# Save the file.
dev.off()
boxplot(Sepal.Width ~ Species,iris)
# ------------------------------------------------------------------------------
# 贡献度分析 又 帕累托分析 pareto (二八分)找到80%位置进行分析
names(df)
df1 <- arrange_(df,desc(substitute(a)))
col_name <- "a"

pareto <- function(df,col_name){
  df1 <- arrange_(df,.dots =paste0("desc(",col_name, ")"))
  vec <- select_(df1,col_name) %>% 
         na.omit()
  tep <- cumsum(vec)/sum(vec)
  id <- which(tep <= 0.8 )
  return(df1[id,])
}
# pareto(df,"a")


# 非标准化求值 Non-standard evaluation NSE
pa <- function(df,...){
     arrange(df,desc(...))
}
pa(df,a)

pa2 <- function(df,col){
  arrange_(df,.dots =paste0("desc(",col, ")"))
}
pa2(df,"a")

pa1 <- function(df,col){
   arrange_(df,substitute(as.name(col))) 
}
pa1(df,a)

library(lazyeval)
df1 %>%
  arrange_(.dots = c("grp", interp(~ desc(n1), n1 = as.name(myCol))))

arrange_(df, substitute(a)) 

tep <- order(df$a,decreasing = T)
tep1 <- cumsum()/sum(tep)
id <- which(tep1 <= 0.8 )
tep[id] #这些贡献度最高，需重点监控这些品类
# 贡献度分析可以重点改善某品类盈利最高的前80%的品类，或者重点发展综合影响最高的80%的部门
temp <- cumsum( order(1:10,decreasing = T))/sum(1:10)


dishdata <- read.csv("catering_dish_profit.csv")

barplot(dishdata[, 3], col = "blue1", names.arg = dishdata[, 2], width = 1,
        space = 0, ylim = c(0, 10000), xlab = "菜品", ylab = "盈利.元")

barplot(1:10,names.arg = letters[1:10], xlab = "names", ylab = "numbers", 
        col = "black",space = 0.05)
accratio <- dishdata[, 3]


for ( i in 1:length(accratio)) {
  accratio[i] <- sum(dishdata[1:i, 3]) / sum(dishdata[, 3])
}
cumsum(dishdata[, 3])/sum(dishdata[, 3])
sapply(dishdata[,3],function(x){x/sum(dishdata[,3])}) %>% cumsum()  #累积求和

par(new = T, mar = c(4, 4, 4, 4))
points(accratio * 10000 ~ c((1:length(accratio) - 0.5)), new = FALSE,type = "b", new = T)

axis(4, col = "red", col.axis = "red", at = 0:10000, label = c(0:10000 / 10000))

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# 估计总体参数
## 均值的区间估计
z.test<-function(x,sigma,conf.level=0.95,u0=0,alt="two.sided"){
  result<-list()
  mean<-mean(x)
  a=1-conf.level
  n <- length(x)
  z<-(mean-u0)/(sigma/sqrt(n))
  p<-pnorm(z,lower.tail=F)
  result$z<-z
  result$p.value<-p
  if(alt=="two.sided"){
    result$p.value<-2*p
  }
  else if (alt == "greater"|alt =="less" ){
    result$p.value<p
  }
  result$interval<-c(mean-sigma*qnorm(1-a/2,0,1)/sqrt(n),mean+sigma*qnorm(1-a/2,0,1)/sqrt(n))
  result
}   # sigma是方差
## e.g 某单位随机抽样的15位员工的身高分别为: 159 158 164 169 161 161 160 157 158 163 161 154 166 168 159, 
##假设身高服从方差为4的正态分布, 要求估计该单位员工身高均值的置信区间，置信水平为95%。

x<-c(159,158,164,169,161,161,160,157,158,163,161,154,166,168,159)



# 方差已知时的均值的区间估计
z.test(x,4) #默认95%的置信区间,方差为4的正态分布
z.test(x,4,conf.level=0.99)
# 方差未知时的均值的区间估计
t.test(x)
t.test(x,conf.level = 0.99)

# 均值差的估计（ 两个总体）
#eg:
#在数据集mtcars的数据帧列 mpg中，有1974年美国各种汽车的汽油里程数据。
mtcars$mpg 
#同时，在另一个数据列mtcars，命名为am ，表示汽车模型（0 =自动，1 =手动）的传输类型。
mtcars$am 
#特别是手动和自动变速器的耗油量是两个独立的数据总量。

# 假设mtcars中的数据遵循正态分布，则找到手动和自动变速器的平均耗油量之差的95％置信区间估计值。
L = mtcars$am == 0 
mpg.auto = mtcars [L,]$mpg 
mpg.manual = mtcars [!L,]$mpg 

t.test(mpg.auto,mpg.manual) 
#在mtcars中，自动变速器的平均里程为17.147 mpg，手动变速器为24.392mpg.
#平均耗油量差异的95％置信区间在3.2097至11.2802 mpg之间。

# ------------------------------------------------------------------------------
##  方差的区间估计
chisq.var.test<-function(x,conf.level=0.95,alt="two.sided",sigma0=1)   #默认95%的置信区间 双侧检验
{
  result<-list()
  n <- length(x)
  a=1-conf.level
  v<-var(x)
  result$interval<-c((n-1)*v/qchisq(1-a/2,n-1,lower.tail=T),(n-1)*v/qchisq(a/2,n-1,lower.tail=T))
  chi2<-(n-1)*v/sigma0
  result$chi2<-chi2
  p<-pchisq(chi2,n-1)
  if(alt=="two.sided")
    result$p.value<-2*min(pchisq(chi2,n-1),pchisq(chi2,n-1,lower.tail=F))
  else
    result$p.value<-pchisq(chi2,n-1,lower.tail=F)
  result
}
# 总体的方差，要求估计该单位员工身高方差的置信区间，置信水平为95%
chisq.var.test(x)

# 两正态总体参数的区间估计
# eg：
# 为比较两种药品的降糖效果, 选择20名条件相似的受试者, 分别服用甲、乙两种药品后，
# 测得甲组的血糖为6.48 4.00 5.54 6.89 5.14 4.60 3.67 4.32 4.80 7.50,
# 乙组的血糖为4.16 10.77 9.08 5.95 6.36 3.77 5.18 6.76 3.86 3.63。
# 假定甲乙两组血糖均服从正态分布，甲组的方差为5.0，乙组的方差为5.2，试求这两组平均血糖差的置信区间(取α=0.05)
x <- c(6.48,4.00,5.54,6.89,5.14,4.60,3.67,4.32,4.80,7.50)
y <- c(4.16,10.77,9.08,5.95,6.36,3.77,5.18,6.76,3.86,3.63)
sigma1<-5.0
sigma2<-5.2

t.test(x,y,var.equal=TRUE) #两方差都未知,但相等时两均值差的置信区间


#可用t.test(),设置方差不等，也可以自己编写函数
twosample.ci2=function(x,y,alpha){  
  n1=length(x);n2=length(y)  
  xbar=mean(x)-mean(y)  
  S1=var(x);S2=var(y)  
  nu=(S1/n1+S2/n2)^2/(S1^2/n1^2/(n1-1)+S2^2/n2^2/(n2-1))  
  c(xbar-z,xbar+z)}  

twosample.ci2(x,y)

## 两方差比的置信区间
var.test(x,y)
var.test(x,y,conf.level = 0.99)
# ------------------------------------------------------------------------------
# 单总体比率pp的区间估计
# eg:
#在某小学随机抽取了120人，发现其中34人有不同程度的视力下降，
#假定样本的数量服从正态分布，以95%的置信度, 估计这个小学视力下降比例。
prop.test(34,120,correct=TRUE)  #用于估计具有某个特征的个体在总体中的比例,correct选项为是否做连续性校正
binom.test(34,120)  # 抽样比很小时，可以使用二项式检验

# 两总体比率差p1−p2p1−p2的区间估计
# eg:
#对某疾病进行调查。在甲地区调查了160人，有98人符合诊断标准，在乙地区调查了206人，
#有132人符合诊断标准。试以95%的可靠性对该病在两地差别作出区间估计。
s <- c(98,132)
t <- c(160,206)
prop.test(s,t)



# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# 平均数检验
## T 检验（单个总体）student t检验方法，需要设置参数var.equal=TRUE。 
#（当两个样本集都符合正态分布时，t检验效果最佳）
# 样本与外生总体均值的对比：单样本t检验 
#假设现在我们的目的为检验列extra数据对应的总体均值是否为0，
#在下面的例子中，我们暂时忽略了变量group与变量ID 
t.test(sleep$extra,var.equal=T,mu=0)   #mu 总体样本均值



sleep_wide <- data.frame(id=1:10,g1=sleep$extra[1:10],g2=sleep$extra[11:20])
t.test(extra ~ group,sleep)  #welch t检验（样本方差不等），函数默认地调用Welch t检验方法

# T 检验（ 两个总体）
t.test(extra ~ group,sleep,var.equal=T) #student t检验(样本方差一致)
t.test(sleep_wide$g1,sleep_wide$g2,var.equal=T) #以宽数据为对象的操作（即指定两个独立向量）
t.test(sleep_wide$g1,sleep_wide$g2,var.equal=T,mu =0) #假设两个总体的均值mu=0关系
# 配对样本t检验 

#我们的数据集为包含分组变量的数据框，那么程序将默认group=1的数据行中的第一行与group=2
#的数据行中的第一行相互匹配。所以我们需要特别注意数据的排列顺序并确保其中没有缺失值，
#否则样本间的配对就不得不被打破。在下面的例子中，
#我们运用group和ID两个变量来确保数据排序的正确。 
sleep_order <- sleep[order(sleep$group,sleep$ID),]
t.test(extra ~ group,sleep_order,paired=T)

# 配对t检验的实质等同于检验每组相互配对的样本数据的差值的总体均值是否为0。
t.test(sleep_wide$g1 - sleep_wide$g2, mu =0,var.equal=T)

# Wilcoxon 符号秩检验
#如果正态都不满足！那就Wilcoxon非参数秩检验了，wilcox.test同样显示两组有显著性差异。
# p<0.05,拒绝原假设
wilcox.test(sleep$extra)
wilcox.test(extra~group,sleep,mu = 0)
wilcox.test(dd~treat, dat)


boxplot(mtcars$mpg~mtcars$am,ylab='mpg',names = c('automatic','manual'))

#执行wilcoxon秩和检验验证自动档手动档数据分布是否一致
wilcox.test(mpg~am,data = mtcars)
wilcox.test(mtcars$mpg[mtcars$am==0],mtcars$mpg[mtcars$am==1]) #（与上面等价）

# 执行wilcoxon秩和检验来验证数据集中mtcars中自动档与手动档汽车的mpg值的分布是否一致，
#p值<0.05,原假设不成立。意味两者分布不同。
#警告“无法精确计算带连结的p值“这是因为数据中存在重复的值，一旦去掉重复值，警告就不会出现。

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# 相关性分析与检验
## 相关性分析
# 正负先关，0是代表不相关（为假设），1代表相关。取值范围（0~1）
# Pearson积差相关系数衡量了两个定量变量之间的线性相关程度。
# 它是说明有直线关系的两变量间，相关关系密切程度和相关方向的统计指标。
n =10
x <- rnorm(n)
y <- rnorm(n)
cor(x,y,method = "pearson" )  #得到xy的相关系数,pearson(默认)spearman、kendall
cor.test(x,y,method = "pearson" )  #上面给出了相关系数的可信度区间和P-value，pearson(默认)
# eg：
cor.test(iris$Sepal.Length,iris$Sepal.Width,method="pearson") #Pearson相关性检验
plot(iris$Sepal.Length,iris$Sepal.Width)
cor.test(iris$Sepal.Length,iris$Sepal.Width,method="spearman")
cor.test(iris$Petal.Length,iris$Petal.Width,method="pearson") 
cor.test(iris$Petal.Length,iris$Petal.Width,method="spearman")
#  之间的p值小于0.05，故拒绝原假设，认为它们之间是相关的
# iris$Petal.Length,iris$Petal.Width 之间的相关系数cor大于0.8，故认为它们之间是高度相关的
plot(iris$Petal.Length,iris$Petal.Width)

states<-state.x77[,1:6]
cov(states)   #协方差
cor(states)   #三种相关系数
cor(states,method = "spearman") # Spearman等级相关系数则衡量分级定序变量之间的相关程度。
cor(mtcars,method = "kendall") # Kendall’s Tau相关系数也是一种非参数的等级相关度量。
# 如欲考察几位老师对多篇作文的评分标准是否一致(又称评分者信度)，就应该使用肯德尔系数。
pairs(states)
x<-states[,c("Population","Income","Illiteracy","HS Grad")]
y<-states[,c("Life Exp","Murder")]
cor(x,y)

cor.test(states[,3],states[,5])
# 检验了预期寿命和谋杀率的Pearson相关系数为0的原假设。假设总体的相关度为0，
# 则预计在一千万次中只会有少于一次的机会见到0.703这样大的样本相关度（即p=1.258e08）
# 。由于这种情况几乎不可能发生，所以可以拒绝原假设，即预期寿命和谋杀率之间的总体相关度不为0。
library(psych)
corr.test(x=states,use="complete")#缺失值"pairwise"成对删除 或 "complete" 行删除;

pairs(iris)#散点图是一种最为简单和最为有效的相关性分析工具

# 典型相关分析(利用综合变量对之间的相关关系来反映两组指标之间的整体相关性的多元统计分析方法)
#降维使用
library(magrittr)
scale_iris <- scale(iris[,1:4]) 
cancor(scale_iris[,1:4],c(rep(1,50),rep(2,50),rep(3,50)))

# 相关关系的可视化
options(digits = 2)
cor(mtcars)
library(corrgram)
corrgram(mtcars,order=TRUE,lower.panel=panel.shade,upper.panel=panel.pie,
         text.panel=panel.txt,main="Correlogram of Mtcars intercorrelations" )
corrgram(mtcars,order=TRUE,lower.panel=panel.ellipse,
         upper.panel=panel.pts,text.panel=panel.txt,
         diag.panel=panel.minmax,
         main="Correlogram of Mtcars intercorrelations" )
# ------------------------------------------------------------------------------
## 偏相关系数涉及到三个及以上变量之间的关系

# http://blog.csdn.net/qq_33683364/article/details/53992564
# pcor（u，s） 
# 其中的 u 是一个数值向量，前两个数值表示要计算相关系数的变量下标，
# 其余的数值为条件变量（即要排除影响的变量）的下标。 S 为变量的协方差阵。
library(ggm)
pcor(c(1,5,2,3,6),cov(states)) #人口和谋杀率的偏相关系数(在控制了收入、文盲率和高中毕业率时)

library(psych)
# 在多元正态性的假设下，psych包中的
# pcor.test()函数可以用来检验在控制一个或多个额外变量时两个变量之间的条件独立性。
# 使用格式为：pcor.test(r,q,n)
# 
# r 是由 pcor() 函数计算得到的偏相关系数，
# q 为要控制的变量数（以数值表示位置），
# n 为样本大小。
pcor.test(pcor(c(1,5,2,3,6),cov(states)),c(2,3,6),n=states)
# psych 包中的 r.test() 函数提供了多种实用的显著性检验方法。
# ------------------------------------------------------------------------------
# 对应分析
# http://www.cnblogs.com/jpld/p/4613109.html
library(MASS)
EyeHair<-caith
corr_<-corresp(EyeHair,nf=2);corr_
biplot(corr_) #作图
# ------------------------------------------------------------------------------
# 多重对应分析
library(ca)
data("wg93")
mjca(wg93[,1:4])
#输出标签由附加水平（1-5）名称的类别名称给出。
#注意在调整方式中惯量的和不是100%
#也可以绘图
plot(mjca(wg93[,1:4]))
summary(mjca(wg93[,1:4], lambda = "Burt"))#摘要一下MCA的结果：
# ------------------------------------------------------------------------------
# 卡方独立性检验（当 p-value < 0.1时就可以认为他们之间没有显著的相关性。）
library(vcd)
str(Arthritis)
mytable <- xtabs(~Treatment+Improved, data=Arthritis)
#这里是要检验的两个列属性：Treatment ，Improved，构建一个交叉相乘表。
mytable
chisq.test(mytable)   # 下面使用了卡方函数测量两个变量是否对立。　　　　　　　　　　　　　　　　　　　　　
mytable <- xtabs(~Sex+Improved, data=Arthritis)
mytable
chisq.test(mytable)

addmargins(mytable)






summ <- summary(df) %>% as.data.frame(stringsAsFactors=FALSE) %>% .[,2:3]
sp_s <- summary(sp) %>% as.data.frame()
widedata <- data.frame(person=c('Alex','Bob','Cathy'),grade=c(2,3,4),score=c(78,89,88))

names(summ) <- NULL
summ %>% spread( summ[,1],summ[,2])

library(reshape2)
dcast(summ,Var2,Freq)



# ==============================================================================
# ==============================================================================
# 回归分析
# ------------------------------------------------------------------------------
## 多重共线性分析
# 得到各个系数的方差膨胀因子，一般认为，
# （注意：在《R语言实战》第2版P182中认为:
#   VIF>4         就存在多重共线性）；
#  当0<VIF<10，不存在多重共线性
#  当10≤VIF<100   存在较强的多重共线性;
#  当VIF>=100     多重共线性非常严重。
# k<100,说明共线性程度小；如果100<k<1000，则存在较多的多重共线性;若k>1000，存在严重的多重共线性

collinear<-data.frame(
  Y=c(10.006, 9.737, 15.087, 8.422, 8.625, 16.289, 
      5.958, 9.313, 12.960, 5.541, 8.756, 10.937),
  X1=rep(c(8, 0, 2, 0), c(3, 3, 3, 3)), 
  X2=rep(c(1, 0, 7, 0), c(3, 3, 3, 3)),
  X3=rep(c(1, 9, 0), c(3, 3, 6)),
  X4=rep(c(1, 0, 1, 10), c(1, 2, 6, 3)),
  X5=c(0.541, 0.130, 2.116, -2.397, -0.046, 0.365,
       1.996, 0.228, 1.38, -0.798, 0.257, 0.440),
  X6=c(-0.099, 0.070, 0.115, 0.252, 0.017, 1.504,
       -0.865, -0.055, 0.502, -0.399, 0.101, 0.432)
)

XX<-cor(collinear[2:7])   #求出自变量的协方差
kappa(XX,exact=TRUE)  #exact=TRUE表示精确计算条件数；
#再用kappa()函数求出条件数,如果条件数大于1000说明严重多重共线

#eigen()用于发现共线性强的解释变量组合#
eigen(XX)    #查看哪些变量是共线的(可以看出x1到x5是多重共线的，可以保留一个。)

cor(iris[,1:4]) %>% kappa(exact=TRUE)
eigen(cor(iris[,1:4]))

# ------------------------------------------------------------------------------
## 线性回归分析（ in R）
age=c(18:29)   #年龄从18到29岁
height=c(76.1,77,78.1,78.2,78.8,79.7,79.9,81.1,81.2,81.8,82.8,83.5)
plot(age,height,main = "身高与年龄散点图")
lm.reg <- lm(height~age)  #建立回归方程
abline(lm.reg)    #画出拟合的线性回归线

coef(lm.reg)#求模型系数
formula(lm.reg)#提取模型公式

# 回归方程，对模型进行检验，方差分析的R
anova(lm.reg)    #模型方差分析
# 由于P<0.05，于是在α=0.05水平下，本例的回归系数有统计学意义，身高和年龄存在直线回归关系。
# 同理，对于上例中的回归方程，我们对模型进行回归系数的t检验，t检验的R代码如下：
summary(lm.reg)    #回归系数的t检验
 
# 同方差分析，由于P<0.05，于是在α=0.05水平下，本例的回归系数有统计学意义，身高和年龄存在回归关系。

x <- c(151, 174, 138, 186, 128, 136, 179, 163, 152, 131)
y <- c(63, 81, 56, 91, 47, 57, 76, 72, 62, 48)
relation <- lm(y~x)  # 得到斜率0.675  和截距-38.455  y = 0.675x + (-38.455)
summary(relation)
a <- data.frame(x = 170)
result <-  predict(relation,a)  #预测新人的体重

plot(y,x,col = "blue",main = "Height & Weight Regression",
     abline(lm(x~y)),cex = 1.3,pch = 16,xlab = "Weight in Kg",ylab = "Height in cm")
dev.off()

# ------------------------------------------------------------------------------
# 逐步回归分析

X1=c( 7, 1, 11, 11, 7, 11, 3, 1, 2, 21, 1, 11, 10);
X2=c(26, 29, 56, 31, 52, 55, 71, 31, 54, 47, 40, 66, 68);
X3=c( 6, 15, 8, 8, 6, 9, 17, 22, 18, 4, 23, 9, 8);
X4=c(60, 52, 20, 47, 33, 22, 6, 44, 22, 26, 34, 12, 12);
Y =c(78.5, 74.3, 104.3, 87.6, 95.9, 109.2, 102.7, 72.5,93.1,115.9,83.8,113.3,109.4);
cement<-data.frame(X1,X2,X3,X4,Y)
lm.sol<-lm(Y~X1+X2+X3+X4,data=cement)
summary(lm.sol) #查看Pr值是否足够小e-7以后


#从上述计算中可以看到，如果选择全部变量作回归方程，效果是不好的，
#因为回归方程的系数没有一项通过检验。接下来使用step()作逐步回归：

lm.step<-step(lm.sol)#查看AIC值最小和所去掉自变量

# 从程序运行结果可以看到，用全部变量作回归方程时，AIC值为26.94。
# 如果去掉变量X3，得到的回归方程的AIC值为24.974，如果去掉变量X4，
# 得到的回归方程的AIC值为25.011。后面类推，由于去掉变量X3可以使AIC达到最小，
# 因此R语言自动去掉变量X3，进行下一轮计算。

summary(lm.step)  #Pr值可以看到 x2、x4是人不够小（变量X2、X4系数检验的显著性水平仍然不理想）

# 由显示结果看到：回归系数检验的显著性水平很很大提高，
# 但变量X2、X4系数检验的显著性水平仍然不理想。下面该如何处理呢？
# R语言还有两个函数可以用来作逐步回归，这两个函数是add1()和drop1()，它们的调用格式为：

# add1(object,scope,scale=0,test=c("none","Chisq","F"),x= NULL,k=2)
# drop1(object,scope,scale=0,test=c("none","Chisq","F"),x= NULL,k=2)


# 其中object是由拟合模型构成的对象，scope是模型考虑增加或去掉项构成的公式，
# scale是用于计算残差的均方估计值，缺省值为0或NULL。下面用drop1()函数计算。

drop1(lm.step)  #查看Sq残差的平方,去掉最小Sq值对应自变量

# 从运算结果来看，如果去掉变量X4，AIC值会从24.974增加到25.420，是增加最少的。
# 另外，除了AIC准则外，残差的平方和也是逐步回归的重要指标之一。
# 从直观上来看，拟合越好的方程，残差的平方和应越小，去掉X4，残差的平方和上升9.93，
# 也是最少的，因此从这两项指标来看，应该去掉变量X4。

lm.opt<-lm(Y~X1+X2,data=cement)
summary(lm.opt)  #可以看到x1、x2所对应的Pr值都足够的小，因此挑选出自变量到“最优”回归方程

# 这个结果应该是满意的，因为所有的检验都是显著的，最后得到“最优”回归方程为：
# Y= 52.58+1.468*X1+0.6623*X2

# ------------------------------------------------------------------------------
# 广义线性模型
##  逻辑回归 Logistic（因变量为类别型）
#1. 预测阶段
library(AER)
data(Affairs,package = "AER")
summary(Affairs)
table(Affairs$affairs) #出轨次数

Affairs$ynaffair[Affairs$affairs > 0] <- 1
Affairs$ynaffair[Affairs$affairs == 0] <- 0
Affairs$ynaffair <- factor(Affairs$ynaffair,levels = c(0,1),labels = c("NO","Yes"))
table(Affairs$ynaffair) #是否出轨


fit.full <- glm(ynaffair ~ gender + age + yearsmarried + children + religiousness + education + occupation + rating,
                data = Affairs, family = binomial())
summary(fit.full)
# 从结果来看，性别、是否有孩子、学历、和职业对模型的结果贡献不大，因此减少变量数重新拟合，并检查新模型是否拟合得更好：
fit.reduced <- glm(ynaffair ~ age + yearsmarried + religiousness + rating,
                   data = Affairs, family = binomial())
summary(fit.reduced)
# 新模型每个回归系数都非常显著，对于两个嵌套模型可以使用anova()函数对它们进行比较，对于广义线性回归可以采用卡方检验。
anova(fit.full,fit.reduced,test = "Chisq")
# 卡方值不显著，表明四个预测变量的新模型与九个完整预测变量的模型拟合程度一样好，因此可以简化模型。

#解释模型参数(在Logistic回归当中，响应变量是Y=1的对数优势比（log），因此为了更好的解释性，需要对结果进行指数化。)
coef(fit.reduced)
exp(coef(fit.reduced))

# 可以看到婚龄增加一年，婚外情的优势比将乘以1.106(保持年龄、宗教信仰和婚姻评定不变)；
# 相反，年龄增加一岁，婚外情的的优势比则乘以0.965。
# 因此，随着婚龄的增加和年龄、宗教信仰与婚姻评分的降低，婚外情优势比将上升。类似的，考虑到预测变量不能为0，
# 截距项在此处没有什么特定含义。
# 
# 如有必要，可以使用confint()函数获取系数的置信区间，也可以进行指数化。

confint(fit.reduced)

#2. 预测阶段
#创建虚拟数据集
testdata <- data.frame(rating=c(1, 2, 3, 4, 5), age=mean(Affairs$age),
                       yearsmarried=mean(Affairs$yearsmarried),
                       religiousness=mean(Affairs$religiousness))
#使用测试数据集预测相应的概率
testdata$prob <- predict(fit.reduced, newdata=testdata, type="response")
testdata
# 从结果上看，当婚姻评分从1(很不幸福)变为5(非常幸福)时，婚外情概率从0.53降低到了0.15(假定年龄、婚龄和宗教信仰不变)。
#类似的方法我们可以探究每一个预测变量对结果概率的影响。

# 检查是否过度离势（比值phi =残差偏差/残差自由度比1大很多，则可以认为存在过度离势）
deviance(fit.reduced)/df.residual(fit.reduced) # 婚外情的例子比值非常接近于1，表明没有过度离势。

fit <- glm(ynaffair ~ age + yearsmarried + religiousness + rating, family = binomial(),data = Affairs)
fit.od <- glm(ynaffair ~ age + yearsmarried + religiousness + rating, family = quasibinomial(),data = Affairs)
pchisq(summary(fit.od)$dispersion * fit$df.residual,fit$df.residual,lower =F)
# 此时p值不显著，这进一步增加了我们认为不存在过度离势的信心。

## 泊松回归（因变量为计数型）
#如果我们将兴趣从是否有婚外情转移到过去一年中婚外情的次数，便可以直接泊松回归对计数型数据进行分析

library(robust)
data(breslow.dat, package = "robust")
names(breslow.dat)
summary(breslow.dat[c(6,7,8,10)])


opar <- par(no.readonly = TRUE)

par(mfrow=c(1,2))
attach(breslow.dat)
hist(sumY, breaks = 20, xlab = "Seizure Count",main = "Distribution of Seizures")
boxplot(sumY~Trt, xlab="Treatment",main = "Group Comparisons")
par(opar)

# 上图清楚地展示了因变量的偏倚特性和可能存在的离群点，
# 而且在药物治疗下癫痫发病数似乎变小了，且方差也变小了。下面用泊松回归进行拟合：
fit <- glm(sumY ~ Base + Age + Trt, data = breslow.dat, family = poisson())
summary(fit)
# 输出结果中的Coefficients结果列出了偏差、回归参数、标准误差和参数为0的检验。显然，所有的p值都小于0.05，结果都非常显著。

# Logistic回归是对数优势比，在泊松回归中，因变量以条件均值的对数形式 log_e(lambda)来建模，
# 响应的初始模型参数为对数均值，同样也可以进行指数化以探求因变量的初始尺度上解释回归系数。以下代码给出了着两者的参数：
coef(fit)   #参数显示
# 年龄的回归参数为0.023，表明保持其他预测变量不变,年龄增加一岁，癫痫发病数的对数均值将相应增加0.03。
# 截距项为预测变量都为0时，发病数的对数均值，显然年龄不可能为0，
# 而且调查对象的基础发病数也都不为0，因此截距项没有实际意义。
exp(coef(fit))
# 从指数化的系数可以看出，保持其他变量不变,年龄增加一岁，期望的癫痫发病数将乘以1.02。
# 这意味着年龄的增加与较高的癫痫发病数相关联。
# 更为重要的是,一单位 Trt 的变化(即从安慰剂到治疗组),期望的癫痫发病数将乘以0.86，
# 换句话说，保持基础癫痫发病数和年龄不变，服药组相对于安慰剂组癫痫发病数降低了20%。


# ------------------------------------------------------------------------------
# 一元多项式回归
# 普通最小二乘回归法（OLS）OLS回归是通过预测变量的加权和来预测量化的因变量，其中权重是通过数据估计而得到的参数。
# 找到最优方程
fit1 <- lm(women$weight ~ women$height,women)
summary(fit1) #没有限制小数点的位数。。截距为-87.51667，斜率为3.45  Multiple R-squared:  0.991
fitted(fit1)  #fitted()的结果是你得到相应的模型后，(x1,x2,...,xn)相应的值，也就是(y1,y2,...,yn)的值
residuals(fit1)  #residuals()---残差 =实际值-拟合值

#pic1
plot(women$height , women$weight)
lines(women$height,fitted(fit1))
dev.off()
#pic2
plot(women$height , women$weight)
abline(fit1)
dev.off()

fit2 <- lm(weight ~ height+I(height^2),women)
summary(fit2)   # Multiple R-squared:  0.9995


fit3<-lm(weight~height+I(height^2)+I(height^3),data=women)
summary(fit3)   # R-squared:  0.9998

# 二次多项式回归

df <- data.frame(w=c(42,42,46,46,46,50,50,50,52,52,58,58),
                 l=c(2.55,2.2,2.75,2.4,2.8,2.81,3.41,3.1,3.46,2.85,3.5,3))
fit <- lm(l~w+I(w^2),df)  #I（）为R中表达式另一个常用符号，用来从算数的角度来解释括号中的元素

with(df,plot(l~w))
lines(df$w,fitted(fit))

# ------------------------------------------------------------------------------
# BoxCox 变换
library(car)
hist(Wool$cycle)
summary(p1 <- powerTransform(Wool$cycles)) 
# 运用powerTansform函数，确定λ，然后以此为基础进行bcPower变换
hist(bcPower(Wool$cycles, p1$roundlam))
# 要进行powerTransform的函数，x中不能有0或者负数。
#因此，常用的做法是将x加上一定的数，平移后使其没有负数。

library(MASS)
b=boxcox(cycles~., data=Wool) # 定义函数类型和数据
I=which(b$y==max(b$y))
b$x[I]    #lambda= -0.06060606  得到-0.06060606 就是下图的最高点
# 第二步：依据上一步boxcox转化的lambda值，即-0.06060606 次方，代入模型

c=lm(cycles^b$x[I] ~ len + amp + load,data=Wool) # 定义一个多元回归，同理y x1 x2 x3 是cvs文件中，带变量名的字母
d=step(c) # 使用逐步法，进入多个自变量
summary(d) # 模型汇总
anova(d) #  用方差分析法对拟合的模型进行检验
shapiro.test(d$res) # 用残差对boxcox变化后的这个逐步回归方程 正态性进行检验




# ==================================判别分析====================================
# ==============================================================================
# 线性判别分
# 线性判别分析(LDA)主要用到了    lda(formula,data,…,subset,na.action)函数;

library(caret)
index <-createDataPartition(1:nrow(iris), time=1, p=0.7, list=F)

index <- sample(1:nrow(iris), 100)
train <-iris[index, ]
test <-iris[-index, ]

library(MASS)
fit_lda1=lda(Species~.,train)

fit_lda1
summary(fit_lda1)
fit_lda1[1:length(fit_lda1)] #查看模型的输出结果


plot(fit_lda1)
plot(fit_lda1,dimen=1)

pre_ldal=predict(fit_lda1,test[,1:4])
pre_ldal[1:length(pre_ldal)]

table(test$Species,pre_ldal$class)
error_lda1 <- sum(as.numeric(as.numeric(pre_ldal$class)!=as.numeric(test$Species)))/nrow(test)
acc_lda1  <- sum(as.numeric(as.numeric(pre_ldal$class)==as.numeric(test$Species)))/nrow(test)
# ------------------------------------------------------------------------------
# 二次判别分析
# 二次判别分析(QDA)则用到了        qda(formula,data,…,subset,na.action)函数
fit_lda2=qda(Species~.,train) #二次判别



# ==================================聚类分析====================================
# 系统聚类 
data=iris[,-5]
dist.e=dist(data,method='euclidean')
heatmap(as.matrix(dist.e),labRow = F, labCol = F)
# 首先提取iris数据中的4个数值变量，然后计算其欧氏距离矩阵。然后将矩阵绘制热图，
# 从图中可以看到颜色越深表示样本间距离越近，大致上可以区分出三到四个区块，其样本之间比较接近。
model1=hclust(dist.e,method='ward')
result=cutree(model1,k=3)
# 然后使用hclust函数建立聚类模型，结果存在model1变量中，
# 其中ward参数是将类间距离计算方法设置为离差平方和法。
# 使用plot(model1)可以绘制出聚类树图。如果我们希望将类别设为3类，
# 可以使用cutree函数提取每个样本所属的类别。

mds=cmdscale(dist.e,k=2,eig=T)
x = mds$points[,1]
y = mds$points[,2]
library(ggplot2)
p=ggplot(data.frame(x,y),aes(x,y))
p+geom_point(size=3,alpha=0.8,
             aes(colour=factor(result),
                 shape=iris$Species))

# 为了显示聚类的效果，我们可以结合多维标度和聚类的结果。先将数据用MDS进行降维，
# 然后以不同的的形状表示原本的分类，用不同的颜色来表示聚类的结果。
# 可以看到setose品种聚类很成功，但有一些virginica品种的花被错误和virginica品种聚类到一起。




















