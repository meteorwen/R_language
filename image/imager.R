library(imager)
plot(boats)
# 注意Y轴向下运行：原点位于左上角，这是图像的传统坐标系。
# 成像仪一致使用这个坐标系统。图像数据具有类“CImg”：
class(boats)

# 宽度和高度应自解释。深度是图像的多少帧：如果深度> 1然后图像实际上是一个视频
# 船有三个彩色通道，通常的RGB。一个灰度版本的船只有一个：
grayscale(boats)

# CImg类对象实际上只是一个薄的界面比普通4d阵列：
dim(boats)

# 下面我们将看到如何精确存储图像。对于大多数意图和目的，它们的行为就像常规数组，
# 这意味着通常的算术运算工作：

log(boats)+3*sqrt(boats)

mean(boats)

sd(boats)

# 现在你可能想知道为什么下面两幅图像看起来完全一样：

layout(t(1:2))
plot(boats)
plot(boats/2)


# 这是因为绘图功能，自动调整图像数据，使用颜色值的整个范围。有两个原因，
# 这是默认的行为：
# 没有标准的RGB值应该如何缩放标准。一些软件，像CImg一样，采用了一系列的0-255（暗），
# 其他的，像R的RGB函数，采用0-1范围。
# 通常用一零个均值图像来工作比较方便，也就是说有负值。
# 如果你不想成像改变颜色自动缩放，设置为false，但现在相机要值在[0,1] [0,1]范围


layout(t(1:2))
plot(boats,rescale=FALSE)
plot(boats/2,rescale=FALSE)

# 如果您想更严格地控制成像器如何将像素值转换为颜色，则可以指定颜色刻度。
# R喜欢它的颜色定义为十六进制码，像这样

rgb(0,1,0)


# 函数RGB是一个颜色尺度，即，它需要像素值和返回颜色。
# 我们可以定义一个替代的颜色尺度，交换红色和绿色值：


cscale <- function(r,g,b) rgb(g,r,b)
plot(boats,colourscale=cscale,rescale=FALSE)


# 在灰度图像中像素只有一个值，这样颜色图就比较简单：它需要一个值并返回一个颜色。
# 在下一个例子中，我们将图像转换为灰度

# 将灰度值映射为蓝色

cscale <- function(v) rgb(0,0,v)
grayscale(boats) %>% plot(colourscale=cscale,rescale=FALSE)

# 秤包有几个方便的功能创建颜色尺度，例如通过插值梯度：
cscale <- scales::gradient_n_pal(c("red","purple","lightblue"),c(0,.5,1))
#度标现在是一个函数返回的颜色代码
cscale(0)

grayscale(boats) %>% plot(colourscale=cscale,rescale=FALSE)





# 看到更多的信息和例子plot.cimg和as.raster.cimg文档。
# 你可能会想要做的下一件事就是加载一个图像，可以用load.image。
# 成像船与另一个例子图像，这是存储在您的R库某处。我们发现在使用system.file
fpath <- system.file('extdata/parrots.png',package='imager')
parrots <- load.image(fpath)
plot(parrots)

#相机支持JPEG，PNG，TIFF，BMP等格式来为你需要安装ImageMagick。
## 2例1：直方图均衡化
# 直方图均衡化是一种增强滤波器的教科书为例。这也是一个很好的话题，介绍你可以做的成像。
# 图像直方图只是像素值的直方图，这在R中当然很容易得到：

grayscale(boats) %>% hist(main="Luminance values in boats picture")


# 由于图像存储为数组，这里我们只使用R的正规历史功能，它把我们的数组作为值的向量。
# 如果我们只想看红色通道，我们可以使用：

R(boats) %>% hist(main="Red channel values in boats picture")


## 另一种方法是把图像转换成一个数据框，并用ggplot立即查看所有通道：
library(ggplot2)
bdf <- as.data.frame(boats)
head(bdf,3)
bdf <- plyr::mutate(bdf,channel=factor(cc,labels=c('R','G','B')))
ggplot(bdf,aes(value,col=channel))+geom_histogram(bins=30)+facet_wrap(~ channel)


# 我们从这些直方图中立即看到的是，中间值在某种意义上是过度使用的：
# 很少有高值或低值的像素。直方图均衡化的直方图平坦的解决问题：
# 每一个像素的值是由其排名所取代，这相当于运行数据通过他们的经验CDF
#作为说明这是什么，请看下面的例子：

x <- rnorm(100)
layout(t(1:2))
hist(x,main="Histogram of x")
f <- ecdf(x)
hist(f(x),main="Histogram of ecdf(x)")

