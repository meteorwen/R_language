# 多元线性型回归说明

----------

## 数据集
> 该数据集包含了美国病人的医疗费用。数据集使用了来自美国人口普查局（U.S. Census Bureau）的人口统计资料。

> 该文件（insurance.csv）包含1338个案例，即目前已经登记过的保险计划受益者以及表示病人特点和历年计划计入的总的医疗费用的特征。这些特征是：

- age: 这是一个整数，表示主要受益者的年龄（不包括超过64岁的人，因为他们一般由政府支付）。
- sex: 这是保单持有人的性别，要么是male，要么是female。
- bmi: 这是身体质量指数（Body Mass Index,BMI），它提供了一个判断人的体重相对于身高是过重还是偏轻的方法，BMI指数等于体重（公斤）除以身高（米）的平方。一个理想的BMI指数在18.5~24.9的范围内。
- children: 这是一个整数，表示保险计划中所包括的孩子/受抚养者的数量。
- smoker: 根据被保险人是否吸烟判断yes或者no。
- region: 根据受益人在美国的居住地，分为4个地理区域：northeast、southeast、southwest和northwest。

>如何将这些变量与已结算的医疗费用联系在一起是非常重要的。例如，可能认为老年人和吸烟者在大额医疗费用上是有较高的风险。与许多其他的方法不同，在回归分析中，特征之间的关系通常由使用者指定而不是自动检测出来。

## 探索和准备数据
```
insurance <- read.csv("insurance.csv",stringsAsFactors = TRUE)
str(insurance)
summary(insurance$charges)
hist(insurance$charges)
```
| Min. |1st Qu. | Median   | Mean |3rd Qu.   | Max.
|---|---|---|---| 
|   1132   | 4669   | 9424  | 13400  | 17084   |63770 

