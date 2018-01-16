

# get appid in spark 
require(stringr)
require(magrittr)
lab <- "Submitted application application_"
ss <- spark_log(sc, n = 10000) %>% 
  as.vector() 
id <- grep(lab,ss)
appid <- ss[id] %>% 
  strsplit( " ") %>% 
  unlist %>% 
  tail(1)
print(appid)
return(appid)