#我们可以直接应用于图像如下：
boats.g <- grayscale(boats)
f <- ecdf(boats.g)
plot(f,main="Empirical CDF of luminance values")   #亮度值的经验CDF

#我们再次使用一个标准的R函数（方法），它返回另一个函数对应的亮度值，在该船的G。
# 如果我们运行的像素数据通过F，我们得到一个平面直方图：
f(boats.g) %>% hist(main="Transformed luminance values")   #改变亮度值
# 现在唯一的问题是，该基地，并没有意识到我们的CImg的对象。
# 函数f取一个图像并返回一个向量：
f(boats.g) %>% str

# 如果我们希望获得图像后我们就可以使用as.cimg：
f(boats.g) %>% 
  as.cimg(dim=dim(boats.g)) %>% 
  plot(main="With histogram equalisation")

#到目前为止，我们已经运行在灰度图像。如果我们想在RGB数据做到这一点，
#我们需要运行的均衡分别在各通道。成像器使其使用分裂应用组合技巧：

#hist.平均灰度
hist.eq <- function(im) as.cimg(ecdf(im)(im),dim=dim(im))
#拆分为颜色通道，
cn <- imsplit(boats,"c")
cn
#我们现在有一个图像列表

# Image list of size 3 

cn.eq <- llply(cn,hist.eq) #run hist.eq on each
imappend(cn.eq,"c") %>% plot(main="All channels equalised") #recombine and plot


iiply(boats,"c",hist.eq) 

#我们可以用它来检查所有的渠道有正确的标准：
iiply(boats,"c",hist.eq) %>% 
  as.data.frame %>% 
  ggplot(aes(value))+geom_histogram(bins=30)+facet_wrap(~ cc)

# 3例子2：边缘检测
# 边缘检测依赖于图像梯度，成像器返回通过：

gr <- imgradient(boats.g,"xy")
gr
# Image list of size 2 
plot(gr,layout="row")

# 对象“GR”是一个图像列表，有两个分量，一个用于沿XX的梯度，另一个用于沿YY渐变。
# “GR”是一个对象类的“imlist”，这是一个图像列表但带有一些方便的功能
# （例如，一个绘图功能上面所用的）。
# 更具体地说，注意到我（x，y）（x，y）我的图像强度在位置x，x，Y，
# 什么成像的回报是一个近似的：

dx <- imgradient(boats.g,"x")
dy <- imgradient(boats.g,"y")
grad.mag <- sqrt(dx^2+dy^2)
plot(grad.mag,main="Gradient magnitude")

-----------------------------------------------------
#这里的方便条捷径：
tmp <- imgradient(boats.g,"xy") %>% 
  enorm #平方在开方，绝对值
plot(tmp,main="Gradient magnitude (again)")
#The first function returns a list of images:
l <- imgradient(boats.g,"xy")
str(l)

###   4 imager and ggplot2
#使用ggplot2绘制你的图像数据，使用和geom_raster as.data.frame：
df <- grayscale(boats) %>% as.data.frame
p <- ggplot(df,aes(x,y))+geom_raster(aes(fill=value))
p
p + scale_y_continuous(trans=scales::reverse_trans())
### 5 blob检测/提取局部极大值，去噪，尺度空间
hub <- load.example("hubble") %>% grayscale
plot(hub,main="Hubble Deep Field")
#在我们使用真实图像之前，我们将尝试合成数据。下面是如何生成一些随机放置的斑点图像
layout(t(1:2))
set.seed(2)
points <- rbinom(100*100,1,.001) %>% as.cimg(x=100,y=100)
blobs <- isoblur(points,5)    #从随机点卷积一大小为5像素的模糊核得到的斑点。
plot(points,main="Random points")
plot(blobs,main="Blobs")
imhessian(blobs)
#为了得到我们所需要的衍生物：
Hdet <- with(imhessian(blobs),(xx*yy - xy^2))
plot(Hdet,main="Determinant of Hessian")
#为了获得只有最高值的像素，我们对图像阈值：
threshold(Hdet,"99%") %>% plot(main="Determinant: 1% highest values")
#阈值的图像包含了离散的图像区域，如果我们可以计算中心，这些地区我们将有我们的位置。
# 第一步是标记这些区域：
lab <- threshold(Hdet,"99%") %>% label
plot(lab,main="Labelled regions")


#标签是一个实用工具，填补了每个白色区域与一个独特的像素值（背景停留在0）。
#我们可以提取在data.frame的形式标记的区域：

