library(rvest)
library(R.utils)
library(stringr)
---------------------------------------------------------------------------------------
#处理单网页单标签
url <- 'http://newhouse.xian.fang.com/house/s/b91'
fun <- function(x){                     #x为网页地址，传参数
  return(x %>% 
      read_html(encoding = 'gbk') %>% 
      html_nodes('div.notice') %>%   #指定标签
      html_text(trim = TRUE) %>% 
        gsub('\t|\r|\n', '',.)
  )
}
test1 <- url %>% fun()

url %>% read_html(encoding = 'gbk') -> t
t1 <- 'http://newhouse.xian.fang.com/house/s/b96' %>% 
  read_html(encoding = 'gbk')
t1 %>% 
  html_nodes("div.kanesf|div.nhouse_price") %>%   #指定标签div.kanesf
  html_text(trim = TRUE) %>% 
  gsub('\t|\r|\n', '',.)


---------------------------------------------------------------------------------------
# 处理单网页、多标签
nodes <- c('div.nlcd_name',
           'div.house_type',
           'div.relative_message',
           'div.nhouse_price')

url_Parse <- function(url,nodes){
  parsed_url <- read_html(url, encoding = 'gbk')   #读取单网页，常量
  temp  <- lapply(nodes, function(node){
          parsed_url %>% 
            html_nodes(node) %>% 
            html_text(trim = TRUE) %>% 
            gsub('\t|\r|\n', '',.)
            })
  result <- data.frame(name =temp[[1]],
                       type =temp[[2]],
                       message =temp[[3]],
                       price = temp[[4]])
  return(result)
  
} 

test2 <- url %>% urlParse(nodes) 



---------------------------------------------------------------------------------------
# 处理多网页、多标签
urls <- paste0('http://newhouse.xian.fang.com/house/s/b9', 
               c(2:36))
#简单应用循环解决

for(url in urls){

  result[url, ] <- urlParse(url, nodes)
}



result <- data.frame()
for(url in urls){
  result <- rbind(result,url_Parse(url,nodes))
}

#加入了tryCatch函数$
urls_Parse <- function(urls, nodes, time_limit){
  result <- data.frame()
  
  pb <- txtProgressBar(max = length(urls), style = 3)   #显示进度
  
  for (url in urls) {
    tryCatch({
      evalWithTimeout(try(result[url, ] <- urlParse(url, nodes), 
                          silent = TRUE), timeout = time_limit)
    }, error = function(e){
      result[url, ] <- e
    })
    
    setTxtProgressBar(pb, which(urls == url))
    gc()
    closeAllConnections()
  }
  
  close(pb)
  return(result)
}

test3 <-  urls_Parse(urls, nodes,time_limit = 2)





--------------------------------------------------------------------------------------
#抓取所房产地址链接，约合650个房产源
--------------------------------------------------------------------------------------
library(rvest)
library(R.utils)
library(stringr)

url <- 'http://newhouse.xian.fang.com/house/s/b9'
urls <- paste0(url,c(12,19,25))

fun <- function(x){
  return(x %>% 
           read_html(encoding = 'gbk') %>% 
           html_nodes('div.clearfix div.nlc_img a') %>%  
           html_attr("href"))
}

pb <- txtProgressBar(max = length(urls), style = 3)  
result <- vector()
for(i in 1:length(urls)){
  tryCatch({
    evalWithTimeout(try(result <- c(result,fun(urls[i])), 
                        silent = TRUE), timeout = 2)
  }, error = function(e){
    result <- c(result,e)
  })
  setTxtProgressBar(pb,  i)
  gc()
  closeAllConnections()
}
a #获取所有房产所有地址
close(pb)

write.csv(a,"fang.csv")
--------------------------------------------------------------------------------------------------
#提取各个链接的地址内的详细信息 test 查询标签测试
--------------------------------------------------------------------------------------------------
uu <- 'http://jingyinghuiqj.fang.com/'
c('div.fixnav_tit h2',                #name
  'div.tit a',                        #score
  'div.advice_left',                 #phone
  'div.wai p',                        #dynamic 
  'div.information_li div.inf_left')  #detail
  uu %>% 
read_html(encoding = 'gbk') -> t
t %>% 
  html_nodes('div.advice_left') %>%   #指定标签
  html_text() %>% 
  gsub('\t|\r|\n', '',.) %>% 
  paste(collapse=";")   #向量字符串合并为一个



nodes <- c('div.fixnav_tit h2',                #name
           'div.tit a',                        #score
           'div.advice_left',                 #phone
           'div.wai p',                        #dynamic 
           'div.information_li div.inf_left')  #detail



url <- 'http://jingyinghuiqj.fang.com/'
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
#单网页，多标签自定义函数
url_Parse <- function(url,nodes){
  parsed_url <- read_html(url, encoding = 'gbk')   #读取单网页，常量
  temp  <- lapply(nodes, function(node){
    parsed_url %>% 
      html_nodes(node) %>% 
      html_text() %>% 
      gsub('\U00A0|\U2002|\t|\r|\n|', '',.) %>% 
      paste(collapse=";") 
  })

  result <- data.frame(name = temp[[1]],
                       score = temp[[2]],
                       phone = temp[[3]],
                       dynamic = temp[[4]],
                       detail = temp[[5]],
                       stringsAsFactors=FALSE)
  return(result)
}

#多网页多标签自定义函数
urls_Parse <- function(urls, nodes, time_limit){
  result <- matrix(NA, nrow = length(urls), ncol = 1 + length(nodes), 
                   dimnames = list(urls, c('id','name','score','phone','dynamic','detail'))) %>% 
    as.data.frame()  #分配内存指定
  
  pb <- txtProgressBar(max = length(urls), style = 3)   #显示进度
  
  for (url in urls) {
    tryCatch({
      evalWithTimeout(try(result[url, ] <- url_Parse(url, nodes), 
                          silent = TRUE), timeout = time_limit)
    }, error = function(e){
      result[url, ] <- e
    })
    
    setTxtProgressBar(pb, which(urls == url))
    gc()
    closeAllConnections()
  }
  
  close(pb)
  return(result)
}
-------------------------------------------------------------------------------------------------
test <-  urls_Parse(urls, nodes,time_limit = 0.5)

















































