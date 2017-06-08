library("EBImage")
library(dplyr)

Image <- readImage('./pic/image.jpg')

display(Image,method="raster")  #open it with rstudio
display(Image)    #open it with web
#给图像添加文本，在图像左上角位置处，（20,20）的地方添加label=Parrots,
#col设置颜色，cex设置字体大小。
text(x = 20,y = 20,label = "dsg",adj = c(0,1),col = "red",cex = 3)

#将其保存，jpeg格式，文件名为filename变量中的字符串，宽度为dim(img)[1]像素，
# 高度为dim(img)[2])像素。
dev.print(jpeg, filename = "./pic/Image_test.jpg" ,
          width = dim(Image)[1],height = dim(Image)[2])
writeImage(Image, "test.jpeg", quality = 85)
image_test <- readImage('./pic/Image_test.jpg')
file.info("./pic/Image_test.jpg")$size##文件的字节大小
file.info("./pic/image.jpg")$size

Image1 <- Image + 0.2
Image2 <- Image - 0.2
display(Image1) 
display(Image2)

Image3 <- Image * 0.5
Image4 <- Image * 2
display(Image3); display(Image4)

Image5 <- Image ^ 2
Image6 <- Image ^ 0.7
display(Image5); display(Image6)

display(Image[100:300, 100:250,])     #裁剪图片

Imagetr <- translate(rotate(Image, 45), c(50, 0))  #旋转图片
display(Imagetr)

colorMode(Image) <- Grayscale
print(Image)
colorMode(Image) <- Color

#过滤
# 我们将使用低通滤波器进行平滑/模糊，并使用高通滤波器的边缘检测。
# 此外，我们亦会研究中值滤波器以消除噪音
fLow <- makeBrush(21, shape= 'disc', step=FALSE)^2
fLow <- fLow/sum(fLow)
Image.fLow <- filter2(Image, fLow)
display(Image.fLow)


# 提取轮廓
fHigh <- matrix(1, nc = 3, nr = 3)
fHigh[2, 2] <- -8
Image.fHigh <- filter2(Image, fHigh)
display(Image.fHigh)

## 2、噪声处理
test <- readImage("./pic/test1.jpg")
display(test,method="raster")
medFltr <- medianFilter(test, 1.1)
display(medFltr)


imageData(img)[1:3,1:6]
##imageData(img)获取img的像素矩阵，然后读取矩阵的1:3行与1:6列相交的地方。
is.Image( as.array(img) )
##as.array(img) 将img转化成矩阵，就不在是图像类型
hist(img)
range(img)##得出该矩阵的元素范围

################################################################################
################################################################################
################################################################################
# 1 安装EBImage.
# ebimage是R包分布作为BioConductor计划的一部分
# 安装步骤如下：
source("http://bioconductor.org/biocLite.R")
biocLite("EBImage")
library("EBImage")
# 2 Reading, displaying and writing images
# 基本ebimage功能包括阅读，写作，和显示的图像。
# 图像的阅读功能使调用readImage函数，需要输入一个文件名或URL。

f = readImage(system.file("images","sample.png", package="EBImage"))
##获取一个系统文件对象，在文件夹images中，名称会死sample.png，属于EBImage包。

img = readImage(f)
##调用阅读图像函数，将图像读入R中，保存在img。

# ebimage目前支持三种图像文件格式：JPEG，PNG和TIFF。
# 我们刚刚加载的图像可以通过函数显示。



display(img)
##当调用一个交互式的R会话，显示在Web浏览器中JavaScript浏览器打开图像。
# 使用鼠标或键盘快捷键，你可以放大和缩小的图像，平移，并通过多个图像帧周期。



display(img, method="raster")
##给display设置method参数为raster,图像可以绘制在当前设备上。
# 这可以方便地将图像数据与其他绘图功能相结合，例如，添加文本标签。



text(x = 20,y = 20,label = "Parrots",adj = c(0,1),col = "orange",cex = 2)
##给图像添加文本，在图像左上角位置处，（20,20）的地方添加label=Parrots,
# col设置颜色，cex设置字体大小。

# 在R设备显示的图形可以使用基础的R函数dev.print或dev.copy保存。
# 例如，让我们保存图像为JPEG文件并验证其大小的磁盘上。

