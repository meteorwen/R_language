library(rvest)
library(magrittr)
library(stringr)
url_0 <- 'http://xa.58.com/qztech/pn'
df_all <- data.frame()
page_start <- 1
page_end <- 1

urlParse <- function(url, nodes){
  result <- url %>% 
    read_html(encoding = 'utf-8') %>% 
    html_nodes(nodes) %>% 
    html_text() %>% 
    iconv('utf-8', 'gbk', sub = '')
}

# s是将要被解析的字符串，包含了大量“\r\t\n”符号
# con是用于检索的关键字 比如“期望月薪：”
detailParse <- function(s, con){
  s_temp <- s %>% 
    gsub('\r|\n|\t', ' ', .) %>%  # 首先将s中所有的“\r\n\t”替换成空格
    strsplit(' ', fixed = TRUE) %>%  # 利用空格分割上一步得到的字符串，结果是一个含有大量空值的list
    unlist # unlist之后得到一个含有大量空值的字符串向量，赋给s_temp
  
  s_temp <- s_temp[s_temp != ''] # 利用s_temp != ''创建了逻辑向量，并作为索引用于提取s_temp中的非空值
  ids <- grep(con, s_temp) # 根据关键字con在s_temp中做检索，得到包含该con的索引，这个地方奇怪的是如果设置fixed=TRUE反而会出错
  
  if (!identical(ids, integer(0))) { # 因为当检索不到con时 ids会等于integer(0)，所以ids不等于                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      integer(0)时执行以下步骤
    result <- s_temp[ids] %>%  # 以ids为索引提取s_temp中的元素，这个元素就是包含con的元素
      str_replace(con, '') %>%  # 将该元素中的con部分替换为空，比如“期望月薪：面议”变为“面议”
      iconv('utf-8', 'gbk', sub = '') # 处理编码格式的
  } else {
    result <- NA # 如果ids为integer(0)，说明s_temp中没有含有con的元素，也就是这份简历的该字段缺失，赋值为NA
  }
  return(result)
}

for (i in page_start:page_end) {
  Sys.sleep(runif(1,1,2))
  url <- paste(url_0, i, sep = '')
  information <- urlParse(url, 'div.xboxcontent')
  
  name <- urlParse(url, 'span.name')
  title <- urlParse(url, 'dt.w280 a')
  resume_complete <- lapply(information, function(s)detailParse(s, '简历完整度：')) %>% unlist
  hope_job <- lapply(information, function(s)detailParse(s, '期望职位：')) %>% unlist
  area <- lapply(information, function(s)detailParse(s, '求职地区：')) %>% unlist
  salary <- lapply(information, function(s)detailParse(s, '期望月薪：')) %>% unlist
  colleges <- lapply(information, function(s)detailParse(s, '最高学历：')) %>% unlist
  sex1 <- urlParse(url,'dd.w50')
  sex <- sex1[2:length(sex1)]
  age1 <- urlParse(url,'dd.w70')
  age <- age1[2:length(age1)]
  changetime1 <-  urlParse(url,'dd.w90')
  changetime <- changetime1[2:length(changetime1)]
  workage1 <- urlParse(url,'dd.w80') %>%
      lapply(function(x){gsub('\r|\n|\t','', x)}) %>%
      unlist()
  workage <- workage1[seq(4,length(workage1),2)] 
  introduction <- urlParse(url,'p.intr-con')
  degree1 <-  urlParse(url,'dd.w100 ')
  degree <- degree1[2:length(degree1)]
  df <- data.frame(name,sex,age,colleges,degree,title,area,salary,workage,
                   resume_complete,changetime,hope_job,introduction,
                   stringsAsFactors = FALSE)
  df_all <- rbind(df_all,df)
}
  
  write.csv(df_all, 'xa58resume.csv')

#   complete <- urlParse(url, 'p.res-per-info')%>%
#     lapply(function(x){
#       gsub('\t|\r|\n', '', x)
#     }) %>% 
#     unlist() %>%
#     strsplit('：') %>% unlist() 
#   resume_complete <- complete[seq(2, length(complete), 2)]
#   
#   hope_job <- urlParse(page_to_parse, 'li.hope-job span')
#   area <- urlParse(page_to_parse,'li.hope-address span')
#   
#   

#   
  

   
   