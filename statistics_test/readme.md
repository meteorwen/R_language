#### 了解数据
##### 构建分析数据
```
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
```

##### **数据摘要**
- 描述
    统计理论中用来对数据进行多种基本统计如是否离散、 缺失值、 缺失率、
异常值、 唯一值、 零值、 是否正态分布、 最大值、 最小值、 平均值、 方差进行分
析。

```
summary()

library(fitdistrplus) 
fitdistrplus::descdist(1:10)

library(Hmisc)
describe(iris)

library(fBasics)
basicStats(iris$Sepal.Length) #支持纯数据
apply(iris[,1:4],2,function(x){basicStats(x)})
```
##### **百分位数**
- 描述
    如果将一组数据从小到大排序， 并计算相应的累计百分位， 则某一百分位
所对应数据的值就称为这一百分位的百分位数。 可表示为： 一组 n 个观测值按数
值大小排列。 如， 处于 p%位置的值称第 p 百分位数。

```
quantile(vector, probs = c(0.1, 0.2, 0.4))

dsg_quantile <- function(df){apply(df,2,
                  function(x){quantile(x, seq(0, 1, by = 0.1),na.rm=TRUE)})}
dsg_quantile(df)

q_interval <- function(df){apply(df,2,function(x){
  cut(x,unique(x %>% quantile(seq(0, 1, by = 0.1),na.rm=TRUE)))
})}
q_interval(df)
```
##### **缺失值分析**
- 描述
    对数据列中的缺失值统计数量和比例

```
dsg_na <- function(df){apply(df,2,function(x){sum(is.na(x)) %>% 
    round(2) %>% 
    return()})} #count how many NA
dsg_na(df)

na_p <- function(df){apply(df,2,function(x){sum(is.na(x)/length(x)) %>% 
    round(2) %>% 
    return()})} 
na_p(df)
```

##### **频率分布分析**
- 描述
    统计数据在各个频段内的频数， 从而了解数据的分布特点

选择数据列： 选择需要分析的列
组数： 指的是频数的组数， 如 20 表示将数据由小到大分为 20 段进行频率分布分析

```
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
```
##### **异常值分析**
- 描述
    分析数据中的异常值， 根据数据分布特性自动设定上下截断点的值， 不在
此范围内的数据为异常值

> 选择数据列： 选择需要分析的列

```
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
```
##### **贡献度分析**
- 描述
    贡献度分析又称为帕累托分析， 是从帕累托分析法衍生出来的一种分析方
法， 反映单个或多个因素对结果的影响程度。
> 选择项目列： 选择作为结果的列（ 单选）
产生效益列： 需要计算贡献度的列（ 单选）

```
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
```

#### 估计总体参数

##### 1.单正态总体的区间估计
方差已知，估计均值：Z检验：
z.test()：BSDA包，调用格式：

```
z.test(x, y = NULL, alternative = "two.sided", mu = 0, sigma.x = NULL, sigma.y = NULL, conf.level = 0.95)  
```

x,y是数值向量，默认y=NULL,即进行单样本的假设检验；
alternative用于指定估计的置信区间，默认为双尾区间，
less表示求置信上限，greate表示求置信下限；
mu表示均值，默认为0，仅在假设检验中起作用；
sigma.x和sigma.y分别指定两个样本总体的标准差；
conf.level指定区间估计的置信水平
simple.z.test()：UsingR包，只能进行置信区间估计，不能实现Z检验。调用格式：<br>

```
simple.z.test(x, sigma, conf.level=0.95)  
```
x是数据向量，sigma是已知的总体标准差，conf.level是置信度。
方差未知，估计均值：用t检验代替Z检验：
t.test():调用格式：
```
t.test(x, y = NULL, alternative=c("two sided","less","greater"), mu = 0,paired = TRUE, var.equal = FALSE, conf.level = 0.95,...) 
```
x，y为样本数据；alternative表示所求置信区间的类型，默认为双尾检验；mu表示均值，均值未知时不需要赋值；paired表示是否是成对检验；var.equal表示双样本的方差是否相等
均值已知/未知，估计方差：
根据均值已知/未知情况，用卡方分布估计方差置信区间，实际情况中均值多为未知。自行编写函数，可用以下代码实现：

