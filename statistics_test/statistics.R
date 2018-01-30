#  statistics
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




















