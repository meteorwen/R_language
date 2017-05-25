rm(list=ls())

library(data.table)
library(dplyr)
users <- read.csv("htcro.csv",header = TRUE,sep = ",",stringsAsFactors = FALSE) %>% 
  as.data.table() %>% 
  rename(.,
         name=姓名,sex=性别,age=年龄,id=身份证号,
         phone1=联系方式一,phone2=联系方式二,address=住址,
         job=职业) %>% 
  select(.,name,id,phone1,phone2,address,job) 
users <- users[order(-id)] %>% as.data.frame()
  
#计算身份证有效性函数
idno_verify <- function(x){
  id_str <- substring(x, 1:18, 1:18)
  id17 <- as.numeric(id_str[-18])
  id_18 <- id_str[18]
  w <- 2^(17:1)
  remainder <- sum(id17 * w) %% 11
  check_code <- c(1, 0, "X",9, 8, 7, 6, 5, 4, 3, 2)
  return(id_18 == check_code[remainder+1])
}
#计算身份证性别函数
# bfunc<-function(id){
#   if(nchar(id)==15)
#     ifelse(as.numeric(substr(id,15,15)) %% 2 ==1,'M','F')
#   else
#     ifelse(as.numeric(substr(id,17,17)) %% 2 ==1,'M','F')
# }

user_1 <- users %>% 
  filter(nchar(users$id) == 18)  %>% # same as  # users[nchar(users$id) == 18,]
  filter(sapply(.$id, idno_verify, USE.NAMES = FALSE)) %>% 
  distinct(id,.keep_all = TRUE)





sex <- substr(user_1$id,17,17) %>% 
  as.numeric() 

aga <- as.Date(Sys.time()) %>% 
  format(.,format = "%Y") %>%              #use format function retain year
  as.numeric(.) - substr(user_1$id,7,10) %>% 
  as.numeric(.)

user_2 <- mutate(user_1,
                 sex = ifelse(sex%%2==0,'女','男'),
                 aga = aga) %>% as.data.table() 

id <- user_2[,2] %>% unlist()    #need vector

phone <- users[,c('id','phone1','phone2')] %>%  as.data.frame()  #使用 .() 或者 list() 都可以
# phone <- select(users,c(id,phone1,phone2)) %>%  as.data.frame()

phone_etl <- function(i)  {
 ph <- phone[id[i] == phone[,1],c(2:3)] %>% 
       unlist(.) %>% 
       unique(.) %>% 
       .[!. == ""] %>%                                                           
       paste(.,collapse = "/") 
return(ph)
}
address_etl <- function(i)  {
  ph <- users[id[i] == users[,2],5] %>%       #need data.frame cannot table.frame
    unlist(.) %>% 
    unique(.) %>% 
    .[!. == ""] %>%                                                           
    paste(.,collapse = "/") 
  return(ph)
}
job_etl <- function(i)  {
  ph <- users[id[i] == users[,2],6] %>%       
    unlist(.) %>% 
    unique(.) %>% 
    .[!. == ""] %>%                                                           
    paste(.,collapse = "/") 
  return(ph)
}

t1<-Sys.time()
t1
phone_all <- sapply(c(1:length(id)),phone_etl)
address_all <- sapply(c(1:length(id)),address_etl)
job_all <- sapply(c(1:length(id)),job_etl)
t2<-Sys.time()
t2-t1

user_all <- data.frame(name = user_2[,1],
                       id = user_2[,2],
                       phone = phone_all,
                       address = address_all,
                       job = job_all)



for (i in 1:1000){
  print (i)
  phone[i] <- phone_etl(i)
}








