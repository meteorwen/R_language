##----向量区间划分，标记标签并自增+1
## 期望结果：
# dd	tip
# 01	1
# 02	1
# 03	1
# 04	1
# 06	1
# 07	2
# 08	2
# 09	2
# 10	2
# 11	2
# 12	2
# 01	3
# 02	3
# 04	3
# 05	3
# 06	3
# 07	4
# 08	4


## vector_insert_newtags
dd = c("01", "02", "03", "04", "06", "07", "08", "09", "10", "11", "12", 
       "01", "02", "04", "05", "06", "07", "08")    #数据集

tag <- dd %in% c("01", "02", "03", "04", "05", "06")  #区间范围，转逻辑向量

dif <- c(0, diff(tag)) #因为是间隔，所以需要新增一位

tags <- vector()
count <- 1
for(i in 1:length(dif)) {
  # print(dif[i])
  if(dif[i]!= 0) {       #条件如果不等于0，则count+1
    count = count + 1
  }
  tags[i] = count
}
print(tags)


#---------------------------------- method2--------------------------------------
library(stringr)
(match <- dd %in% stringr::str_pad(c(1:6), 2, side = "left", pad = "0"))  
#创建目标区间做对比，得到一个逻辑向量
#str_pad函数以左边填充0，保证了2位数
(times <- c(0, which(match[-length(match)] != match[-1]), length(dd)) %>% diff())
# 分别去掉逻辑向量第一位和最后一位，得到2个逻辑向量做比较，比对出第几位的不同。
# 第一位补0和整个逻辑向量长度，得到一个间位向量，得到一个每个间位上的计数。
(output <- data.frame(dd, tip = rep(1:length(times),times)))

















