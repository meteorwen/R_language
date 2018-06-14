# http://echarts.baidu.com/tutorial.html#5%20%E5%88%86%E9%92%9F%E4%B8%8A%E6%89%8B%20ECharts
# https://madlogos.github.io/recharts/index_cn.html#-en
# library(devtools)
# install_github("madlogos/recharts")
browseVignettes("recharts") #可以离线查看本手册
library(recharts)
#  echartr(data, x, y, <series>, <weight>, <t>, <type>)
################################################################################
## -----------------------      散点图 气泡图      -----------------------------
echartr(iris, Sepal.Width, Petal.Width) #  未指定series，则不显示图例。
echartr(iris, Sepal.Width, Petal.Width, type='scatter') #等价同上
echartr(iris, ~Sepal.Width, Petal.Width, type='point') #等价同上
echartr(iris, Sepal.Width, "Petal.Width", type='bubble') #等价同上
echartr(iris, ~Sepal.Width, "Petal.Width", type='auto') #等价同上

echartr(iris, x=Sepal.Width, y=Petal.Width, series=Species) #标准使用
echartr(iris, Sepal.Width, Petal.Width, z=Species)
# 时间轴要求数值型或日期/时间型的Z变量。如果传入文本型变量，echartr会将其转为因子，
#并用其索引值作图，因子标签作为时间轴标签。

# 气泡图
# 关键是传入有效的数值型weight变量。如果weight被接受，且type为’bubble’，可生成气泡图。
echartr(iris, x=Sepal.Width, y=Petal.Width, weight=Petal.Length, 
        type='bubble')

# 如type是’scatter’/‘point’，不会显示气泡图，但weight可映射dataRange控件。
echartr(iris, Sepal.Width, Petal.Width, weight=Petal.Length) %>%
  setDataRange(calculable=TRUE, splitNumber=0, labels=c('Big','Small'),
               color=c('red', 'yellow', 'green'), valueRange=c(0, 2.5))

# 标注线和标注点addMarkLine And addMarkPoint
lm <- with(iris, lm(Petal.Width~Sepal.Width))
pred <- predict(lm, data.frame(Sepal.Width=c(2, 4.5)))

echartr(iris, Sepal.Width, Petal.Width, Species) %>%
  addML(series=1, data=data.frame(name1='Max', type='max')) %>%
  addML(series=2, data=data.frame(name1='Mean', type='average')) %>%
  addML(series=3, data=data.frame(name1='Min', type='min')) %>%
  addMP(series=2, data=data.frame(name='Max', type='max')) %>%
  addML(series='Linear Reg', 
        data=data.frame(name1='Reg', value=lm$coefficients[2], 
    xAxis1=2, yAxis1=pred[1], xAxis2=4.5, yAxis2=pred[2]))



data <- data.frame(
  name1=c('Max', 'Mean', 'Min'), type=c('max', 'average', 'min'),
  series=levels(iris$Species))
echartr(iris, Sepal.Width, Petal.Width, Species) %>%
  addML(series=1:3, data=data) %>%
  addMP(series=2, data=data.frame(name='Max', type='max')) %>%
  addML(series='Linear Reg', data=data.frame(
    name1='Reg', value=lm$coefficients[2], 
    xAxis1=2, yAxis1=pred[1], xAxis2=4.5, yAxis2=pred[2]))
################################################################################
## -----------------------      柱状图      -----------------------------

titanic <- data.table::melt(apply(Titanic, c(1,4), sum))
names(titanic) <- c('Class', 'Survived', 'Count')
knitr::kable(titanic)  # markdown 形式 print 输出 

# 单个数据系列Singular Series
echartr(titanic[titanic$Survived=='Yes',],Class, Count) %>%
  setTitle('Titanic: N Survival by Cabin Class')  
# 多个数据系列Multiple Series
echartr(titanic, Class, Count, Survived) %>%
  setTitle('Titanic: Survival Outcome by Cabin Class')
# 堆积条图Stacked Horizontal Bar Chart  type='hbar' 横向
echartr(titanic, Class, Count, Survived, type='hbar', subtype='stack') %>% 
  setTitle('Titanic: Survival Outcome by Cabin Class') 
# 龙卷风图Tornado Chart
## 龙卷风图是条图的特例。关键是：
# 1、提供一个全正值变量，和一个全负值变量
# 2、平铺，不要堆积
titanic_tc <- titanic
titanic_tc$Count[titanic_tc$Survived=='No'] <- 
  - titanic_tc$Count[titanic_tc$Survived=='No']
titanic_tc
g <- echartr(titanic_tc, Class, Count, Survived, type='hbar') %>%
  setTitle("Titanic: Survival Outcome by Cabin Class")
# 当然，我们还得微调一下坐标轴。Y轴应该和x轴交会于零点，
#且x轴标签都要取绝对值 (略有点复杂，需要懂一点JaveScript)。
g %>% setYAxis(axisLine=list(onZero=TRUE)) %>% 
  setXAxis(axisLabel=list(
    formatter=JS('function (value) {return Math.abs(value);}')
  ))

# 如果设type为’hbar’，subtype为’stack’，就得到了社会学中常用的人口学金字塔。
echartr(titanic_tc, Class, Count, Survived, type='hbar', subtype='stack') %>%
  setTitle("Titanic: Survival Outcome by Cabin Class") %>%
  setYAxis(axisLine=list(onZero=TRUE)) %>%
  setXAxis(axisLabel=list(
    formatter=JS('function (value) {return Math.abs(value);}')
  ))

