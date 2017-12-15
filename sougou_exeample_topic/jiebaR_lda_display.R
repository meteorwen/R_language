setwd("C:\\Users\\Administrator\\Desktop\\Naive-Bayes-Classifier-master\\Database\\SogouC")
data <- read.csv("data.csv",header=T, stringsAsFactors=F)
######################数字处理##########################

removeNumbers = function(x){
  ret <-gsub("[0-9０１２３４５６７８９]","",x)
}

# 字母处理
removeLetters = function(x){
  rep = gsub(pattern="[a-zA-Z]+","",x)
}
#################################################################
library(magrittr)
sample_words <- lapply(data$text, removeNumbers) %>% 
  unlist %>% 
  lapply(removeLetters) %>% 
  unlist


library(jiebaR)
library(jiebaRD)
wk <- worker(bylines = T,
                 user = "UsrWords.dict",
                 stop_word = "stop_words.utf8") #去停用词

comments_seged <- wk[sample_words] 





library(lda)
corpus <- lexicalize(comments_seged, lower=TRUE)   
#生成稀疏list和corpus$documents文档词频统计和corpus$vocab单词列表
num_topics <- 9 #9个主题
#初始化Params
params <- sample(c(-1, 1), num_topics, replace=TRUE)
poliblog_ratings<- sample(c(-100, 100), length(comments_seged), replace=TRUE)

result <- slda.em(documents=corpus$documents,
                  K=num_topics,
                  vocab=corpus$vocab,
                  num.e.iterations=30,
                  num.m.iterations=12,
                  alpha=1.0, eta=0.1,
                  poliblog_ratings / 100,
                  params,
                  variance=0.25,
                  lambda=1.0,
                  logistic=FALSE,
                  method="sLDA")
############################ display1   ###########################################
# 每个主题以柱状图显示相关词语的前8个词语 
Topics <- apply(top.topic.words(result$topics,8, by.score=TRUE),
                2, paste, collapse=" ")#每个topic重点 排名前8个重复最高的词频

aa=length(Topics)
t=c()
for(i in 1:aa)
{t[i]=paste(i,Topics[i],sep="")}


a=apply(result$document_sums,1,sum)
names(a)<-Topics
p=data.frame(a=Topics,b=a)
p=p[order(p[,2],decreasing=T),]


a1=c()
c=c("a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"
    ,"za","zb","zc","zd")
for(i in 1:aa){
  a1[i]= paste(c[i],p$a[i],sep="")
}

p1=data.frame(a=a1,主题得分=p$b)

library(ggplot2)
ggplot(data=p1, aes(x=a, y=主题得分, fill=主题得分)) +
  geom_bar(colour="black", stat="identity") +
  labs(x = "主题", y = "得分") + ggtitle("文档主题排名顺序")+ coord_flip()
############################ display2   ###########################################
# 每个主题分布前20个是词频最高的词语展现  

Topics <- top.topic.words(result$topics, 20, by.score=TRUE)  #每个主题文档前20个词频统计

a=c()
b=c()
for(i in 1:9)
{
  a=c(a,Topics[,i])
  b=c(b,rep(paste("主题",i,sep=""),20))
}

a = table(a, b)
a = as.matrix(a)
library(wordcloud)

comparison.cloud(a, scale = c(1, 1.5), rot.per = 0.5, colors = brewer.pal(ncol(a), "Dark2"))

#############################      文本分类       ###############################
# 
# 提到文本聚类就要说到r语言的tm包，
# 该包的作用就是生成文本文档矩阵，这个比较方便。但是如果你的文本特征不是词频，tf-IDF，
# 那么他们包就没什么用了。
data <- read.csv("data.csv",header=T, stringsAsFactors=F)
library(tm)
reuters =VCorpus(VectorSource(data$text))

# PlainTextDocument <- function (x = character(0), 
#                                author = character(0), 
#                                datetimestamp = as.POSIXlt(Sys.time(),tz = "GMT"), 
#                                description = character(0), 
#                                heading = character(0), 
#                                id = character(0), 
#                                language = character(0), 
#                                origin = character(0), 
#                                ..., 
#                                meta = NULL, class = NULL) {
#   p <- list(content = as.character(x), 
#             meta = TextDocumentMeta(author,datetimestamp, description, heading, id, language, origin, 
#                                                                ..., meta = meta))
#   class(p) <- unique(c(class, "PlainTextDocument", "TextDocument"))
#   p
# }
# 
# library(Rwordseg)
# cnreader <- function(elem,language,id){
#   require(jiebaR)
#   require(jiebaRD)
#   wk <- worker(bylines = T,
#                     user = "UsrWords.dict",
#                     stop_word = "stop_words.utf8") 
#     words <- wk[elem$content]#进行分词
#     ncon <- paste(words,collapse=" ")#合并分词的结果为新的文档，该文档可为tm正确的识别
#     PlainTextDocument(ncon, id=id,language=language)
# }
# mycop <- VCorpus(VectorSource(data$text),readerControl = list(reader = cnreader))





reuters <- tm_map(reuters, stripWhitespace)  #剔除多余的空白
reuters <- tm_map(reuters,content_transformer(tolower)) #转换为小写

#eg:
inspect(reuters[1:2])   # 查看某几条信息
meta(reuters[[2]])# 查看单个文档元数据
as.character(reuters[[2]])  #查看单个文档内容
lapply(reuters[1:2],as.character)  # 查看多个文档内容




data_stw<- readLines("stop_words.utf8",encoding = "UTF-8") 

reuters=tm_map(reuters,removeWords,data_stw)  #移除停用词

control=list(removePunctuation=T,
             minDocFreq=9,
             wordLengths = c(2, Inf),
             weighting = weightTfIdf,
             language = "UTF-8")

doc.tdm=TermDocumentMatrix(reuters,control)
length(doc.tdm$dimnames$Terms)

tdm_removed=removeSparseTerms(doc.tdm, 0.99) #去除99%的稀疏矩阵
x <- length(tdm_removed$dimnames$Terms)
mat = as.matrix(tdm_removed)####转换成文档矩阵
library(e1071)
classifier = naiveBayes(mat[1:x,], as.factor(data$type[1:x]) )##贝叶斯分类器，训练


predicted = predict(classifier, mat[1:90,]);#预测
A=table(data$type[1:90], predicted)#预测交叉矩阵














































