filename = "parrots.jpg"##设置文件名

dev.print(jpeg, filename = filename ,width = dim(img)[1],height = dim(img)[2])
##将其保存，jpeg格式，文件名为filename变量中的字符串，宽度为dim(img)[1]像素，
# 高度为dim(img)[2])像素。

Dim(x)
#为求起变量的维数，即一个多维向量，有多少行多少列多少层等组成。
# 比如一个二维矩阵，32行11列，则：
# 下图表示img对象数组是768*512的像素矩阵。

file.info(filename)$size
##文件的字节大小

# 彩色图像：
imgcol = readImage(system.file("images", "sample-color.png", package="EBImage"))
display(imgcol)

# 如果一个图像由多个帧组成，它们可以通过指定的函数参数全部显示在一个网格排列中，
# 另all=true. 

# TIFF是最复杂的一种位图文件格式。TIFF是基于标记的文件格式，
# 它广泛地应用于对图像质量要求较高的图像的存储与转换。
# 由于它的结构灵活和包容性大，它已成为图像文件格式的一种标准，
# 绝大多数图像系统都支持这种格式。
# 用Photoshop 编辑的TIFF文件可以保存路径和图层。
nuc = readImage(system.file("images","nuclei.tif", package="EBImage"))
display(nuc, method = "raster",all = TRUE)
##method=raster,表示设置为当前平台显示，all=true，将所有帧显示在同一个平面内。

# 可以将图像保存到使用writeimage函数文件。
# 我们加载的图像是一个PNG文件；如果我们要保存该图像为JPEG文件。
# JPEG格式允许设置一个质量值1和100之间的压缩算法。
# 对writeimage质量参数的默认值是100，这里我们使用一个较小的值，
# 导致更小的文件大小在图像质量降低成本。
writeImage(imgcol, "sample.jpeg", quality = 85)

# 图像数据表示
# 
# ebimage使用特殊的包来图像存储和图像处理。
# 它扩展了R基类的阵列，和所有ebimage函数可以直接调用矩阵和数组。
# 窥视图像对象的内部结构

str(img)

imageData(img)[1:3,1:6]
##imageData(img)获取img的像素矩阵，然后读取矩阵的1:3行与1:6列相交的地方。

is.Image( as.array(img) )
##as.array(img) 将img转化成矩阵，就不在是图像类型

# 可以在直方图中绘制的像素强度的分布，在它们的范围内使用范围函数检查。

hist(img)

range(img)
##得出该矩阵的元素范围
# 这里提供了一个有用的总结图像对象的显示方法，
# 这是调用，我们简单地键入对象的名称就可以。
# 
# img
# 
# Image
# 
# colorMode    : Grayscale ##颜色模式：灰度
# 
# storage.mode : double ##存储模式：双精度
# 
# dim          : 768 512 ##维度
# 
# frames.total : 1 ##帧（全部的）：1
# 
# frames.render: 1 ##帧（提供）：1



###灰度处理

colorMode(imgcol) = Grayscale
##设置其颜色模式为灰度

display(imgcol, method = "raster",all=TRUE)
##三个独立的灰度帧对应的红色，绿色和蓝色通道


# 
# 使用功能信道进行灰度和彩色图像之间的颜色空间转换。
# 它具有一个灵活的接口，它允许转换的模式之间的任何一种方式，
# 并可以用于提取颜色通道。不像colormode，信道变化的图像的像素强度值。
# 
# 彩色到灰度图的转换模式包括以平均在RGB通道，
# 和一个加权亮度保持转换模式更适合展示的目的。
# 
# 红、绿和蓝，模式转换成灰度图像或数组的指定色调的彩色图像。
# 
# 
# 
# 一个便利的RGB功能， 促进一个灰度图像的RGB颜色空间通过复制它在红色，
# 绿色和蓝色通道，这就相当于用设置为RGB模式呼叫频道。当显示时，
# 这个图像看起来与它的灰度级不一样，这是预期的，因为颜色通道之间的信息是相同的。
# 结合三灰度图像到一个单一的RGB图像的使用功能rgbimage。
# 
# 
# 
# Image（）
# 函数可以将一个Ｒ的特征向量或者是数组
# －－由颜色组成的－－表示形式为１６进制或是字符表示形式的，
# 都可以转化成一个图片对象。





