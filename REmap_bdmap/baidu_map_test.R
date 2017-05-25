library(WriteXLS)
library(rjson)
library(RCurl)
library(XLConnect)

keyword <- "小区"
key <- "pE0nfFRVHfva4CuKZ9Su3F71wPiNHOFp" ### 请前往此处申请key: http://lbsyun.baidu.com/apiconsole/key?application=key
city <-"西安"
page_size <- 20
page_num <- 0
total <- 30
placeIDSet = name = lat = lng = address = telephone =NULL

while(page_num <= ceiling(total/page_size)-1){
  
  searchURL = paste("http://api.map.baidu.com/place/v2/search?q=",
                    keyword,
                    "&scope=",1,
                    "&page_num=",page_num,
                    "&page_size=",page_size,
                    "&region=",city,
                    "&output=json",
                    "&ak=",key,
                    sep="")
  result = getURL(url = searchURL,ssl.verifypeer = FALSE)
  
  x = fromJSON(result)
  total = x$total
  cat("Retrieving",page_num+1,"from total",ceiling(total/page_size),"pages ...\n")
  page_num = page_num + 1
  
  placeIDSet = c(placeIDSet,
                 unlist(lapply(X = x$results,FUN = function(x)return(x$uid))))
  name = c(name,
           unlist(lapply(X = x$results,FUN = function(x)return(x$name))))
  lat = c(lat,
          unlist(lapply(X = x$results,FUN = function(x)return(x$location$lat))))
  lng = c(lng,
          unlist(lapply(X = x$results,FUN = function(x)return(x$location$lng))))
  address = c(address,
              unlist(lapply(X = x$results,FUN = function(x)return(x$address))))
  telephone = c(telephone,
              unlist(lapply(X = x$results,FUN = function(x)return(x$telephone))))
}

dt <- data.frame(name,lng,lat,address,telephone)
---------------------------------------------------------------------------------------------------
conn <- loadWorkbook('daxue.xlsx',create=TRUE) 
createSheet(conn,name='data')
writeWorksheet(conn,dat,'data',startRow=1,startCol=1,header=TRUE)
saveWorkbook(conn)
WriteXLS(x = "dat",ExcelFileName = "searchResult-baidu.xlsx")

---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

AK <- "pE0nfFRVHfva4CuKZ9Su3F71wPiNHOFp"

# 载入需要的文件
add <- read.csv("add.csv")
#####自定义部分-end#####
add <- c('新旅城','盛方科技园','咸阳市财富中心')

#####自动运行-begin#####
#载入需要的包
library(rjson)
library(RCurl)

#建立网址列表
add_id <- add

#设定空向量
baidu_lat <- c()
baidu_lng <- c()
baidu_address <-c()
baidu_geo <- c()
#列表循环-begin#

for (location in add_id) {
  #建立地址转换网址
  url <- paste("http://api.map.baidu.com/geocoder/v2/?ak=",AK,"&output=json&address=",location, sep = "")
  url_string <- URLencode(url)
  
  # 捕获连接对象
  connect <- url(url_string)
  
  # 处理json对象
  temp_geo <- fromJSON(paste(readLines(connect,warn = F), collapse = ""))
  temp_lat<-temp_geo$result$location$lat
  temp_lng<-temp_geo$result$location$lng
  
  baidu_geo  <-c(baidu_geo,temp_geo)
  baidu_lat <- c(baidu_lat,temp_lat)
  baidu_lng <- c(baidu_lng,temp_lng)
  address <- c(address,location)
}
#列表循环-end#
content <- data.frame(address,baidu_lat,baidu_lng)
#####自动运行-end#####

#查看数据
content

---------------------------------------------------------------------------------------------
library(baidumap)
library(REmap)    #数据可视化包
library(devtools)
#install baidumap package must install this package first:   mapproj   geosphere     proto
install_github('badbye/baidumap')
#install REmap package must install this package first: htmltools  
install_github('lchiffon/REmap')


#地图显示以影子为中心全国大学
thinkcoo <- data.frame(lon=108.88260,lat=34.23403,name='盛方科技园')
plotdata2<- rbind(thinkcoo,collage_list[1:nrow(collage_list),])
demo <- data.frame(origin='盛方科技园',destination=collage_list$name)
remapB(markLineData = demo,geoData = plotdata2)
getCoordinate(c('盛方科技园'), formatted = T)
































