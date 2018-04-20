rm(list = ls())
library(magrittr)
library(imager)
library(e1071)

read.imags <- function(path = "./") {
  fns <- list.files(path)
  res <- NULL
  for(i in fns) {
    fn <- paste(path, i, sep = "")
    im <- load.image(fn)                               #loading image
    im <- imager::resize(im, size_x = 4096L, size_y = 4096L,       #cut image
                 size_z = 1L, size_c = 1L)
    im <- as.array(im)
    im <- matrix(im, 1,dim(im))
    ifelse(!is.null(res),
           res <- rbind(res, im), res <- im)
  }
  return(res)
}

#读取图片
a.images <- read.imags("./101_ObjectCategories/gerenuk/")
a.label <- rep(0,34)
b.images <- read.imags("./101_ObjectCategories/garfield/")
b.label <- rep(1,34)
images <- rbind(a.images,b.images)
labels <- c(a.label,b.label)




detach("imager")   # http://www.r-china.net/forum.php?mod=viewthread&tid=205


library("EBImage")
rs_df <- data.frame()
for(i in 1:nrow(images))
{
  # Try-catch
  result <- tryCatch({
    # 将图像转成1维向量
    img <- as.numeric(images[i,])
    # 重塑为64x64的图像（ebimage对象）
    img <- Image(img, dim=c(64, 64), colormode = "Grayscale")
    # 调整图像的像素28x28
    img_resized <- EBImage::resize(img, w = 28, h = 28)
    # 获取图像矩阵（应该有另一个功能做得更快，更整洁！）
    img_matrix <- img_resized@.Data
    # 强制转化向量
    img_vector <- as.vector(t(img_matrix))
    # Add label
    label <- labels[i]
    vec <- c(label, img_vector)
    # 在rs_df使用rbind栈
    rs_df <- rbind(rs_df, vec)
    # Print status
    print(paste("Done",i,sep = " "))},
    # 错误函数（只打印错误）
    error = function(e){print(e)})
}


names(rs_df) <- c("label", paste("p", c(1:784)))

# 为再现性设置种子
set.seed(100)

# 混合 df
shuffled <- rs_df[sample(1:nrow(rs_df)),]

# Train-test split
train <- shuffled[1:(nrow(shuffled)-ceiling(nrow(shuffled)*0.3)), ]
test <- shuffled[(nrow(shuffled)-ceiling(nrow(shuffled)*0.3)):nrow(shuffled), ]


train <- data.matrix(train)
train_x <- t(train[, -1]) # as data
train_y <- train[, 1]     # as labels
train_array <- train_x
dim(train_array) <- c(28, 28, 1, ncol(train_x))   # as array 4D

test_x <- t(test[, -1])
test_y <- test[, 1]
test_array <- test_x
dim(test_array) <- c(28, 28, 1, ncol(test_x))

library(mxnet)
data <- mx.symbol.Variable('data')
# 1st convolutional layer卷积层
conv_1 <- mx.symbol.Convolution(data = data, kernel = c(5, 5), num_filter = 20)
tanh_1 <- mx.symbol.Activation(data = conv_1, act_type = "tanh")
pool_1 <- mx.symbol.Pooling(data = tanh_1, pool_type = "max", kernel = c(2, 2), stride = c(2, 2))
# 2nd convolutional layer
conv_2 <- mx.symbol.Convolution(data = pool_1, kernel = c(5, 5), num_filter = 50)
tanh_2 <- mx.symbol.Activation(data = conv_2, act_type = "tanh")
pool_2 <- mx.symbol.Pooling(data=tanh_2, pool_type = "max", kernel = c(2, 2), stride = c(2, 2))
# 1st fully connected layer 全连接层
flatten <- mx.symbol.Flatten(data = pool_2)
fc_1 <- mx.symbol.FullyConnected(data = flatten, num_hidden = 500)
tanh_3 <- mx.symbol.Activation(data = fc_1, act_type = "tanh")
# 2nd fully connected layer
fc_2 <- mx.symbol.FullyConnected(data = tanh_3, num_hidden = 40)
# Output. Softmax output since we'd like to get some probabilities.输出因为我们希望得到一些概率。
NN_model <- mx.symbol.SoftmaxOutput(data = fc_2)

mx.set.seed(100)

# Device used. CPU in my case.装置的使用。CPU的案例。
devices <- mx.cpu()

# Training
#-------------------------------------------------------------------------------

# Train the model
model <- mx.model.FeedForward.create(NN_model,
                                     X = train_array,
                                     y = train_y,
                                     ctx = devices,
                                     num.round = 208,           #训练次数
                                     array.batch.size = 40,     #数组批大小
                                     learning.rate = 0.01,      #学习速率
                                     momentum = 0.9,            #动量
                                     eval.metric = mx.metric.accuracy,
                                     epoch.end.callback = mx.callback.log.train.metric(100))

predicted <- predict(model, test_array)
# Assign labels指定标签
predicted_labels <- max.col(t(predicted)) - 1
# Get accuracy 得到的精度
sum(diag(table(test[, 1], predicted_labels)))/length(test_y)





































