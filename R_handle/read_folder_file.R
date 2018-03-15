###############################    example lapply    ##################################
path <- "dt/"
hz <-  "*.csv"
readff <- function(path,hz){
   list.files(path=path,pattern=hz) %>% 
    paste0(path,.) %>% 
    lapply(., function(x) read_csv(x, col_names = F,na = c("\\N", "NA"))) %>% 
    do.call("rbind", .) %>% 
    return()
}
# do.call() 是将list或data.frame告诉一个函数，然后list里的所有元素来执行这个函数。
system.time(
df <- readff(path,hz)
)

###############################    example for    ##################################
Sys.time()    #当前系统时间 
setwd("D:/Workspace/Rsession/dt/")
path <- "dt/"
hz <-  "*.csv"
readf <- function(pa,hz){
  dir <- list.files(path = path,pattern=hz)
  require(readr)
  require(magrittr)
  df <- data.frame()
  for(i in 1:length(dir)){
  df <-  paste0(path,dir[i]) %>% 
    read_csv(.,col_names = F,na = c("\\N", "NA")) %>% 
    rbind(df,.)
  }
  return(df)
}
df <- readf(path,hz)

readf1 <- function(pa,hz){
  dir <- list.files(path = path,pattern=hz)
  require(readr)
  require(magrittr)
  df <- data.frame()
  for(i in dir){
    df <-  paste0(path,i) %>% 
      read_csv(col_names = F,na = c("\\N", "NA")) %>% 
      rbind(df,.)
  }
  return(df)
}
df <- readf1(path,hz)

readf2 <- function(pa,hz){
  dir <- list.files(path = path,pattern=hz)
  require(magrittr)
  df <- data.frame()
  for(i in dir){
    df <-  paste0(path,i) %>% 
      read.csv(header = F,sep = ",",encoding = "UTF-8") %>% 
      rbind(df,.)
  }
  return(df)
}
system.time(
df <- readf2(path,hz)
)

###############################################################################
# 读取文件夹下指定类型文件并做文件合并
#   “*.csv”  
read.csv(x,header = F, sep = ",",encoding = "UTF-8")
library(readr)
read_csv(x, col_names = F,na = c("", "NA")
#   ".txt"
read.table(x,header = FALSE, sep = "")
read_delim(file, delim, quote = "\"", escape_backslash = FALSE,
           escape_double = TRUE, col_names = TRUE, col_types = NULL,
           locale = default_locale(), na = c("", "NA"), quoted_na = TRUE,
           comment = "", trim_ws = FALSE, skip = 0, n_max = Inf,
           guess_max = min(1000, n_max), progress = show_progress())
#   "*.xlsx" "*.xls" 
library(readxl)
readxl_example()
read_excel(xls_example)
excel_sheets(xlsx_example)
read_excel(xlsx_example, sheet = "chickwts")        #指定sheet读取
read_excel(xls_example, sheet = 4)
read_excel(xlsx_example, range = cell_cols("B:D"))  #指定列读取
read_excel(xlsx_example, range = cell_rows(1:4))    #指定行读取
read_excel(xlsx_example, range = "C1:E4")           #指定区间读取
read_excel(xlsx_example, range = "mtcars!B1:D5")    #指定sheet+区间

read_excel(xlsx_example, na = "setosa")            #指定不需要的列赋值为NA

l <- list(iris = iris, mtcars = mtcars, chickwts = chickwts, quakes = quakes)
openxlsx::write.xlsx(l, file = "inst/extdata/datasets.xlsx")



