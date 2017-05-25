rm(list=ls())
library(magrittr)
library(lubridate)
test <- read.csv("htcro.csv",header = TRUE,sep = ",")
user <- as.data.frame(test)
id <- as.character(user$身份证号)
# nchar(id) == 18 #符合18位的索引
# id[nchar(id) == 18]
# id[nchar(id) != 18]
#1、去除不满足18身份证号的用户
user1 <- user[nchar(id) == 18,]#符合18位要求身份，用户详情
#2、去除身份证乱填写的号码
# 将计算逻辑编写为函数，输入单个字符串，返回是否有效的逻辑值.验证身份真伪
idno_verify <- function(x){
  id_str <- substring(x, 1:18, 1:18)
  id17 <- as.numeric(id_str[-18])
  id_18 <- id_str[18]
  w <- 2^(17:1)
  remainder <- sum(id17 * w) %% 11
  check_code <- c(1, 0, "X", 9, 8, 7, 6, 5, 4, 3, 2)
  
  # 返回计算结果为 TRUE 或 FALSE
  return(id_18 == check_code[remainder+1])
}
# 因为在处理每个子元素中间过程会生成多个元素的向量，故而这里需要用向量化的函数 sapply 
# sapply(user1$身份证号, idno_verify, USE.NAMES = FALSE)
user2 <- user1[sapply(user1$身份证号, idno_verify, USE.NAMES = FALSE),] #得到验证身份证号后的用户详情
#计算年龄
birthday <- substr(user2$身份证号,7,14)
birthday <- as.Date(as.character(birthday),"%Y%m%d")
age <- year(Sys.Date())-year(birthday)
# sort(age) 排序
#计算性别
sex <- substr(user2$身份证号,17,17)
sex <- as.numeric(sex)
sex1 <- NULL
for (i in 1:length(sex)){
  if(sex[i]%%2 == 0){
    sex1[i] <- "女"
  }else{
    sex1[i] <- "男"
  }
}
user2[,2] <- sex1
user2[,3] <- age
user_new <- user2

index <- duplicated(user_new$身份证号)
card_id <- user_new[!index,][,4]
basis <- user_new[!index,][,c(1:4)]

t1<-Sys.time()
t1
##################################################################################################
phone <- NULL
area <- NULL
position <- NULL
project <- NULL
for (i in 1:100){
  print(i)
  user_new[card_id[i] == user_new[,4],]
  #电话去重、去空值、合并号码
  phone[i]  <- unique(unlist(user_new[card_id[i] == user_new[,4],c(5:6)])) %>%  #去重电话
    .[!. == ""] %>%                                                             #去除空值
    paste(.,collapse = "/")                                                     #合并电话号码
  #地址去重、去空值、合并号码
  area[i] <- unique(user_new[card_id[i] == user_new[,4],7]) %>% 
    .[!. == ""] %>% 
    paste(.,collapse = "/")
  #职位去重、去空值、合并号码
  position[i] <- unique(user_new[card_id[i] == user_new[,4],8]) %>%
    .[!. == ""] %>% 
    paste(.,collapse = "/") 
  #参加项目去重、去空值、合并号码
  project[i]  <- unique(user_new[card_id[i] == user_new[,4],c(9:24)]) %>% 
    .[!. == ""] %>% 
    paste(.,collapse = "/") 
  }
##################################################################################################
t2<-Sys.time()
t2-t1

dt <- data.frame(phone,area,position,project)
tail(dt)
# htcro <- data.frame(basis,dt)
# write.csv(htcro, file = "htcro_final.csv",row.names = T ,fileEncoding = "UTF-8")










i (1:length(card_id)) vector
user_new (1:nrow(user_new)) data.frame

a <- c(1,3,5,7,9)
# b <- c(1:10)
# c <- letters[1:10]
bc <- data.frame(b,c)









# 
# 
# 
# 
# data <- join(card_id,user_new,by="身份证号",type="left",match="all")
# 
# dt1 <-  merge(x = card_id, y = user_new, by = "身份证号", all.x = TRUE)
# res1 <- full_join(card_id, user_new, by=c('身份证号'='身份证号'))
# 
# 
# 
# 
# 
# library(tidyr)
# library(dplyr)
# library(datasets)
# library(plyr)
# library(sqldf)
# 
# 
# 
# data<-join(x,y,by="匹配关键字段",type="left",match="all")
# class(iris)
# iris_df<-tbl_df(iris)
# select(iris_df,Sepal.Length,Petal.Length)   
# merge()
# 
# select(user_new,user_new$身份证号,user_new$姓名,user_new$性别,
#        user_new$年龄,user_new$联系方式一,user_new$联系方式二,user_new$住址,user_new$职业)











