rm(list = ls())
library(magrittr)
library(rvest)
library(R.utils)
library(stringr)

url <- 'http://transcoder.tradaquan.com/tc?srd=1&dict=32&h5ad=1&bdenc=1&lid=1695437387546441682&title=阴阳刺青师最新章节%7C精校无错%7C无弹窗%7C墨大先生出品-...&nsrc=IlPT2AEptyoA_yixCFOxXnANedT62v3IGti2LC6L3j3volqvbePqXdNpX8KhVmyXE5P7u7nDtRg2wHCb3mRU'


#返回为网页名称
names <- url %>%  read_html(encoding = 'gbk') %>% 
                  html_nodes("li") %>% 
                  html_text(trim = TRUE) %>% 
                  .[1:688]  
#返回为网页地址
urls <- url %>% 
  read_html(encoding = 'gbk') %>% 
  html_nodes("li a") %>% 
  html_attr("href") %>% 
  .[1:688]

dt <- data.frame(names = names,urls =urls,stringsAsFactors=FALSE)

length(dt$urls)

name <- dt$urls[1] %>%  
  read_html(encoding = 'gbk') %>% 
  html_nodes("div.nr_title") %>% 
  html_text(trim = TRUE)


data <- dt$urls[2] %>%  
  read_html(encoding = 'gbk') %>% 
  html_nodes("div.nr_nr") %>% 
  html_text(trim = TRUE) %>% 
  gsub('\u00A0|\t|\r|\n', '',.)
--------------------------------------------------------------
#这部分是重点，调用rvest包里面的函数
fun <- function(x){
  return(x %>%  
           read_html(encoding = 'gbk') %>% 
           html_nodes("div.nr_nr") %>% 
           html_text(trim = TRUE) %>% 
           gsub('\u00A0|\t|\r|\n', '',.))
}

all <- dt$urls[1:20] %>% 
  sapply(fun) %>% 
  unlist()
-------------------------------------------------------------------
#以循环的方式遍历：注意循环的起始，建议第一种
aa <- NULL
for(i in 1:200){
  print(i)
  # Sys.sleep(runif(1,1,2))
  aa[i] <- dt$urls[i] %>% fun()
}
#循环遍历以向量的是形式
aa <- NULL
for(i in dt$urls[1:200]){
  print(i)
  # Sys.sleep(runif(1,1,2))
  aa[i] <- i %>% fun()
}


#注意自定义主函数，一定需要return 返回值，加入爬虫过程中网页相应问题函数trycatch
main <- function(urls,time_limit){
  result <- NULL
  pb <- txtProgressBar(max = length(urls), style = 3)
    for (url in urls) {
    tryCatch({
      evalWithTimeout(try(result[url] <- fun(url), 
                          silent = TRUE), timeout = time_limit)
    }, error = function(e){
      result[url] <- e
    })
    
    setTxtProgressBar(pb, which(urls == url))
    gc()
    closeAllConnections()
  }
  close(pb)
  return(result)
}
aaaa <- main(dt$urls,2)

ccc <- data.frame(names =names ,data =aaaa)

write.csv(aaaa,'111.csv',row.names = FALSE,fileEncoding = "gbk")



