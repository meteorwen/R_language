


##########
# http://rstudio-pubs-static.s3.amazonaws.com/13823_dbf87ac4114b44f8a4b4fbd2ea5ea162.html
text <- readLines("file.txt", encoding = "UTF-8")  #假设有这么一个文件可供使用
scan("file.txt", what = character(0),encoding ="UTF-8")  #默认设置，每个单词作为字符向量的一个元素
scan("file.txt", what = character(0), sep = "\n",encoding ="UTF-8")  #设置成每一行文本作为向量的一个元素，这类似于readLines
scan("file.txt", what = character(0), sep = ".",encoding ="UTF-8")  #设置成每一句文本作为向量的一个元素
#同样R对象里面的内容也可以写入文本文件中，主要有cat()和writeLines()。
#默认情况下，cat()会将向量里的元素连在一起写入到文件中去，但可以sep参数设置分割符。
cat(text, file = "file.txt", sep = "\n")
writeLines(text, con = "file.txt", sep = "\n", useBytes = F)
##########



###########    数据预处理 生成df
setwd("C:\\Users\\Administrator\\Desktop\\Naive-Bayes-Classifier-master\\Database\\SogouC")

list.files("Sample/")  #文件夹名称
list.files("Sample/C000008/")  #文件夹内文件名称



readpath <- function(path){
read1txt <- function(x){
  require(magrittr)
  require(stringr)
vector <- vector()  
vector <- x %>% 
    readLines(encoding ="UTF-8") %>% 
    paste(collapse="") %>% 
    gsub("　　","",.) 
return(vector)
}
textnames <- list.files(path) 
pathtext <- paste0(path,textnames)
vector <- vector()  
vector <- pathtext %>% 
  t %>% 
  sapply(read1txt)
names(vector) <- NULL
return(vector)
}

ClassList <- read.table("ClassList.txt",encoding = "UTF-8",stringsAsFactors = F) %>% 
  .[,2]

pa <- "Sample/"
path2 <- list.files(pa) %>% 
  paste0("/") %>% 
  t %>% 
  paste0(pa,.) %>% 
  t

df <- data.frame()
v1 <- vector()
v2 <- vector()
for(i in 1:length(path2)){
  v1 <- path2[i] %>% 
    readpath %>% 
    c(v1)
  tep <- list.files(path2[i]) %>% length()
  v2 <- ClassList[i] %>% 
    rep(tep) %>% 
    c(v2)
  df<- data.frame(type=v2,text=v1)
}
write.csv(df,"data.csv")
############################

# 1.读取资料库  
csv <- read.csv("data.csv",stringsAsFactors = FALSE)
mystopwords<- read.table("stopwords_cn.txt",stringsAsFactors=F,encoding = "UTF-8") %>% 
  unlist
  
# 2.数据预处理（中文分词、stopwords处理）  
library(tm)  
#移除数字  
removeNumbers = function(x) { ret = gsub("[0-9０１２３４５６７８９]","",x) }  
sample_words <- lapply(csv$text,removeNumbers)
sample_words <- gsub(pattern="[a-zA-Z]+","",sample_words)
#处理中文分词,此处用到Rwordseg包

wordsegment<- function(x) {
  library(Rwordseg)
  segmentCN(x)
}

sample_words <- lapply(sample_words, wordsegment)


###stopwords处理
###先处理中文分词，再处理stopwords，防止全局替换丢失信息

removeStopWords = function(x,words) {  
  ret = character(0)
  index <- 1
  it_max <- length(x)
  while (index <= it_max) {
    if (length(words[words==x[index]]) <1) ret <- c(ret,x[index])
    index <- index +1
  }
  ret
}
sample_words <- lapply(sample_words, removeStopWords, mystopwords)


# 3.wordcloud展示
#构建语料库
corpus = Corpus(VectorSource(sample_words))
meta(corpus,"cluster") <- csv$type
unique_type <- unique(csv$type)
#建立文档-词条矩阵
(sample_dtm <- DocumentTermMatrix(corpus, control = list(wordLengths = c(2, Inf))))

#install.packages("wordcloud"); ##需要wordcloud包的支持
library(wordcloud);
#不同文档wordcloud对比图
sample_tdm <-  TermDocumentMatrix(corpus, control = list(wordLengths = c(2, Inf)));

tdm_matrix <- as.matrix(sample_tdm);

png(paste("./1",".png", sep = ""), width = 1500, height = 1500 );
comparison.cloud(tdm_matrix,colors=rainbow(ncol(tdm_matrix)));####由于颜色问题，稍作修改
title(main = "sample comparision");
dev.off()

#按分类汇总wordcloud对比图
n <- nrow(csv)
zz1 = 1:n
cluster_matrix<-sapply(unique_type,function(type){
  apply(tdm_matrix[,zz1[csv$type==type]],1,sum)})