colorMat = matrix(rep(c("red","green","#0000ff"), 25), 5,5)
##创建一个数组，rep函数是内容重复函数，将c("red","green", "#0000ff")
# 三个元素进行25次重复。matrix(函数是构建数组，为5行5列



colorImg = Image(colorMat)

colorImg

# Image
# 
# colorMode    : Color
# 
# storage.mode : double
# 
# dim          : 5 5 3
# 
# frames.total : 3
# 
# frames.render: 1



imageData(object)[1:5,1:5,1]


display(colorImg, method = "raster",interpolate=FALSE)
# method = "raster"表示使用当前工具的显示工具。interpolate=FALSE表示插值



作为数字阵列，图像可以方便地操纵任何R的算术运算符。
例如，我们可以产生一个负的图像，用图像的最大值减去图像的所有像素点的值。



img_neg = max(img) - img
# 像素最大值挨个遍历容器进行减法，得到图像的相反颜色。

display( img_neg )
# 展示

# 我们也可以通过增加图像的亮度，通过乘法调整对比度，并通过运算应用伽玛校正。

img_comb = combine(
  img,
  img + 0.3,
  img * 2,
  img ^ 0.5)

# combine：结合，该函数将多个数组结合在一起，img为１帧，img_comb变为四帧。

display(img_comb, all=TRUE,method="raster")
##变为四幅图。每一幅图的亮度不一样
# 此外，我们可以用标准矩阵运算进行分割和阈值图像

img_crop = img[366:749, 58:441]
##取局部

img_thresh = img_crop > .5
##将元素大于0.5的置1为黑色，小于等于的为0，白色

display(img_thresh)
##展示一张二值图片，只有黑白两色。



# 图像移位，而不是使用转置的基函数T，
# 因为transpose可以对彩色以及多帧图像进行空间维度交换

img_t = transpose(img)
##转置函数

display( img_t )

# 空间转换

img_translate = translate(img, c(100,-50))
##将img生成的图像右偏移100像素，上偏移50像素。以图像左上角为（0,0）坐标原点。
display(img_translate)

img_rotate = rotate(img, 30, bg.col = "white")
##中心轴进行平面旋转，30为顺时针旋转30度，bg.col为设置背景色，默认为黑。

display(img_rotate)


# 缩放一个图像到所需的尺寸使用调整大小。如果只提供宽度或高度的一个
# ，则另一个维度是自动计算保持原始纵横比的。

img_resize = resize(img, w=256, h=256)
##重定义大小，w为宽，h为高，单位为像素。
display(img_resize )

img_flip = flip(img)
##flip为图像垂直翻转后的映射

img_flop = flop(img)
##flop为图像水平翻转后的图片

display(combine(img_flip, img_flop), all=TRUE)




# 
# 线性滤波器
# 
# 一个常见的图像预处理步骤是通过平滑的手段去掉噪音以及某些事物。
# 一个直观的方法是定义一个选定了大小且周围每一个像素跟平均值都在邻域内的窗口，
# 将此过程应用到所有的像素后，新的，平滑的图像被获得。从数学上说，这可以表示为
# 
# F(x,y)是像素在（x，y）处的值，N =（2A＋1）2是像素数量平均，F′是新的平滑的图像。
# 
# 更普遍的是，我们可以取代移动平均值的加权平均值，使用一个权重函数W，
# 通常具有最高的值在窗口中点处（S = T = 0），然后对边缘弱化。
# 
# 为方便起见，我们让求和的范围从−∞+∞，即使在实践中的和是有限的和W只有有限个非零的值。
# 事实上，我们可以认为权重函数w为另一幅图像，这种操作也被称为图像F和W的卷积，
# 用符号表示∗。
# 卷积是一种线性的操作在这个意义上，W∗（c1f1 + c2f2）= c1w∗F1 + F2 C2W∗
# 任何两图像的F1、F2和编号C1、C2。
# 
# 在EBImage，二维卷积功能的实现是通过过滤器函数filter2，
# 辅助功能函数makebrush可用于生成的权重函数。
# 事实上，过滤器不直接进行求和公式中指出的。
# 相反，它使用的快速傅立叶变换的方式，是在数学上是等价的，但计算效率更高。