```
var.conf.int=function(x,mu=Inf,alpha){  
     n=length(x)  
     if(mu<Inf){  
        s2=sum((x-mu)^2)/n  
        df=n}  
     else{  
        s2=var(x)  
        df=n-1}  
     c(df*s2/qchisq(1-alpha/2,df),df*s2/qchisq*alpha/2,df))}  
```
##### 2.双正态总体的区间估计
当两总体方差已知，估计均值差μ1-μ2：
z.test():BSDA包，调用格式同上：
```
z.test(x, y = NULL, alternative = "two.sided", mu = 0, sigma.x = NULL, sigma.y = NULL, conf.level = 0.95)  
```
当两总体方差未知但相等，估计均值差μ1-μ2：
t.test():调用格式同上
```
t.test(x, y = NULL, alternative=c("two sided","less","greater"), mu = 0,paired = TRUE, var.equal = FALSE, conf.level = 0.95,...)  
```
当两总体方差未知且不等，估计均值差μ1-μ2：
可用t.test(),设置方差不等，也可以自己编写函数，代码如下：
```
twosample.ci2=function(x,y,alpha){  
                n1=length(x);n2=length(y)  
               xbar=mean(x)-mean(y)  
                S1=var(x);S2=var(y)  
nu=(S1/n1+S2/n2)^2/(S1^2/n1^2/(n1-1)+S2^2/n2^2/(n2-1))  
           c(xbar-z,xbar+z)}  
```
两总体方差比的估计：
var.test():调用格式：
```
var.test(x, y, ratio = 1, alternative = c("two.sided","less","greater"), conf.level = 0.95,...)  
```
x,y为样本数据；ratio为原假设的方差比值；alternative设置检验类型为双尾或是单尾；conf.level为置信水平
##### 3.比率的区间估计
用于估计具有某个特征的个体在总体中的比例
prop.test():调用格式：
```
prop.test(x, n, p = NULL, alternative = c("two.sided","less","greater"),conf.level = 0.95,correct = TRUE) 
```
x为具有特征的样本数；n为样本总数；p设置假设检验的原假设比率值；alternative设置检验方式；conf.level为置信水平；correct设置是否使用Yates连续修正，默认为TRUE。
抽样比很小时，可以使用二项式检验：
binom.test():调用格式为：
```
binom.test(x, n, p = 0.5, alternative = c("two.sided","less","greater"),conf.level= 0.95)  
```
参数代表意义与prop.test()一致。


##### **均值的估计（ 单个总体）**
- 描述
    当总体数据非常庞大时很难对每一个对象进行研究， 均值的估计是根据从
总体中抽取的样本估计总体数据均值的方法。

>数据： 选择需要分析的字段（ 单选）
置信区间： 就结果输出为置信区间还是上下限
置信水平： 设置置信水平， 该结果均值出现的概率

```
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
} 

z.test(vector,4,conf.level=0.99)  #已知方差为4的正态分布

# 方差未知时的均值的区间估计
t.test(x)
t.test(x,conf.level = 0.99)
```

##### **均值差的估计（ 两个总体）**
- 描述
    均值差的估计是分别来自两总体的样本数据估计两总体的均值之差， 已知
来自两总体的样本数据估计两份样本的均值差， 判断两份样本是否有差别

>总体 X： 第一个总体样本字段
总体 Y： 第二个总体样本字段
置信区间： 选择输出结果为置信区间还是上下限
置信水平： 设置置信水平

```
t.test(vector1,vector2) 
```
##### **方差的估计（ 单个总体）**
- 描述
    方差的估计是根据从总体中抽取的样本估计总体分布中方差的方法， 总体
数据庞大、 总体的分布形式已知、 总体的样本数据已知。 输出为方差估计的置信
区间。

>数据： 选择需要进行分析的字段（ 单选）
置信区间： 输出置信区间还是上下限
置信水平： 设置置信水平

```
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
chisq.var.test(vector)
```
##### **方差比的估计（ 两个总体）**
- 描述
    方差比的估计是分别来自两总体的样本数据估计两总体的方差之比， 判断
两份样本稳定程度是否一样

>总体 X： 第一个总体样本字段
总体 Y： 第二个总体样本字段
置信区间： 选择输出结果为置信区间还是上下限
置信水平： 设置置信水平