df <- as.data.frame(lab) %>% subset(value>0)
head(df,3)

unique(df$value) #10 regions

#现在我们需要做的是把数据分成多个区域，并计算各平均坐标值。
# 我们显示了两个解决方案，一个使用路经，其他使用最近的dplyr变异：
centers <- ddply(df,.(value),summarise,mx=mean(x),my=mean(y))
centers <- dplyr::group_by(df,value) %>% 
  dplyr::summarise(mx=mean(x),my=mean(y))

#作为练习，您可以尝试提取其他汇总值的区域（面积，例如，或纵横比）。
#我们现在覆盖的结果对原始图像：

plot(blobs)
with(centers,points(mx,my,col="red"))

# 这很好，但要使事情更难一点，我们会增加噪音的形象：
nblobs <- blobs+.001*imnoise(dim=dim(blobs))
plot(nblobs,main="Noisy blobs")

#如果我们再尝试同样的事情，它完全失败
get.centers <- function(im,thr="99%")
{
  dt <- imhessian(im) %$% { xx*yy - xy^2 } %>% threshold(thr) %>% label
  as.data.frame(dt) %>% subset(value>0) %>% dplyr::group_by(value) %>% dplyr::summarise(mx=mean(x),my=mean(y))
}

plot(nblobs)
get.centers(nblobs,"99%") %$% points(mx,my,col="red")

# 我们需要一个额外的去噪步骤。简单的模糊会在这里：
nblobs.denoised <- isoblur(nblobs,2)
plot(nblobs.denoised)
get.centers(nblobs.denoised,"99%") %$% points(mx,my,col="red")


#我们已经准备好进入 Hubble image。这是第一次天真的尝试：
plot(hub)
get.centers(hub,"99.8%") %$% points(mx,my,col="red")
#我们的探测器主要是捡小物件。添加模糊结果
plot(hub)
isoblur(hub,5) %>% get.centers("99.8%") %$% points(mx,my,col="red")

#探测器现在只拾取大对象。如果我们想检测各种规模的物体呢？
# 该解决方案是汇总的结果超过规模，这是多尺度方法做。
#计算行列式的规模“尺度”
hessdet <- function(im,scale=1) isoblur(im,scale) %>% 
  imhessian %$% { scale^2*(xx*yy - xy^2) }
#注意尺度(scale^2)的决定因素
plot(hessdet(hub,1),main="Determinant of the Hessian at scale 1")

#在不同尺度下的结果看，我们可以用ggplot：
#Get a data.frame with results at scale 2, 3 and 4
dat <- ldply(c(2,3,4),function(scale) hessdet(hub,scale) %>% 
               as.data.frame %>% 
               mutate(scale=scale))
p <- ggplot(dat,aes(x,y))+geom_raster(aes(fill=value))+facet_wrap(~ scale)
p+scale_x_continuous(expand=c(0,0))+scale_y_continuous(expand=c(0,0),trans=scales::reverse_trans())

#尺度空间理论表明，我们寻找斑点跨尺度。这很容易：
scales <- seq(2,20,l=10)

d.max <- llply(scales,function(scale) hessdet(hub,scale)) %>% parmax
plot(d.max,main="Point-wise maximum across scales")

#parmax的另一个例子是一个还原功能，一个为每个像素在所有尺度上的最大值。
# 找出哪些表具有point-wise的极大值点，我们可以用which.parmax：
i.max <- llply(scales,function(scale) hessdet(hub,scale)) %>% which.parmax
plot(i.max,main="Index of the point-wise maximum \n across scales")

#到目前为止，这不是太翔实。一旦我们有了标记区域：
#Get a data.frame of labelled regions
labs <- d.max %>% threshold("96%") %>% label %>% as.data.frame
#Add scale indices
labs <- mutate(labs,index=as.data.frame(i.max)$value)

regs <- dplyr::group_by(labs,value) %>% 
  dplyr::summarise(mx=mean(x),my=mean(y),scale.index=mean(index))

p <- ggplot(as.data.frame(hub),aes(x,y))+
  geom_raster(aes(fill=value))+
  geom_point(data=regs,aes(mx,my,size=scale.index),pch=2,col="red")

p+scale_fill_gradient(low="black",high="white")+
  scale_x_continuous(expand=c(0,0))+
  scale_y_continuous(expand=c(0,0),trans=scales::reverse_trans())

#结果不完美，存在虚假的点（特别是沿着线缝），但它不是一个坏的开始了代码量小。
# 注意刻度指数是如何跟随实际物体的尺度。