w = makeBrush(size = 31, shape = 'gaussian', sigma = 5)
##makeBrush是EBImage包中带的辅助功能函数，shape=“gaussian”表示满足高斯分布，
# 生成长宽都为31的数组，正态分布函数参数sigma = 5。

plot(w[(nrow(w)+1)/2, ], ylab = "w", xlab = "", cex = 0.7)
##使用第16行的向量元素，该数组每一行的点都满足正态分布。（w[(nrow(w)+1)/2=16）

img_flo = filter2(img, w)
##该函数是过滤函数，w是求得的权，权满足正态分布

display(img_flo)

# 在这里，我们已经使用了宽度为5的sigma的高斯滤波器。
# 其他可用的过滤器形状包括“box”（默认），“disc”，“diamond”和“line”，
# 其中一些内核可以是二进制的.
# 
# 如果滤波后的图像包含多个帧，则将该滤波器分别应用于每个帧。
# 为方便起见，可以将图像平滑使用包装功能gblur进行高斯平滑对滤波尺寸自动
# 调整高斯的sigma.

nuc_gblur = gblur(nuc, sigma = 5)

##这是sigma=5，自动进行高斯分布的调整，代替了
# w = makeBrush(size = 31, shape = 'gaussian', sigma = 5)与
# img_flo = filter2(img, w)这两步。
display(nuc_gblur, all=TRUE )

# 在信号处理中，平滑图像的操作被称为低通滤波。
# 高通滤波是相反的操作，它允许检测边缘和锐化图像。
# 这是可以做到的，例如，使用拉普拉斯滤波器。



fhi = matrix(1, nrow = 3, ncol = 3)

fhi[2, 2] = -8

img_fhi = filter2(img, fhi)##不明白

display(img_fhi)

# Median filter：中值滤波器
# 
# 执行降噪的另一种方法是应用一个中值滤波器，这是一个非线性的技术，
# 而不是在前面的部分中描述的低通卷积滤波器。
# 中值滤波在斑点噪声的情况下是特别有效的，并具有去除噪声的优点，同时保持边缘。
# 
# 本地的中值滤波的工作原理是通过扫描图像数组中的像素，
# 在一个指定窗口大小内，取代每个像素的中位数对其相邻的。
# 这种过滤技术是由EBImage提供的函数中值滤波。我们用统一噪声去腐蚀图像，
# 采用中值滤波重建原图像。





l = length(img)
##求取img二维矩阵的长度，该长度是二维矩阵素偶偶元素个数，次序是竖着排序

n = l/10

pixels = sample(l, n)
##simple函数是随机抽取函数，详解在下文。

img_noisy = img

img_noisy[pixels] = runif(n, min=0, max=1)
##pexels是随机抽取的在0~L范围内的不重复数字，
# 每个数字对应img_noisy的一个标签，然后将该标签下的数字替换成随机数

display(img_noisy)

# R中sample(x, size, replace = FALSE, prob = NULL)
# 命令是从x中随机抽取size大小的样本 replace是否放回抽样，
# prob 设置所要抽取的每个元素被抽取的概率





img_median = medianFilter(img_noisy, 1)
##用中值滤波进行去噪处理，还原清晰

display(img_median)

# 
# 二值图像是包含只有两个像素的图像，与值，说0和1，代表的背景和前景像素。
# 这些图像是受几个非线性形态操作：侵蚀，扩张，开放，和关闭。
# 这些操作通过覆盖面具的工作，称为结构元素，以下面的方式在二进制图像：
# 
# 腐蚀：对于每一个前景像素，把它周围的面具，如果任何一个被面具覆盖的像素是来自背景，
# 那么设置像素到背景。
# 
# dilation: For every background pixel, put the mask around it, 
# and if any pixel covered by the mask is from the foreground, 
# set the pixel to foreground.
# 
# Dilation:扩张；foreground：前景色。
# 余下部分不懂。。。。
# 
# 在“操作图像”部分，我们已经展示了如何在图像上设置一个全局阈值。
# 在那里，我们使用了一个任意的截止值。图像的像素强度分布为双峰直方图更系统的方法，
# 包括利用最大类间方差法。Otsu的方法是一种自动执行基于图像分割的聚类技术。假设一个双峰的强度分布，该算法将图像像素分为前景和背景。通过最小化组合的类内方差确定的最佳阈值。
# 
# Otsu阈值可以使用函数计算法。当被调用的多帧图像时，
# 该阈值被计算为每个帧分别产生在图像中的帧的总的长度等于输出矢量的长度。