```
t.test(x,y,var.equal=TRUE) #两方差都未知,但相等时两均值差的置信区间

## 两方差比的置信区间
var.test(x,y)
var.test(x,y,conf.level = 0.99)
```

##### **比率的估计（ 单个总体）**
- 描述
    比率的估计是根据样本数据估计总体中'1'所占的比例,总体数据庞大、 总体
的分布形式已知、 总体的样本数据已知。 输出为比率的估计范围。

> 数据： 选择需要进行分析的字段（ 单选）
置信区间： 输出置信区间还是上下限
置信水平： 设置置信水平

```
prop.test(34,120,correct=TRUE)  #用于估计具有某个特征的个体在总体中的比例,correct选项为是否做连续性校正
binom.test(34,120)  # 抽样比很小时，可以使用二项式检验
```
##### **比率差的估计（ 两个总体）**
- 描述
    比率差估计是根据样本 X 和样本 Y 估计总体 X 和总体 Y 的比率之差,判断
两份样本中'1'所占的比例是否一样。
> 总体 X： 第一个总体样本字段
总体 Y： 第二个总体样本字段
置信区间： 选择输出结果为置信
置信水平： 设置置信水平

```
s <- c(98,132)
t <- c(160,206)
prop.test(s,t)
```
#### 平均数检验
##### **T 检验（ 单个总体）**
- 描述
T 检验， 亦称 student t 检验（ Student's t test）， 主要用于样本含量较小（例如 n<30）， 总体标准差σ未知的正态分布资料。
数据： 选择需要检验的字段
平均值： 设定假设的均值
原假设： 选择是等于还是不小于、 不大于假设的均值
置信水平： 设置置信水平
```
t.test(sleep$extra,var.equal=T,mu=0)   #mu 总体样本均值
```



##### **T 检验（ 两个总体）**
- 描述
    用 t 分布理论来推论差异发生的概率， 从而比较两个平均数的差异是否显
著； 双总体 t 检验是检验两个样本平均数与其各自所代表的总体的差异是否显著。

总体 X： 第一个总体样本字段
总体 Y： 第二个总体样本字段
原假设： 假设两个总体的均值关系
置信水平： 设置置信水平
方差相等： 选择条件两个总体的方差是否相等
```
sleep_wide <- data.frame(id=1:10,g1=sleep$extra[1:10],g2=sleep$extra[11:20])
t.test(sleep_wide$g1,sleep_wide$g2,var.equal=T,mu =0) #假设两个总体的均值mu=0关系
```
##### **Wilcoxon 符号秩检验**
- 描述
    把观测值和零假设的中心位置之差的绝对值的秩分别按照不同的符号相加
作为其检验统计量。

分析列： 选择统计分析的列字段（ 单选）
中位数： 用户自定义中位数值

```
wilcox.test(mpg~am,data = mtcars)
wilcox.test(mtcars$mpg[mtcars$am==0],mtcars$mpg[mtcars$am==1]) #（与上面等价）
```
执行wilcoxon秩和检验（也称Mann-Whitney U检验）这样一种非参数检验 。<br>
t检验假设两个样本的数据集之间的差别符合正态分布（当两个样本集都符合正态分布时，t检验效果最佳）!<br>
但当服从正态分布的假设并不确定时，执行wilcoxon秩和检验来验证数据集中mtcars中自动档与手动档汽车的mpg值的分布是否一致。<br>
**p值<0.05,原假设不成立**。意味两者分布不同。<br>
*警告“无法精确计算带连结的P值“这是因为数据中存在重复的值，一旦去掉重复值，警告就不会出现。*


#### 相关性分析与检验
##### **相关性分析**
- 描述
     对从上级操作单元节点得到的数据表所选的不同字段间的相关性进行分析，
得到不同字段的相关系数以判定不同字段的相关性大小。

>字段选择： 用户选择进行数据勘察的字段
算法选择： 用户选择使用的算法（皮尔森，斯皮尔曼）<br>

`cor(x,use=,method=)`

x指矩阵或数据框；
use指定缺失数据的处理方式，可选的方式为all.obs（假设不存在缺失数据——遇到缺失数据时将报错）、everything（遇到缺失数据时，相关系数的计算结果将被设为missing）、complete.obs（行删除）以及pairwise.complete.obs（成对删除，pairwisedeletion）；
method指定相关系数的类型。可选类型为pearson、spearman或kendall<br>
```
# make data
states<-state.x77[,1:6]
cov(states)   #协方差
cor(states)   #三种相关系数
```