![](https://i.imgur.com/DaPdVS8.png)
>在数据中，绝大多数的个人每年的费用都在0~15000美元，尽管分布的尾部经过直方图的峰部后延伸得很远。即将面临的另一个问题就是回归模型需要每一个特征都是数值型的，而在
>的数据框中，有3个因子类型的特征。很快，会看到R中的线性回归函数如何处理变量。

### 1.探索特征之间的关系——相关系数矩阵

在使用回归模型拟合数据之前，有必要确定自变量与因变量之间以及自变量之间是如何相关的。相关系数矩阵（correlation matrix）提供了这些关系的快速概览。给定一组变量，它可以为每一对变量之间的关系提供一个相关系数。

为insurance数据框中的4个数值型变量创建一个相关系数矩阵，可以使用cor()命令：
```
cor(insurance[c("age","bmi","children","charges")])
```
![](https://i.imgur.com/5kistp8.jpg)
该矩阵中中的相关系数不是强相关的，但还是存在一些显著的关联。例如，age和bmi显示出中度相关，这意味着随着年龄（age）的增长，身体质量指数（bmi）也会增加。此外，age和charges，bmi和charges，以及children和charges也都呈现处中度相关。当建立最终的回归模型时，会尽量更加清晰地梳理出这些关系。

### 2.可视化特征之间的关系——散点图矩阵

或许通过使用散点图，可视化特征之间的关系更有帮助。虽然可以为每个可能的关系创建一个散点图，但对于大量的特征，这样做可能会变得比较繁琐。

另一种方法就是创建一个散点图矩阵（scatterplot matrix)，就是简单地将一个散点图集合排列在网格中，里边包含着相互紧邻在一起的多种因素的图表。它显示了每个因素相互之间的关系。斜对角线上的图并不符合这个形式。为何不符合呢？在这个语境下，这意味着找到某个事物和自身的关系，而正在尝试确定某些变量对于另一个变量的影响。默认的R中提供了函数pairs()，该函数产生散点图矩阵提供了基本的功能。对医疗费用数据之中的四个变量的散点图矩阵如下图所示。R代码如下：
```
pairs(insurance[c("age","bmi","children","charges")])
```
![](https://i.imgur.com/rQnuftx.jpg)
```
library(psych)
pairs.panels(insurance[c("age","bmi","children","charges")])
```
![](https://i.imgur.com/eimj1dM.jpg)

在对角线的上方，散点图被相关系数矩阵所取代。在对角线上，直方图描绘了每个特征的数值分布。最后，对角线下方的散点图带有额外的可视化信息。



**每个散点图中呈椭圆形的对象称为相关椭圆（correlation ellipse）**，它提供了一种变量之间是如何密切相关的可视化信息。位于椭圆中心的点表示x轴变量的均值和y轴变量的均值所确定的点。两个变量的相关性由椭圆的形状所表示，椭圆越被拉伸，其相关性越强。一个几乎类似于圆的完美的椭圆形，如bmi和children，表示一种非常弱的相关性。



**散点图中绘制的曲线称为局部回归平滑（loess smooth）**，它表示x轴和y轴变量之间的一般关系。最好通过例子来理解。散点图中age和childr的曲线是一个倒置的U，峰值在中年附近，这意味着案例中年龄最大的人和年龄最小的人比年龄大约在中年附近的人拥有的孩子更少。因为这种趋势是非线性的，所以这一发现已经不能单独从相关性推断出来。另一方面，对于age和bmi，局部回归光滑是一条倾斜的逐步上升的线，这表明BMI会随着年龄（age）的增长而增加，从相关系数矩阵中也可推断出该结论。

### 第3步——基于数据训练模型
 用R对数据拟合一个线性回归模型时，可以使用lm()函数。该函数包含在stats添加包中，当安装R时，该包已经被默认安装并在R启动时自动加载好。使用R拟合称为ins_model的线性回归模型，该模型将6个自变量与总的医疗费用联系在一起。代码如下：
```
ins_model <- lm(charges~age+children+bmi+sex+smoker+region,data=insurance)
ins_model

Call:
lm(formula = charges ~ age + children + bmi + sex + smoker + 
    region, data = train)

Coefficients:
    (Intercept)              age         children              bmi  
      -11632.36           258.45           453.56           335.33  
        sexmale        smokeryes  regionnorthwest  regionsoutheast  
          38.32         24487.55          -386.84         -1338.12  
regionsouthwest  
       -1314.27 


```
注意到，在模型公式中，仅指定了6个变量，但是输出时，除了截距项外，却输出了8个系数。之所以发生这种情况，是因为lm()函数自动将一种称为虚拟编码(dummy coding)的技术应用于模型所包含的每一个因子类型的变量中。当添加一个虚拟编码的变量到回归模型中时，一个类别总是被排除在外作为参照类别。然后，估计的系数就是相对于参照类别解释的。在模型中，R自动保留sexfemale、smokerno和regionnortheast变量，使东北地区的女性非吸烟者作为参照组。因此，相对于女性来说，男性每年的医疗费用要少$131.30；吸烟者平均多花费$23848.50，远超过非吸烟者。此外，模型中另外3个地区的系数是负的，这意味着东北地区倾向于具有最高的平均医疗费用。



线性回归模型的结果是合乎逻辑的。高龄、吸烟和肥胖往往与其他健康问题联系在一起，而额外的家庭成员或者受抚养者可能会导致就诊次数增加和预防保健（比如接种疫苗、每年体检）费用的增加。

### 第4步——评估模型的性能

通过在R命令行输入ins_model，可以获得参数的估计值，它们告诉关于自变量是如何与因变量相关联的。但是它们根本没有告诉如何用该模型来拟合数据有多好。为了评估模型的性能，可以使用summary()命令来分析所存储的回归模型：
```
summary(ins_model)

Call:
lm(formula = charges ~ age + children + bmi + sex + smoker + 
    region, data = train)

Residuals:
   Min     1Q Median     3Q    Max 
-12052  -2983  -1039   1487  29227 

Coefficients:
                 Estimate Std. Error t value Pr(>|t|)    
(Intercept)     -11632.36    1197.12  -9.717  < 2e-16 ***
age                258.45      14.71  17.571  < 2e-16 ***
children           453.56     168.73   2.688  0.00731 ** 
bmi                335.33      34.46   9.731  < 2e-16 ***
sexmale             38.32     409.82   0.094  0.92552    
smokeryes        24487.55     514.80  47.567  < 2e-16 ***
regionnorthwest   -386.84     589.83  -0.656  0.51208    
regionsoutheast  -1338.12     583.05  -2.295  0.02195 *  
regionsouthwest  -1314.27     593.53  -2.214  0.02705 *  
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 6284 on 941 degrees of freedom
Multiple R-squared:  0.7433,	Adjusted R-squared:  0.7411 
F-statistic: 340.5 on 8 and 941 DF,  p-value: < 2.2e-16
```

开始时，summary()的输出可能看起来令人费解，但基本原理是很容易掌握的。与上述输出中用标签编号所表示的一样，该输出为评估模型的性能提供了3个关键的方面：



1） Residuals（残差）部分提供了预测误差的主要统计量；

2） 星号（例如，***）表示模型中每个特征的预测能力；

3） 多元R方值（也称为判定系数）提供度量模型性能的方式，即从整体上，模型能多大程度解释因变量的值。



给定前面3个性能指标，模型表现得相当好。对于现实世界数据的回归模型，R方值相当低的情况并不少见，因此0.75的R方值实际上是相当不错的。考虑到医疗费用的性质，其中有些误差的大小是需要关注的，但并不令人吃惊。如下节所述，会以略微不同的方式来指定模型，从而提高模型的性能。

**在得到的回归模型进行显著性检验后:**
还要在做残差分析(预测值和实际值之间的差)，检验模型的正确性，残差必须服从正态分布N(0,σ^2)。

```
par(mfrow=c(2,2))
plot(ins_model)
```
![](https://i.imgur.com/Nf4AYCS.jpg)

- 残差和拟合值(左上)，残差和拟合值之间数据点均匀分布在y=0两侧，呈现出随机的分布，红色线呈现出一条平稳的曲线并没有明显的形状特征。
- 残差QQ图(右上)，数据点按对角直线排列，趋于一条直线，并被对角直接穿过，直观上符合正态分布。
- 标准化残差平方根和拟合值(左下)，数据点均匀分布在y=0两侧，呈现出随机的分布，红色线呈现出一条平稳的曲线并没有明显的形状特征。
- 标准化残差和杠杆值(右下)，没有出现红色的等高线，则说明数据中没有特别影响回归结果的异常点。

结论，没有明显的异常点，残差符合假设条件。

### 第5步——提高模型的性能
正如前面所提到的，回归模型通常会让使用者来选择特征和设定模型。因此，如果有关于一个特征是如何与结果相关的学科知识，就可以使用该信息来对模型进行设定，并可能提高模型的性能。

#### 1. 模型的设定——添加非线性关系
在线性回归中，自变量和因变量之间的关系被假定为是线性的，然而这不一定是正确的。例如，对于所有的年龄值来讲，年龄对医疗费用的影响可能不是恒定的；对于最老的人群，治疗可能会过于昂贵。
#### 2. 转换——将一个数值型变量转换为一个二进制指标
假设有一种预感，一个特征的影响不是累积的，而是当特征的取值达到一个给定的阈值后才产生影响。例如，对于在正常体重范围内的个人来说，BMI对医疗费用的影响可能为0，但是对于肥胖者（即BMI不低于30）来说，它可能与较高的费用密切相关。可以通过创建一个二进制指标变量来建立这种关系，即如果BMI大于等于30，那么设定为1，否则设定为0。
注：如果决定是否要包含一个变量时遇到困难，一种常见的做法就是包含它并检验其显著性水平。然后，如果该变量在统计上不显著，那么就有证据支持在将来排除该变量。
#### 3. 模型的设定——加入相互作用的影响
到目前为止，只考虑了每个特征对结果的单独影响（贡献）。如果某些特征对因变量有综合影响，那么该怎么办呢？例如，吸烟和肥胖可能分别都有有害的影响，但是假设它们的共同影响可能会比它们每一个单独影响之和更糟糕是合理的。

当两个特征存在共同的影响时，这称为相互作用（interaction）。如果怀疑两个变量相互作用，那么可以通过在模型中添加它们的相互作用来检验这一假设，可以使用R中的公式语法来指定相互作用的影响。为了体现肥胖指标（bmi30）和吸烟指标（smoker）的相互作用，可以这样的形式写一个公式：charge~bmi30*smoker。
#### 4. 全部放在一起——一个改进的回归模型
基于医疗费用如何与患者特点联系在一起的一点学科知识，采用一个认为更加精确的专用的回归公式。下面就总结一下改进：
- 增加一个非线性年龄项
- 为肥胖创建一个指标
- 指定肥胖与吸烟之间的相互作用

这次像之前一样使用lm()函数来训练模型，但是这一次，将添加新构造的变量和相互作用项：
```
library(dplyr)
insurance1 <- mutate(insurance,bmi30=ifelse(bmi>30,1,0), 
       age2 =age^2)

ins_model2 <-lm(charges~age+age2+children+bmi+sex+bmi30*smoker+region,data=insurance)

summary(ins_model2)

Call:
lm(formula = charges ~ age + age2 + children + bmi + sex + bmi30 * 
    smoker + region, data = train1)

Residuals:
    Min      1Q  Median      3Q     Max 
-3839.2 -1852.5 -1440.4  -803.8 24095.4 

Coefficients:
                  Estimate Std. Error t value Pr(>|t|)    
(Intercept)       -98.4424  1701.4811  -0.058  0.95387    
age               -17.2267    74.4085  -0.232  0.81696    
age2                3.6139     0.9306   3.883  0.00011 ***
children          669.6013   130.9668   5.113 3.85e-07 ***
bmi               119.3786    42.2912   2.823  0.00486 ** 
sexmale          -208.2179   305.3954  -0.682  0.49554    
bmi30            -980.2871   533.0803  -1.839  0.06624 .  
smokeryes       13275.8113   573.1889  23.161  < 2e-16 ***
regionnorthwest  -320.3684   439.4307  -0.729  0.46615    
regionsoutheast -1070.0533   434.7555  -2.461  0.01402 *  
regionsouthwest -1433.1314   442.0954  -3.242  0.00123 ** 
bmi30:smokeryes 20370.4218   767.5935  26.538  < 2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 4680 on 938 degrees of freedom
Multiple R-squared:  0.8581,	Adjusted R-squared:  0.8564 
F-statistic: 515.5 on 11 and 938 DF,  p-value: < 2.2e-16
```


分析该模型的拟合统计量有助于确定改变是否提高了回归模型的性能。相对于第一个模型，R方值从0.75提高到约0.87，模型现在能解释医疗费用变化的87%。此外，关于模型函数形式的理论似乎得到了验证，高阶项age2在在统计上是显著的，肥胖指标bmi30也是显著的。肥胖和吸烟之间的相互作用表明了一个巨大的影响，除了单独吸烟增加的超过$13404的费用外，肥胖的吸烟者每年要另外花费$19810，这可能表明吸烟会加剧（恶化）与肥胖有关的疾病。

### 第6步——预测模型
```
res <- predict(model_res,test[,!(names(test) %in% y)])
cor <- cor(res,test[,(names(test) %in% y)])^2
```