png(paste("./2",".png", sep = ""), width = 800, height = 800 )
comparison.cloud(cluster_matrix,colors=brewer.pal(ncol(cluster_matrix),"Paired")) 
##由于颜色分类过少，此处稍作修改
title(main = "sample cluster comparision")
dev.off()


#按各分类画wordcloud
sample.cloud <- function(cluster, maxwords = 100) {
  words <- sample.words[which(csv$type==cluster)]
  allwords <- unlist(words)
  
  wordsfreq <- sort(table(allwords), decreasing = T)
  wordsname <- names(wordsfreq) 
  
  png(paste("./", cluster, ".png", sep = ""), width = 600, height = 600 )
  wordcloud(wordsname, wordsfreq, 
            scale = c(6, 1.5),
            min.freq = 2, max.words = maxwords, 
            colors = rainbow(100))
  title(main = paste("cluster:", cluster))
  dev.off()
}
lapply(unique_type,sample.cloud)# unique(csv$type)

## 4.主题模型分析
library(slam)
summary(col_sums(sample.dtm))
term_tfidf  <- tapply(sample.dtm$v/row_sums( sample.dtm)[ sample.dtm$i],   sample.dtm$j,  mean)*
  log2(nDocs( sample.dtm)/col_sums( sample.dtm  >  0))
summary(term_tfidf)

sample.dtm  <-  sample.dtm[,  term_tfidf  >=  0.1]
sample.dtm  <-  sample.dtm[row_sums(sample.dtm)  >  0,]
##α估计严重小于默认值，这表明Dirichlet分布数据集中于部分数据，文档包括部分主题

library(topicmodels)
k <- 30

SEED <- 2010
sample_TM <-
  list(
    VEM = LDA(sample.dtm, k = k, control = list(seed = SEED)),
    VEM_fixed = LDA(sample.dtm, k = k,control = list(estimate.alpha = FALSE, seed = SEED)),
    Gibbs = LDA(sample.dtm, k = k, method = "Gibbs",control = list(seed = SEED, burnin = 1000,thin = 100, iter = 1000)),
    CTM = CTM(sample.dtm, k = k,control = list(seed = SEED,var = list(tol = 10^-4), em = list(tol = 10^-3)))
  )

sapply(sample_TM[1:2], slot, "alpha")
sapply(sample_TM, function(x) mean(apply(posterior(x)$topics,1, function(z) - sum(z * log(z)))))

# α估计严重小于默认值，这表明Dirichlet分布数据集中于部分数据，文档包括部分主题。
# 数值越高说明主题分布更均匀

#最可能的主题文档
Topic <- topics(sample_TM[["VEM"]], 1)
table(Topic)

#每个Topic前5个Term
Terms <- terms(sample_TM[["VEM"]], 5)

Terms[,1:10]
######### auto中每一篇文章中主题数目
(topics_auto <-topics(sample_TM[["VEM"]])[ grep("auto", csv[[1]]) ])


most_frequent_auto <- which.max(tabulate(topics_auto))

######### 与auto主题最相关的10个词语
terms(sample_TM[["VEM"]], 10)[, most_frequent_auto]

# 5.文本分类、无监督分类（包括系统聚类、KMeans、string kernals）
sample_matrix = as.matrix(sample.dtm)
rownames(sample_matrix) <- csv$type

#KMeans分类
sample_KMeans  <-  kmeans(sample_matrix,  k)
library(clue)
#计算最大共同分类率
cl_agreement(sample_KMeans,  as.cl_partition(csv$type),  "diag")
#string kernals
library("kernlab")
stringkern  <-  stringdot(type  =  "string")
stringC1 <- specc(corpus, 10, kernel=stringkern)
#查看统计效果
table("String  Kernel"=stringC1,  cluster = csv$type )


# 6.文本分类，有监督分类（包括knn、SVM）
# 把数据随机抽取90%作为学习集，剩下10%作为测试集。实际应用中应该进行交叉检验，
# 这里简单起见，只进行一次抽取。
n <- nrow(csv)
set.seed(100)
zz1 <- 1:n
zz2 <- rep(1:k,ceiling(n/k))[1:n] #k <- length(unique(csv$type))
zz2 <- sample(zz2,n)


train <- sample_matrix[zz2<10,]
test <- sample_matrix[zz2==10,]
trainC1 <- as.factor(rownames(train))
#knn分类
library(class)
sample_knnCl  <-  knn(train, test, trainC1)
trueC1 <- as.factor(rownames(test))
#查看预测结果
(nnTable  <-  table("1-NN" = sample_knnCl,  sample =  trueC1))


sum(diag(nnTable))/nrow(test)
#样本集少预测效果是不好
#SVM分类
rownames(train) <- NULL
train <- as.data.frame(train)
train$type <- trainC1
sample_ksvm  <-  ksvm(type~., data=train)
svmCl  <-  predict(sample_ksvm,test)
(svmTable <-table(SVM=svmCl, sample=trueC1))


sum(diag(svmTable))/nrow(test)














