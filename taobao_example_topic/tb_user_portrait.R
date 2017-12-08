library(jiebaR)
library(jiebaRD)
library(wordcloud2)
library(magrittr)
############################        keywords          ########################## 
#文件路径
readChineseWords<-function(path){
  rawstring = readLines(path,encoding="UTF-8")
  rawstring = paste0(rawstring,collapse = ' ')
  s <- gsub('\\w','',rawstring,perl = T)
  s <- gsub('[[:punct:]]',' ',s)
  return(s)
}

#url
male_link <- 'https://s.taobao.com/search?q=男'
female_link <- 'https://s.taobao.com/search?q=女'



male_str <- readChineseWords(male_link)
female_str <- readChineseWords(female_link)

#分词1
wk <- worker(bylines = T,
             user = "taobao/UsrWords.dict",
             stop_word = "taobao/stop_words.utf8")


datahandle <- function(x){
  require(magrittr)
  vectors <- vector()
  tep <- vector()
    tep <- x %>% 
    wk[.] %>% 
    unlist %>% 
    table %>% 
    sort(decreasing = TRUE)
  id_del <- tep < 5| nchar(names(tep))<2 
  vectors <- tep[!id_del]
  return(vectors)
}
 
female_words <- female_str %>% datahandle
male_words <- male_str %>% datahandle
wordcloud2(male_words,
           figPath = 'taobao/male.png',
           backgroundColor = 'black',color = 'random-light')
wordcloud2(female_words,
           figPath = 'taobao/female.png',
           backgroundColor = 'black',color = 'random-light')

#分词2
cc <- worker()
new_user_word(cc,'打底裤','n')  #新增新词
male_words <- cc[male_str]
female_words <- cc[female_str]

female_df <- freq(female_words)
male_df <- freq(male_words)
wordcloud2(male_df,figPath = 'male.png',backgroundColor = 'black',color = 'random-light')
wordcloud2(female_df,figPath = 'female.png',backgroundColor = 'black',color = 'random-light')





############################        keywords          ########################## 
library(jiebaR)
library(wordcloud2)

#读取中文并去掉非中文及注音符号
readChineseWords<-function(path){
  rawstring = readLines(path,encoding="UTF-8")
  rawstring = paste0(rawstring,collapse = ' ')
  s <- gsub(' ','',rawstring)
  s <- gsub('\\w','',rawstring,perl = T)
  s <- gsub('[[:punct:]]',' ',s)
  
  return(s)
}

#文件路径
uri <- 'taobao/test.txt'
Rt<-readChineseWords(uri)
Rt<-gsub(' ','',Rt)

#stop.txt为停用词表
words<-worker(stop_word = 'taobao/stops.txt')

#添加新词
new_user_word(words,c('子婴','n','秦始皇','n'))
seg<-segment(Rt,words)

#获取top30的关键字
keys<-worker('keywords',topn=30)
v<-vector_keywords(seg,keys)

#转为data.frame格式
df<-stack(v)
df$ind<-as.numeric(as.character(df$ind))

#生成词云
wordcloud2(df)


############################        topic          ############################  
library(jiebaR)
library(jiebaRD)
library(lda)
library(LDAvis)
setwd("taobao/")

cutter <- worker(bylines = T,stop_word = "./stops.txt")
comments_seg <- cutter["test.txt"]

comments_segged <- readLines(comments_seg,encoding = "UTF-8")
comments <- as.list(comments_segged)
doc.list <- strsplit(as.character(comments),split = " ")

term.table <- table(unlist(doc.list))

term.table <- sort(term.table, decreasing = TRUE)

del <- term.table < 5| nchar(names(term.table)) < 2
term.table <- term.table[!del]
vocab <- names(term.table)

get.terms <- function(x) {
  index <- match(x,vocab)
  index <- index[!is.na(index)]
  rbind(as.integer(index - 1), as.integer(rep(1, length(index))))
}
#将原始list文档，按照分伺后的词频列表，生成对应原始list文档对应的该词语的标号和对应重复次数
documents <- lapply(doc.list, get.terms) #词序(过滤后)+词频  

K <- 8
G <- 5000
alpha <- 0.10
eta <- 0.02

set.seed(357)
fit <- lda.collapsed.gibbs.sampler(documents = documents,
                                   K = K,
                                   vocab = vocab, 
                                   num.iterations = G,
                                   alpha = alpha,
                                   eta = eta,
                                   initial = NULL,
                                   burnin = 0,
                                   compute.log.likelihood = TRUE)

theta <- t(apply(fit$document_sums + alpha, 2, function(x) x/sum(x)))
phi <- t(apply(t(fit$topics) + eta, 2, function(x) x/sum(x)))
term.frequency <- as.integer(term.table)
doc.length <- sapply(documents, function(x) sum(x[2, ]))

json <- createJSON(phi = phi,
                   theta = theta,
                   doc.length = doc.length,
                   vocab = vocab,
                   term.frequency = term.frequency)
serVis(json, out.dir = './vis', open.browser = FALSE)
writeLines(iconv(readLines("./vis/lda.json"), from = "GBK", to = "UTF8"),
           file("./vis/lda.json", encoding="UTF-8"))






# 重点研究k tdm 矩阵
# https://github.com/pnandak/text_mining/blob/master/2013_zhilian_textming/tm_salescv_2013.R
# https://github.com/phenix502/textming