# type='column' 纵向
echartr(titanic, Class, Count, Survived, type='column') %>%   
  setTitle('Titanic: Survival Outcome by Cabin Class') 
# subtype='stack'   （堆积柱图Stacked Vertical Bar (Column) Chart）
echartr(titanic, Class, Count, Survived, type='column', subtype='stack') %>%
  setTitle('Titanic: Survival Outcome by Cabin Class') 



## -----------------------      直方图Histogram      ---------------------------
# type可以是’histogram’、‘hist’。setTooltip(formatter='none'调用默认的tooltip模板。
echartr(iris, Sepal.Width, width=600) %>%
  setTitle('Iris: Histogram of Sepal.Width') %>%
  setTooltip(formatter='none') %>%   # 调用默认的tooltip模板
  setSeries(1, barWidth=500/13)  # Echarts2无法自适应设定barWidth

echartr(iris, Sepal.Width, type='hist', subtype='density', width=600) %>%
  setTitle('Iris: Histogram of Sepal.Width') %>% 
  setYAxis(name="Density") %>%
  setTooltip(formatter='none') %>% 
  setSeries(1, barWidth=500/13)

################################################################################  
#基础图类Basic Plots 03 - 线图Line/面积图Area
aq <- airquality
aq$Date <- as.Date(paste('1973', aq$Month, aq$Day, sep='-'))
aq$Day <- as.character(aq$Day)
aq$Month <- factor(aq$Month, labels=c("May", "Jun", "Jul", "Aug", "Sep"))
head(aq)

echartr(aq, Date, Temp, type='line') %>%
  setTitle('NY Temperature May - Sep 1973') %>% 
  setSymbols('none')
#       dt   x     y    type(factor)
echartr(aq, Day, Temp, Month, type='line') %>%
  setTitle('NY Temperature May - Sep 1973, by Month') %>% 
  setSymbols('emptycircle')
# 堆积线图Stacked Line Chart
echartr(aq, Day, Temp, Month, type='line', subtype='stack') %>%
  setTitle('NY Temperature May - Sep 1973, by Month') %>% 
  setSymbols('emptycircle')
# 权重变量映射线宽Line Width Mapped to Weight
echartr(aq, Day, Temp, Month, weight=Wind, type='line') %>%
  setTitle('NY Temperature May - Sep 1973, by Month') %>% 
  setSymbols('emptycircle')
# 带时间轴的线图Line Chart with Timeline (动态图效果，分月份变化)
echartr(aq, Day, Temp, t=Month, type='line') %>%
  setTitle('NY Temperature May - Sep 1973, by Month') %>% 
  setSymbols('emptycircle')
# 平滑线图Curve (Smooth Line) Chart
echartr(aq, Day, Temp, Month, type='curve') %>%  # type为’curve’
  setTitle('NY Temperature May - Sep 1973, by Month') %>% 
  setSymbols('emptycircle')
# 堆积平滑线图Stacked Smooth Line Chart
echartr(aq, Day, Temp, Month, type='curve', subtype='stack') %>%
  setTitle('NY Temperature May - Sep 1973, by Month') %>% 
  setSymbols('emptycircle')
# 面积图Area Chart                       #波峰与波谷空心圆点
echartr(aq, Date, Temp, type='area') %>%  
  setTitle('NY Temperature May - Sep 1973') %>% 
  setSymbols('emptycircle')
# 堆积面积图Stacked Area Chart
echartr(aq, Day, Temp, Month, type='area', subtype='stack') %>%
  setTitle('NY Temperature May - Sep 1973, by Month') %>% 
  setSymbols('emptycircle')
# 平铺平滑面积图Tiled Smooth Area Chart  #波峰与波谷实心圆点
echartr(aq, Date, Temp, type='wave') %>%
  setTitle('NY Temperature May - Sep 1973') %>% 
  setSymbols('emptycircle')
# 堆积平滑面积图Stacked Smooth Area Chart
echartr(aq, Day, Temp, Month, type='wave', subtype='stack') %>%
  setTitle('NY Temperature May - Sep 1973, by Month') %>% 
  setSymbols('emptycircle')
################################################################################  
#基础图类Basic Plots 04 - 蜡烛图Candlestick（蜡烛图也叫K线图。）
echartr(stock, as.character(date), c(open, close, low, high), type='k') %>%
  setXAxis(name='Date', axisLabel=list(rotate=90)) %>% 
  setYAxis(name="Price")
# 带时间轴With Timeline
stock$Month <- format(stock$date, '%m')
stock$Day <- format(stock$date, '%d')
fullData <- data.frame(expand.grid(unique(stock$Month), unique(stock$Day)))
# expand.grid(vector1,vector2) vector1 n个元素 ，vector2 m 个元素
# 函数的意思重复生成 df 类型的 m1重复了 n1次，即会生成 n*m 行的 df 格式
names(fullData) <- c("Month", "Day")
stock1 <- merge(stock, fullData, all.y=TRUE)
echartr(stock1, Day, c(open, close, low, high), t=Month, type='k') %>%
  setYAxis(name="Price")



################################################################################  
#基础图类Basic Plots 05 - 事件河流图eventRiver
data(events)
events$link <- 'www.baidu.com'
events$img <- 'inst/favicon.png'
events$title <- paste(rownames(events), events$event)
echartr(events, c(time, event, title, link, img), c(value, weight), series, 
        type='eventRiver') %>% 
  setTitle('Event River', 'Ficticious Data') %>% 
  setXAxis(name='Time') %>%
  setGrid(y2=80)


