threshold = otsu(nuc)##计算阈值，有几帧就计算几个值

threshold





nuc_th = combine( mapply(function(frame, th) frame > th, 
                         getFrames(nuc), threshold, SIMPLIFY=FALSE) )
##getFrames(nuc)获得所有帧的信息。threshold存了每个帧的阈值。
# GetFrames是显示单个帧，分割开的，但是combine将每个帧组合成一幅图。





# Adaptive thresholding：自适应阈值
# 自适应阈值的想法是，相比简单的阈值从前面的部分，
# 允许在不同的区域的图像的阈值是不同的。在这种方式中，
# 一个可以预见的潜在的空间依赖性的底层的背景信号引起的，
# 例如，由不均匀的照明或由附近的明亮的物体的杂散信号。
# 
# 自适应阈值的作品，通过比较每个像素的强度，
# 从一个当地的邻里确定的背景。这可以通过比较图像的平滑版本，
# 其中的过滤窗口是大于我们想要捕获的对象的典型大小。



disc = makeBrush(31, "disc")
disc = disc / sum(disc)
offset = 0.05
nuc_bg = filter2( nuc, disc )
nuc_th = nuc > nuc_bg + offset
display(nuc_th, all=TRUE)

# 这种技术假设的对象是相对稀疏分布的图像中，使在附近的信号分布是占主导地位的背景。
# 而在我们的图像中的核，这个假设是有意义的，因为其他情况下，
# 你可能需要作出不同的假设。用一个矩形框的线性滤波器的自适应阈值设置的阈值，
# 采用更快的实现比直接使用过滤器。

display( thresh(nuc, w=15, h=15, offset=0.05), all=TRUE )


# 9 Image segmentation：图像分割

# 执行图像分割，通常用于识别图像中的对象。
# 非接触连接的对象可以分割使用bwlabel功能进行分割，
# 然而水洗跟分割等使用更复杂的算法能够分离的物体相互接触。
# 
# bwlabel发现每一个背景像素以外的链接，并重新命名这些设置唯一的增长整数。
# 它可以被称为一个二进制图像阈值以提取对象。

logo_label = bwlabel(logo)

table(logo_label)

# 显示图像我们规范到（0,1）所预计的范围内显示功能。
# 这个结果在不同的对象被渲染与一个不同的阴影的灰色。

display( normalize(logo_label) )
##灰度渐变

display( colorLabels(logo_label) )
##色彩渐变，彩色


# Object manipulation

# 对孔的填充，用fillHull()函数

filled_logo = fillHull(logo)
##将空洞之内的进行填充。

display(filled_logo)



rgblogo = toRGB(logo)
##转化成可以显示rgb对象

rgblogo = floodFill(rgblogo, c(50, 50), "red")
#在坐标点c（50,50）处，开始递归寻找邻域，相同的就染同色。

rgblogo = floodFill(rgblogo, c(100, 50), "green")

rgblogo = floodFill(rgblogo, c(150, 50), "blue")

display( rgblogo )





nuc = readImage(system.file('images', 'nuclei.tif', package='EBImage'))

##读取图片

cel = readImage(system.file('images', 'cells.tif', package='EBImage'))

# 读取图片

cells = rgbImage(green=1.5*cel, blue=nuc)
##将两个颜色矩阵结合在一张图，并将指定的矩阵赋予颜色

display(cells, all = TRUE)

segmented = paintObjects(cmask, cells, col='#ff00ff')

segmented = paintObjects(nmask, segmented, col='#ffff00')

display(segmented, all=TRUE)
sessionInfo()
#显示R的所有信息



















