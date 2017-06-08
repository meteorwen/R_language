# library(ripa)
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
    im <- resize(im, size_x = 32L, size_y = 32L,       #cut image
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
b.images <- read.imags("./101_ObjectCategories/garfield/")

sam.count <- ceiling(min(nrow(a.images) * 0.8, nrow(b.images) * 0.8))
#训练模型
train.a <- sample(1:nrow(a.images), sam.count, replace = F)
train.b <- sample(1:nrow(b.images), sam.count, replace = F)

data.imags <- rbind(a.images[train.a,], b.images[train.b,])

fit <- svm(data.imags, c(rep(1, length(train.a)), rep(0, length(train.b))),
           probablity = T, cross = 3,
           type = "C-classification", method = "SVM")

summary(fit)

#对测试集分类
a.pred <- predict(fit, a.images[-train.a,])
a.pred <- as.numeric(as.character(a.pred))
prop.table(table(a.pred))


b.pred <- predict(fit, b.images[-train.b,])
b.pred <- as.numeric(as.character(b.pred))
prop.table(table(b.pred))





