**pearson:**
```
cor(states,method = "spearman") # Spearman（默认）等级相关系数则衡量分级定序变量之间的相关程度。

x<-states[,c("Population","Income","Illiteracy","HS Grad")]
y<-states[,c("Life Exp","Murder")]
cor(x,y)
```

**spearman:**
```
cor(mtcars,method = "kendall") # Kendall’s Tau相关系数也是一种非参数的等级相关度量。
```

**相关关系的可视化：**
利用 corrgram 包中的 corrgram() 函数，可以以图形方式展示该相关系数矩阵。
corrgram() 函数基本格式为：corrgram(x,order= ,panel= ,text.panle= ,diag.panel= ) 
x 是一行一个观测的数据框;
order = TRUE 时，相关矩阵将使用主成分分析法对变量重排序，这将使得二元变量的关系模式更为明显。order = FALSE 时，变量按原来的顺序输出。
选项 panel 设定非对角线面板使用的元素类型。你可以通过选项lower.panel和upper.panel来分别设置主对角线下方和上方的元素类型。而 text.panel 和 diag.panel 选项控制着

```
options(digits = 2)
cor(mtcars)
```
```
library(corrgram)
corrgram(mtcars,order=TRUE,lower.panel=panel.shade,upper.panel=panel.pie,
         text.panel=panel.txt,main="Correlogram of Mtcars intercorrelations" )
```
我们先从下三角单元格（在主对角线下方的单元格）开始解释这幅图形。默认地，蓝色和从左下指向右上的斜杠表示单元格中的两个变量呈正相关。反过来，红色和从左上指向右下的斜杠表示变量呈负相关。色彩越深,饱和度越高，说明变量相关性越大。相关性接近于0的单元格基本无色。本图为了将有相似相关模式的变量聚集在一起，对矩阵的行和列都重新进行了排序（使用主成分法）。
从图中含阴影的单元格中可以看到， gear 、 am 、 drat 和 mpg 相互间呈正相关， wt 、 disp 、hp 和 carb 相互间也呈正相关。但第一组变量与第二组变量呈负相关。你还可以看到 carb 和 am 、vs 和 gear 、 vs 和 am 以及 drat 和 qsec 四组变量间的相关性很弱。
上三角单元格用饼图展示了相同的信息。颜色的功能同上，但相关性大小由被填充的饼图块的大小来展示.正相关性将从12点钟处开始顺时针填充饼图，而负相关性则逆时针方向填充饼图
```
corrgram(mtcars,order=TRUE,lower.panel=panel.ellipse,
         upper.panel=panel.pts,text.panel=panel.txt,
         diag.panel=panel.minmax,
         main="Correlogram of Mtcars intercorrelations" )
```
我们在下三角区域使用平滑拟合曲线和置信椭圆，上三角区域使用散点图。散点图限制了一些变量的可用值。例如，挡位数须取3、4或5，气缸数须取4、6或者8。am（传动类型）和vs（V/S）都是二值型。因此上三角区域的散点图看起来很奇怪。
为数据选择合适的统计方法时，你一定要保持谨慎的心态。指定变量是有序因子还是无序因子可以为之提供有用的诊断。当R知道变量是类别型还是有序型时，它会使用适合于当前测量水平的统计方法。


##### **偏相关分析**
- 描述
    当两个变量同时与第三个变量相关时， 需要消除第三个变量的影响时，
使用偏相关分析。 输入为控制变量和分析变量， 控制变量是保持不变的那个变量，
分析变量是需要计算相关性系数的变量， 输出结果为偏相关系数矩阵， 表示分析
变量两两之间的相关性。

控制变量： 保持不变的参考变量字段
分析变量： 需要计算相关性系数的变量字段
```
library(ggm)
pcor(c(1,5,2,3,6),cov(states)) #人口和谋杀率的偏相关系数(在控制了收入、文盲率和高中毕业率时)
```
```
# 偏相关检验
# 使用格式为：pcor.test(r,q,n)
 r 是由 pcor() 函数计算得到的偏相关系数，
 q 为要控制的变量数（以数值表示位置），
 n 为样本大小。
pcor.test(pcor(c(1,5,2,3,6),cov(states)),c(2,3,6),n=states)

```

