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


http://ziweidongjin.fang.com/?ctm=1.xian.xf_search.lplist.4
http://jinseyuechengwk.fang.com/?ctm=1.xian.xf_search.lplist.3
http://hailunchuntian029.fang.com/?ctm=1.xian.xf_search.lplist.8
http://shanghejun029.fang.com/?ctm=1.xian.xf_search.lplist.10



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

