##### **对应分析**
- 描述
    对应分析又称为关联分析、相应分析、 R-Q 分析， 是因子分析基础上发展而来的一种
多元统计分析方法， 它主要通过分析属性（ 定性） 与变量构成的列联表来揭示变
量之间的关系， 也是利用降维的思想以达到简化数据结构的目的
 
变量 X： 用户选择用于统计分析的第一个列字段（ 单选）
变量 Y： 用户选择用于统计分析的第二个列字段（ 单选）
R中的程序包MASS提供了两个函数，corresp()用于做简单一的对应分析，mca()用于计算多重对应分析，通常使用前者，其调用格式为corresp(x,nf=1,……)
x是数据矩阵:nf表示因子分析中计算因子的个数，通常取2.

```
ch=data.frame(A=c(47,22,10),B=c(31,32,11),C=c(2,21,25),D=c(1,10,20))
rownames(ch)=c("Pure-Chinese","Semi-Chinese","Pure-English")
library(MASS)
ch.ca=corresp(ch,nf=2)
options(digits=4)
ch.ca
```
分析结果给出了两个因子对应行变量、列变量的载荷系数。对应分析是一种可视化的多元统计方法，它主要是通过图形分析来得出结论，在R中我们使用函数biplot（）可以提取因子分析的散点图，以直观地展示样本和变量各个水平之间的关系。


##### **多重对应分析**
- 描述
    多重对应分析是处理多个变量间的特殊的对应分析方法。
 多重对应分析（MCA）和联合对应分析（JCA）是简单对应分析的扩展
MCA中的方法选择由mjca （）的 lambda 参数给出： 
    • lambda = "indicator": 基于指标矩阵的简单对应分析
    • lambda = "Burt": 基于Burt矩阵的特征值分解的分析
    • lambda = "adjusted": 基于带有惯量调整的Burt矩阵的分析(默认的，该函数给出的是调整方法（"adjusted"）)
    • lambda = "JCA": 联合对应分析
>分析列： 用户选择用于统计分析的列字段（ 多选）

```
library(ca)
data("wg93")
mjca(wg93[,1:4])
#输出标签由附加水平（1-5）名称的类别名称给出。
#注意在调整方式中惯量的和不是100%
#也可以绘图
plot( mjca(wg93[,1:4]))
summary(mjca(wg93[,1:4], lambda = "Burt"))#摘要一下MCA的结果：
```



##### **相关性检验**
- 描述
    相关性检验就是通过科学的统计方法对数据之间的相关性进行检验的方法。
输出结果为 p 值， 如果 p 值小于置信水平 0.05， 则拒绝原假设， 即变量之间不相关
变量列： 用户选择用于作为变量的列字段（ 单选）
目标列： 用户选择用于分析的列字段（ 单选）
```
#person 检验
a<-c(1,2,3)
b<-c(11,12,14)
cor.test(a,b,method="pearson")
```

##### **秩相关检验**
- 描述(spearman相关系数,亦即秩相关系数)
将两变量 X、 Y 成对的观察值分别从小到大顺序编秩， 若观察值相同取平
均秩次。 将秩次带入公式计算， 由样本算得的秩相关系数是否有统计学意义， 作
假设检验， 原假设为不相关。

>样本 A： 选择统计分析的列字段作为样本 1
样本 B： 选择统计分析的列字段作为样本 2
原假设： 是否相关
检验方法： 选择进行检验的方法
置信水平： 设置置信水平
连续修正： 是或否， 默认否
```
# spearman检验
a<-c(1,10,100,101)
b<-c(21,10,15,13)
cor.test(a,b,method="spearman")
# 用替换后的向量的pearson相关系数进行验证
e<-c(1,2,3,4)  # (1,10,100,101)替换成(1,2,3,4)
f<-c(4,1,3,2)  # (21,10,15,13)替换成(4,1,3,2)
cor.test(e,f,method="pearson")
```

##### **卡方独立性检验**
- 描述
    根据次数资料判断两类因子彼此相关或相互独立的假设检验。 与适合性检
验同属于卡方检验。

分析数据： 用户选择用于统计分析的列字段（ 可多选）

```
library(vcd)  # 当 p-value < 0.1时就可以认为他们之间没有显著的相关性
str(Arthritis)
mytable <- xtabs(~Treatment+Improved, data=Arthritis)
#这里是要检验的两个列属性：Treatment ，Improved，构建一个交叉相乘表。
mytable
chisq.test(mytable)   # 下面使用了卡方函数测量两个变量是否对立。　　　　　　　　　　　　　　　　　　　　　
mytable <- xtabs(~Sex+Improved, data=Arthritis)
mytable
chisq.test(mytable)

addmargins(mytable)
```

#### 回归分析
##### **多重共线性分析**
- 描述
    检验多重共线性是否存在； 估计多重共线性的范围， 即判断哪些变量之间
存在共线性
>选择数据列： 用户选择用于统计分析的列字段（ 多选）

```
#  当0<VIF<10，不存在多重共线性
#  当10≤VIF<100   存在较强的多重共线性;
#  当VIF>=100     多重共线性非常严重。

 cor(iris[,1:4]) %>% #求出自变量的协方差
	kappa(exact=TRUE)  #exact=TRUE表示精确计算条件数；
```
##### **线性回归分析**
- 描述
    线性回归， 是利用数理统计中回归分析， 来确定两种或两种以上变量间相
互依赖的定量关系的一种统计分析方法。 在回归分析中包括两个或两个以上的自
变量， 且因变量和自变量之间是线性关系， 则称为多元线性回归分析。

```
# in R
x <- c(151, 174, 138, 186, 128, 136, 179, 163, 152, 131)
y <- c(63, 81, 56, 91, 47, 57, 76, 72, 62, 48)

relation <- lm(y~x)  
summary(relation)
coef(relation)#求模型系数
formula(relation)#提取模型公式

a <- data.frame(x = 170)  #新数据进行预测
result <-  predict(relation,a)  #预测新人的体重
# 散点图与拟合直线
plot(y,x,col = "blue",main = "Height & Weight Regression",
     abline(lm(x~y)),cex = 1.3,pch = 16,xlab = "Weight in Kg",ylab = "Height in cm")
dev.off()

# in spark

lm_model <- iris_tbl %>%
  select(Petal_Width, Petal_Length) %>%
  ml_linear_regression(Petal_Length ~ Petal_Width)


iris_tbl %>%
  select(Petal_Width, Petal_Length) %>%
  collect %>%
  ggplot(aes(Petal_Length, Petal_Width)) +
    geom_point(aes(Petal_Width, Petal_Length), size = 2, alpha = 0.5) +
    geom_abline(aes(slope = coef(lm_model)[["Petal_Width"]],
                    intercept = coef(lm_model)[["(Intercept)"]]),
                color = "red") +
  labs(
    x = "Petal Width",
    y = "Petal Length",
    title = "Linear Regression: Petal Length ~ Petal Width",
    subtitle = "Use Spark.ML linear regression to predict petal length as a function of petal width."
  )


# 预测过程
 predicted <- sdf_predict(lm_model, test) %>%
    collect()
```

##### **逐步回归分析**
- 描述
    逐步回归是对一个或多个自变量和因变量之间关系进行建模的一种回归分
析， 通过删除自变量使模型达到最好。 利用建立好的模型和已知的自变量对因变
量进行预测

```



```

##### **广义线性模型**
- 描述
    把自变量的线性预测函数当作因变量的估计值

##### **一元多项式回归**
- 描述
    一元多项式回归用来处理一个因变量与和一个自变量之间的关系， 建立变
量之间的的线性模型并根据模型做分析和预测。

>多项次数： 一元 n 次多项式的次数 n
生成回归诊断图： 勾选生成诊断图， 不勾选则不生成。


##### **二次多项式回归**
- 描述
    一元多项式回归用来处理一个因变量与和一个自变量之间的关系， 建立变
量之间的的线性模型并根据模型做分析和预测。

##### **BoxCox 变换**
- 描述
    可以使线性回归模型满足线性性、 独立性、 方差齐性以及正态性的同时又
不丢失信息。 统计建模中常用的一种用于连续的响应变量不满足正态分布的情况
的数据变换。

##### **抗干扰回归**
- 描述
    抗干扰回归拟合数据集中比较好的点， 从而实现高崩溃点的回归估计。 崩
溃点表示的是一个估计量可以承受离群值的最大数目和样本容量之比。 整体稳健
可以用崩溃点来描述， 崩溃点越高， 抵抗离群值的能力越强， 估计越稳健。 抗干
扰回归的目的是使求出的回归系数不受离群值的影响。



#### 判别分析
##### **线性判别分析**
- 描述
     线性判别分析（ Linear Discriminant Analysis）， 是统计学上一种
经典的分析方法， 可以用于对数据进行分类， 首先要用事先分好类的数据对 LDA
进行训练， 建立判别模型， LDA 的基本思想是投影， 将 n 维数据投影到低维空间，
使得投影后组与组之间尽可能分开， 即在该空间中有最佳的可分离性， 而衡量标
准是新的子空间有最大的类间距离和最小的类内距离。

##### **二次判别分析**
- 描述 
    使用二次曲面来将物件或事件分成两个或以上的分类。

#### 聚类分析
##### **系统聚类**
- 描述 
    系统聚类是将各样品分成若干类的方法， 其基本思想是： 先将各样品各看
成一类， 然后规定类与类之间的距离， 选择距离最小的一对合并成新的一类， 计
算新类与其他类之间的距离， 再将距离最近的两类合并， 这样每次减少一类， 直
到获得合适的分类要求为止。

> 分析列： 用户选择用于统计分析的列字段（ 可多选）
聚类方法： 选择使用的聚类方法
距离： 选择距离计算方法
聚类个数： 选择聚类结果的个数
聚类距离： 根据用户输入的类间最小距离可自动确认聚类个数， 类间最小距离与
聚类个数必须二选一。

##### **Kmeans 聚类**
- 描述 
    k-means 算法是很典型的基于距离的聚类算法， 采用距离作为相似性的评
价指标， 即认为两个对象的距离越近， 其相似度就越大。 该算法认为簇是由距离
靠近的对象组成的， 因此把得到紧凑且独立的簇作为最终目标。
聚类可能做为数据预处理的一部分， 用于辅助分类， 对数据贴上标签。

>分析列： 用户选择用于统计分析的列字段（ 可多选）
聚类算法： 选择使用的聚类算法
聚类个数： 选择聚类结果的个数
迭代次数： 进行迭代计算的次数
随机集合数： 结果的集合数
聚类结果集合： 勾选进行集合， 不勾选则不集合

```
dsg_kmeans <- function(trainpath,modelpath,modelname,k){
require(sparklyr)
require(dplyr)
require(magrittr)
# config <- spark_config()
# config$spark.driver.cores <- 4
# config$spark.executor.cores <- 4
# config$spark.executor.memory <-"4g"

sc <- spark_connect(master = "yarn-client",
                    version="1.6.0", 
                    # config = config,
                    spark_home = '/opt/cloudera/parcels/CDH/lib/spark/')
require(stringr)
require(magrittr)
lab <- "Submitted application application_"
ss <- spark_log(sc, n = 10000) %>% 
  as.vector() 
appid <- grep(lab,ss) %>% 
  ss[.] %>% 
  strsplit( " ") %>% 
  unlist %>% 
  tail(1) 

dt <- spark_read_csv(sc, "train_data", trainpath)

kmeans_model <- dt %>% ml_kmeans(centers = k)

print(kmeans_model)

Sys.setenv(HADOOP_CMD="/opt/cloudera/parcels/CDH/bin/hadoop")
Sys.setenv(HADOOP_STREAMING="/opt/cloudera/parcels/CDH/lib/hadoop-0.20-mapreduce/contrib/streaming/hadoop-streaming-2.6.0-mr1-cdh5.8.5.jar")
Sys.setenv(HADOOP_COMMON_LIB_NATIVE_DIR="/opt/cloudera/parcels/CDH/lib/hadoop/lib/native/")
Sys.setenv(HADOOP_CONF_DIR='/etc/hadoop/conf.cloudera.hdfs')
Sys.setenv(YARN_CONF_DIR='/etc/hadoop/conf.cloudera.yarn')
require(rhdfs)
require(rJava)
hdfs.init()

modelfile = hdfs.file(paste0(modelpath,modelname,".rda"), "w")
hdfs.write(kmeans_model, modelfile)
hdfs.close(modelfile)
return(appid)
spark_disconnect_all()
}
```