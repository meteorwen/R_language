#----------------------------------   tidyr   -------------------------------------
#----------------------------------   tidyr   -------------------------------------
# 本文将演示tidyr包中下述四个函数的用法：
# 
# gather—宽数据转为长数据。类似于reshape2包中的melt函数
# spread—长数据转为宽数据。类似于reshape2包中的cast函数
# unit—多列合并为一列
# separate—将一列分离为多列
library(tidyr)
mtcars$car <- rownames(mtcars)
mtcars <- mtcars[, c(12, 1:11)]
rownames(mtcars) <- NULL

# gather(data, key, value, ..., na.rm = FALSE, convert = FALSE)
# 这里，...表示需要聚合的指定列。
# 与reshape2包中的melt函数一样，得到如下结果：

mtcarsNew <- mtcars %>% gather(attribute, value, -car)
#除了car列外，其余列聚合成两列，分别命名为attribute和value
head(mtcarsNew)
mtcarsNew <- mtcars %>% gather(attribute, value, mpg:gear)



# spread(data, key, value, fill = NA, convert = FALSE, drop = TRUE)
# 与reshape2包中的cast函数一样，得到如下结果：
mtcarsSpread <- mtcarsNew %>% spread(attribute, value)
head(mtcarsSpread)



# unite(data, col, ..., sep = "_", remove = TRUE)
# ...表示需要合并的列，col表示合并后的列。

set.seed(1)
date <- as.Date('2016-01-01') + 0:14
hour <- sample(1:24, 15)
min <- sample(1:60, 15)
second <- sample(1:60, 15)
event <- sample(letters, 15)
data <- data.frame(date, hour, min, second, event)
data
# 需要把date，hour，min和second列合并为新列datetime。
# 通常，R中的日期时间格式为"Year-Month-Day-Hour:Min:Second"
dataNew <- data %>%
  unite(datehour, date, hour, sep = ' ') %>%
  unite(datetime, datehour, min, second, sep = ':')
dataNew

# separate(data, col, into, sep = "[^[:alnum:]]+", remove = TRUE,
#          convert = FALSE, extra = "warn", fill = "warn", ...)

data1 <- dataNew %>% 
  separate(datetime, c('date', 'time'), sep = ' ') %>% 
  separate(time, c('hour', 'min', 'second'), sep = ':')
data1





#----------------------------    readr     ---------------------------------------
#----------------------------    readr     ---------------------------------------
library(readr)
#   https://blog.rstudio.com/2015/04/09/readr-0-1-0/
# col_logical()[1]，只含有T，F，TRUE或FALSE。
# col_integer() [i]整数。
# col_double() [d]，双打。
# col_euro_double()[e]，“欧元”双倍，,用作小数分隔符。
# col_date() [D]：Ymd日期。
# col_datetime() [T]：ISO8601日期时间
# col_character() [c]，其他一切。


read_csv("iris.csv", col_types = list(
  Sepal.Length = col_double(),
  Sepal.Width = col_double(),
  Petal.Length = col_double(),
  Petal.Width = col_double(),
  Species = col_factor(c("setosa", "versicolor", "virginica"))
))
# 任何省略的列将自动解析，因此以前的调用相当于：
read_csv("iris.csv", col_types = list(
  Species = col_factor(c("setosa", "versicolor", "virginica"))
))

read_delim(col_names = FALSE, na = c("", "NA"), delim = "|",
           col_types = list(col_character(),col_double(),
                            col_character(),ol_integer())) 

# 日期和时间
# readr最有用的功能之一就是能够导入日期和日期。它可以自动识别以下格式：
# 年月日形式：2001-10-20或2010/15/10（或任何非数字分隔符）。
# 它不能自动地以m / d / y或d / m / y格式自动认可日期，因为它们是不明确的：
# 是02/01/20151月2日还是2月1日？
# 
# 日期倍ISO8601形式：例如2001-02-03 04:05:06.07 -0800，20010203 040506，20010203
# 等我并不支持所有可能的变化呢，所以请让我知道，如果它不为你的数据（更详细工作?parse_datetime）。
# 
# 如果你的日期是另一种格式，不要绝望。您可以使用col_date()和col_datetime()显式指定格式字符串。
# Readr实现它自己的strptime()等价物，支持以下格式字符串：

# Year: \%Y (4 digits). \%y (2 digits); 00-69 -> 2000-2069, 70-99 -> 1970-1999.
# 
# Month: \%m (2 digits), \%b (abbreviated name in current locale), \%B (full name in current locale).
# 
# Day: \%d (2 digits), \%e (optional leading space)
# 
# Hour: \%H
# 
# Minutes: \%M
# 
# Seconds: \%S (integer seconds), \%OS (partial seconds)
# 
# Time zone: \%Z (as name, e.g. America/Chicago), \%z (as offset from UTC, e.g. +0800)
# 
# Non-digits: \%. skips one non-digit charcater, \%* skips any number of non-digit characters.
# 
# Shortcuts: \%D = \%m/\%d/\%y, \%F = \%Y-\%m-\%d, \%R = \%H:\%M, \%T = \%H:\%M:\%S, \%x = \%y/\%m/\%d.
parse_date("2015-10-10")
parse_datetime("2015-10-10 15:14")
parse_date("02/01/2015", "%m/%d/%Y")
parse_date("02/01/2015", "%d/%m/%Y")

read_lines()
# 以同样的方式工作readLines()，但是要快很多。

read_file() 
# 将完整的文件读入字符串。

type_convert()
# 试图将所有字符列强制到其适当的类型。
# 如果您需要进行一些手动切换（例如使用正则表达式）将字符串转换为数字，则此功能非常有用。
# 它使用与read_*功能相同的规则。

write_csv()
# 将数据帧写入csv文件。它比write.csv()它更快，它不会写row.names。
# 它也可以以可读取"的方式转义嵌入到字符串中read_csv()。

# 如果解析文件有任何问题，该read_函数会发出警告，告诉您有多少问题。
# 然后，您可以使用该problems()功能来访问提供有关每个问题的信息的数据框架：
csv <- "x,y
1,a
b,2"

df <- read_csv(csv, col_types = "ii")

problems(df)

df






#-------------------------    Lubridate    ----------------------------------------
#-------------------------    Lubridate    ----------------------------------------
#   https://cran.r-project.org/web/packages/lubridate/vignettes/lubridate.html
# 解析日期和时间

# 让R同意您的数据包含您认为的日期和时间可能是棘手的。Lubridate简化了。
# 确定您的日期中显示年，月和日的顺序。现在以相同的顺序排列“y”，“m”和“d”。
# 这是lubridate中解析你的日期的函数的名称。例如，
library(lubridate)
ymd("20110604")
mdy("06-04-2011")
dmy("04/06/2011")

# Lubridate的解析函数处理各种格式和分隔符，从而简化了解析过程。
# 
# 如果您的日期包含时间信息，请将h，m和/或s添加到函数的名称。
# ymd_hms可能是最常见的日期时间格式。要读取某个时区的日期，请在参数中提供该时区的正式名称tz。
arrive <- ymd_hms("2011-06-04 12:00:00", tz = "Pacific/Auckland")
arrive
leave <- ymd_hms("2011-08-10 14:00:00", tz = "Pacific/Auckland")
leave

# 设置和提取信息
# 
# 提取与功能的日期时间信息second，minute，hour，day，wday，yday，week，month，year，和tz。
# 您还可以使用这些设置（即更改）给定的信息。请注意，这将改变日期时间。
# wday并month有一个可选label参数，用数字输出替代工作日或月份的名称。
second(arrive)
second(arrive) <- 25
arrive

second(arrive) <- 0

wday(arrive)   #一周里第几天，星期天为1
wday('2017-08-02')
wday(arrive, label = TRUE)


# 时区
# 
# 与日期和时区有两个非常有用的事情。
# 首先，在不同的时区显示相同的时刻。
# 第二，通过将现有时钟时间与新时区相结合创造新时刻。这些被实现with_tz和force_tz。
# 
# 例如，前一段时间我在新西兰奥克兰。我安排在今天凌晨9点在奥克兰时间的9:00，
# 与哈特利（Haadley）的合着者达成协议。那个回到德克萨斯州休斯顿的哈德利几点？
meeting <- ymd_hms("2011-07-01 09:00:00", tz = "Pacific/Auckland")
with_tz(meeting, "America/Chicago")

# 所以会议发生在哈德利时间4点（和前一天）。
# 当然，这是与新西兰9点相同的实际时刻。由于地球的曲率，它似乎是不同的一天。
# 如果哈德利错误地在他的时间9点登录呢？什么时候会是我的时间？

mistake <- force_tz(meeting, "America/Chicago")
with_tz(mistake, "Pacific/Auckland")


# 时间间隔
# 
# 您可以使用lubridate将间隔时间段保存为Interval类对象。
# 这是非常有用的！例如，我在奥克兰逗留从2011年6月4日到2011年8月10日（我们已经保存到达和离开）。
# 我们可以通过以下两种方法之一创建此间隔：

auckland <- interval(arrive, leave) 
auckland

auckland <- arrive %--% leave
auckland

# 我在奥克兰大学的导师克里斯，参加了当年的各种会议，包括联合统计会议（JSM）。
# 这让他从7月20日直到8月底才出国。
jsm <- interval(ymd(20110720, tz = "Pacific/Auckland"), ymd(20110831, tz = "Pacific/Auckland"))
jsm
int_overlaps(jsm, auckland)  #我的访问是否与他的旅行重叠？是。

setdiff(auckland, jsm)

# 与间隔工作的其他功能包括：
# int_start，int_end，int_flip，int_shift，int_aligns，union，intersect，setdiff，%within%



# 算术与日期时间
# 
# 间隔是具体的时间跨度（因为它们与特定的日期相关），但是也可以提供两个一般的时间跨度类别：
# 持续时间和时间段。辅助功能创建时间以时间单位（复数）命名。
# 用于创建持续时间的辅助功能遵循相同的格式，但以“d”（持续时间）开始，或者如果您愿意，
# 还是“e”（确切地））。

minutes(2) ## period   时间点
dminutes(2) ## duration   时间段

# 为什么两个班？因为时间轴不如数字线那么可靠。持续时间课程将始终提供数学上精确的结果。
# 持续时间总是等于365天。另一方面，时间段的波动与时间线相同，给出直观的结果。
# 这使它们对建模时钟时间有用。例如，面对闰年，持续时间将是诚实的，但时间可能会返回你想要的：

leap_year(2011) ## regular year  定期一年
ymd(20110101) + dyears(1)
ymd(20110101) + years(1)
leap_year(2012)
ymd(20120101) + dyears(1)
ymd(20120101) + years(1)

# 您可以使用期间和持续时间来执行具有日期时间的基本算术。
# 例如，如果我想与Hadley建立一个每周Skype会议的重新建立，它将发生在：
meetings <- meeting + weeks(0:5)
meetings %within% jsm   #哈德利和克里斯同时参加了会议。哪些会议会受到影响？最后两个。

auckland / ddays(1)   #我在奥克兰逗留多久？
auckland / ddays(2)
auckland / dminutes(1)

#可以进行模数和整数除法。有时候这比司更明智 - 
# 由于一个月的长短不断变化，所以表达剩下的一个月是不明显的。
auckland %/% months(1)
auckland %% months(1)
# 具有时间间隔的模数将剩余部分作为新的（较小）间隔返回。
# 您可以将此或任何间隔转换为广义时间跨度as.period。
as.period(auckland %% months(1))


jan31 <- ymd("2013-01-31")
jan31 + months(0:11)

floor_date(jan31, "month") + months(0:11) + days(31)
jan31 %m+% months(0:11)
#请注意，这只会影响算术运算（如果您的开始日期为2月29日，则算术与数年）。

# 矢量
# 
# lubridate中的代码是矢量化的，可以在交互式设置和功能内使用。
# 作为一个例子，我提供一个将日期提前到月的最后一天的功能
last_day <- function(date) {
  ceiling_date(date, "month") - days(1)
}











#----------------------      magrittr      ---------------------------------------
#----------------------      magrittr      ---------------------------------------
# magrittr包，主要定义了4个管道操作符，分另是%>%, %T>%, %$% 和 %<>%。其中，
# 操作符%>%是最常用的，其他3个操作符，与%>%类似，在特殊的使用场景会起到更好的作用。
library(magrittr)
set.seed(1)
n1<-rnorm(10000)            # 第1步
n2<-abs(n1)*50              # 第2步
n3<-matrix(n2,ncol = 100)   # 第3步
n4<-round(rowMeans(n3))     # 第4步
hist(n4%%7)                 # 第5步
hist(round(rowMeans(matrix(abs(rnorm(10000))*50,ncol=100)))%%7)

set.seed(1)
rnorm(10000) %>%
   abs %>% `*` (50)  %>%
   matrix(ncol=100)  %>%
   rowMeans %>% round %>% 
   `%%`(7) %>% hist
## %T>%
# %T>%向左操作符，其实功能和 %>% 基本是一样的，只不过它是把左边的值做为传递的值，
# 而不是右边的值。这种情况的使用场景也是很多的，比如，你在数据处理的中间过程
# ，需要打印输出或图片输出，这时整个过程就会被中断，用向左操作符，就可以解决这样的问题。
# 
# 现实原理如下图所示，使用%T>%把左侧的程序的数据集A传递右侧程序的B函数，
# B函数的结果数据集不再向右侧传递，而是把B左侧的A数据集再次向右传递给C函数，最后完成数据计算。

rnorm(10000) %>%
  abs %>% `*` (50)  %>%
  matrix(ncol=100)  %>%
  rowMeans %>% round %>% 
  `%%`(7) %T>% hist %>% sum

## %$% 解释操作符

set.seed(1)
data.frame(x=1:10,y=rnorm(10),z=letters[1:10]) %$% 
  .[which(x>5),]

data.frame(x=1:10,y=rnorm(10),z=letters[1:10]) %>%  
  .[which(.$x>5),]

set.seed(1)
df<-data.frame(x=1:10,y=rnorm(10),z=letters[1:10])
df[which(df$x>5),]
# 从代码中可以发现，通常的写法是需要定义变量df的，df一共要被显示的使用3次，
# 就是这一点点的改进，会让代码看起来更干净。


##  %<>% 复合赋值操作符

set.seed(1)
x %<>% rnorm(100) %>%  abs %>% sort %>% head(10)
#注意一下 %<>% 必须要用在第一个管道的对象处，才能完成赋值的操作，
#如果不是左侧第一个位置，那么赋值将不起作用。
set.seed(1)
x<-rnorm(100)
x %<>% abs %>% sort %>% head(10)   # 左侧第一个位置，赋值成功
x
x %>% abs %<>% sort %>% head(10)   # 左侧第二个位置，结果被直接打印出来，但是x的值没有变

# %>%符号操作符定义

# extract	                  `[`
# extract2	          `[[`
# inset	                  `[<-`
# inset2	                  `[[<-`
# use_series	          `$`
# add	                  `+`
# subtract	          `-`
# multiply_by	          `*`
# raise_to_power	          `^`
# multiply_by_matrix	  `%*%`
# divide_by	          `/`
# divide_by_int	          `%/%`
# mod	                  `%%`
# is_in	                  `%in%`
# and	                  `&`
# or	                  `|`
# equals	                  `==`
# is_greater_than	          `>`
# is_weakly_greater_than	  `>=`
# is_less_than	          `<`
# is_weakly_less_than	  `<=`
# not (`n'est pas`)	  `!`
# set_colnames	          `colnames<-`
# set_rownames	          `rownames<-`
# set_names	          `names<-`

## eg：
# 使用符号的写法
set.seed(1)
rnorm(10) %>% `*`(5) %>% `+`(5)
set.seed(1)
rnorm(10) %>% multiply_by(5) %>% add(5)

# %>%对代码块的传递
set.seed(1)
     rnorm(10)      %>%
     multiply_by(5) %>%
     add(5)         %>%
     {cat("Mean:", mean(.), 
         "Var:", var(.), "\n")
         sort(.) %>% 
           head}
# 比如，对一个包括10个随机数的向量的先*5再+5，
# 求出向量的均值和标准差，并从小到大排序后返回前5条。
     
# %>%对函数的传递
iris %>%
    (function(x) {
    if (nrow(x) > 2) 
    rbind(head(x, 1), tail(x, 1))
    else x
    })





#-----------------------          stringr         --------------------------------
#-----------------------          stringr         --------------------------------
#    https://cran.r-project.org/web/packages/stringr/vignettes/stringr.html
# 在stringr中有四个主要的功能：
# 1 字符操作：这些功能允许您操纵字符向量内的字符串内的各个字符。
# 2 空白工具添加，删除和处理空格。
# 3 区域设置敏感操作，其操作将因区域设置而异
# 4 模式匹配功能。这些识别出四种引擎的模式描述。最常见的是定期表达，但还有另外三种工具。
library(stringr)
str_length("abc")   #nchar()
#提取指定位置字符串
x <- c("abcdef", "ghifjk")
str_sub(x, 3, 3)
str_sub(x, 2, -1) # The 2nd to 2nd-to-last character,-1为倒是第一
str_sub(x, 3, 3) <- "X"   # 可以使用str_sub()修改字符串
#复制指定位置的字符串的次数
str_dup(x, c(2, 3))    #要复制单个字符串

#补齐字符串的位数，左右两边补充,默认填充是" "
str_pad(string, width, side = c("left", "right", "both"), pad = " ") 
# 通过在左侧，右侧或两侧添加额外的空格来将字符串填充到固定长度。
# 永远不会使字符串更短
x <- c("abc", "defghi")
str_pad(x, 10)
str_pad(x, 10, "both")
str_pad(x, 4)

#所以如果你想确保所有的字符串是相同的长度（通常对打印方法很有用），合并str_pad()和str_trunc()
x <- c("Short", "This is a long string")
#裁剪字符串，左右两边裁剪，默认裁剪后,后三位是用...填充
str_trunc(string, width, side = c("right", "left", "center"),ellipsis = "...")
x %>% 
  str_trunc(10,ellipsis = '') %>% 
  str_pad(15, "right", pad = "$")


# str_trim()，这消除前缘和后空白,默认是两边修剪两边修剪空白
x <- c("  a   ", "b   ",  "   c")
str_trim(x)  #默认both
str_trim(x, "left")

# str_wrap()修改现有的空格，以便包装一段文本，以使每行的长度尽可能相似。
jabberwocky <- str_c(
  "`Twas brillig, and the slithy toves ",
  "did gyre and gimble in the wabe: ",
  "All mimsy were the borogoves, ",
  "and the mome raths outgrabe. ")  #字符串合并成一个
cat(str_wrap(jabberwocky, width = 40))  #将一个字符串按照固定长度分割成若干个，中间以 \n 分隔
cat("1\t2\n3",4,"5        6",7) #打印输出

x <- "I like horses."
str_to_upper(x) #字符串英文字母全大写
str_to_title(x) #字符串英文字母第一个大写
str_to_lower(x) #字符串英文字母全小写
str_to_lower(x, "tr")
stringi::stri_locale_list()

strings <- c(
  "apple", 
  "219 733 8965", 
  "329-293-8753",
  "18182509512",
  "029-33238730",
  "0910 33238730",
  "Work: 579-499-7527; Home: 543.355.3679"
)
######## 正则表达式简单用法  ####################
# () 是为了提取匹配的字符串。表达式中有几个()就有几个相应的匹配字符串。
# (\s*)表示连续空格的字符串。
# []是定义匹配的字符范围。比如 [a-zA-Z0-9] 表示相应位置的字符要匹配英文字符和数字。
# [\s*]表示空格或者*号。
# {}一般用来表示匹配的长度，比如 \s{3} 表示匹配三个空格，\s[1,3]表示匹配一到三个空格。
# (0-9) 匹配 '0-9′ 本身。 [0-9]* 匹配数字（注意后面有 *，可以为空）
# [0-9]+ 匹配数字（注意后面有 +，不可以为空）{1-9} 写法错误。
# [0-9]{0,9} 表示长度为 0 到 9 的数字字符串。


phone <- "([0-9]{3})[- .]([0-9]{3})[- .]([0-9]{4})"
ph <- "([0-9]{11})" #匹配数字0-9长度为11的字符串
ph <- "([a-zA-Z0-9]{11})"
ph <- "([1,8,2,5,0,9]{11})"
str_detect(strings, ph) 
str_detect(strings, phone) 
#str_detect()检测模式的存在或不存在并返回逻辑向量（类似于grepl()）
str_subset(strings, phone)   #★★★
tel <- "([0-9]{3,4})[- ]([0-9]{7,8})"#包含[0-9]的数字3到4位中间连接是空格和-包含数字[0-9]7到8位
str_subset(strings, tel) 
#str_subset()返回匹配正则表达式（类似于字符向量的元素grep()用value = TRUE）

str_count(strings, phone)    ## How many phone numbers in each string

# str_locate()找到一个模式的第一个位置，并返回一个带有开始和结束列的数字矩阵。
# str_locate_all()查找所有匹配项，返回数组矩阵列表。类似于regexpr()和gregexpr()
(loc <- str_locate(strings, phone))
str_locate_all(strings, phone)


# str_extract()提取与第一个匹配相对应的文本，返回一个字符向量。
# str_extract_all()提取所有匹配并返回字符向量列表。
str_extract(strings, phone)    #return vector
str_extract_all(strings, phone)  #return list
str_extract_all(strings, phone, simplify = TRUE) #return df ★★★


# str_match()提取()从第一场比赛形成的捕获组。它返回一个字符矩阵，
#            其中一列用于完整匹配，每个组有一列。
# str_match_all()从所有匹配中提取捕获组，并返回字符矩阵列表。类似regmatches()。
str_match(strings, phone)
str_match_all(strings, phone)

# str_replace()替换第一个匹配的模式并返回一个字符向量。
# str_replace_all()取代所有比赛。类似于sub()和gsub()。
str_replace(strings, phone, "XXX-XXX-XXXX")
str_replace_all(strings, phone, "XXX-XXX-XXXX") #★★


# str_split_fixed()基于模式将字符串分割成固定数量的片段并返回字符矩阵。
# str_split()将字符串分割成可变数量的片段并返回字符向量列表。
str_split("a-b-c", "-")
str_split_fixed("a-b-c", "-", n = 3) #★
str_split_fixed("a-b-c", "-", n = 2)

# stringr可以用来描述模式的四个主要引擎：

# 1正则表达式，默认，如上所示，并在vignette("regular-expressions")。
# 2固定bytewise匹配，与fixed()。
# 3语言敏感字符匹配，与 coll()
# 4文本边界分析boundary()。
a1 <- "\u00e1"
a2 <- "a\u0301"
c(a1, a2)
a1 == a2
str_detect(a1, fixed(a2))
str_detect(a1, coll(a2))

# coll(x)寻找一个匹配x使用人类语言科尔通货膨胀的规则，
# 如果你想要做的不区分大小写的匹配就显得尤为重要。整理规则在世界各地不同，
# 所以您还需要提供一个locale参数。
i <- c("I", "İ", "i", "ı")
str_subset(i, coll("i", ignore_case = TRUE))
str_subset(i, coll("i", ignore_case = TRUE, locale = "tr"))

# 缺点coll()是速度; 因为该字符是相同的用于识别规则复杂，coll()相比相对缓慢regex()和fixed()。
# 请注意，都将fixed()和regex()有ignore_case争论，他们的表现比更简单的比较coll()。

# boundary()匹配字符，行，句子或单词之间的边界。
# 这是最有用的str_split()，但可以用于所有模式匹配功能
x <- "This is a sentence."
str_split(x, boundary("word"))
str_count(x, boundary("word"))
str_extract_all(x, boundary("word"))
# 按照惯例，""被视为boundary("character")：
str_split(x, "")
str_count(x, "")





#-----------------------          dplyr           --------------------------------
#-----------------------          dplyr           --------------------------------
#-----------------------          dplyr           --------------------------------
# dplyr是一种数据操作语法，提供一套一致的动词，可帮助您解决最常见的数据操作难题：
# 
# mutate() 添加作为现有变量函数的新变量
# select() 根据名称选择变量。
# filter() 根据其价值选择案件。
# summarise() 将多个值减少到单个摘要。
# arrange() 更改行的顺序。

# 获取dplyr的最简单的方法是安装整个tidyverse： 
install.packages("tidyverse")# 或者，只需安装dplyr： 
install.packages("dplyr")
# 或从GitHub开发版本：
# install.packages("devtools")
devtools::install_github("tidyverse/dplyr")

library(dplyr)
#-----------------1.    数据集类型转换：
# tbl_df()可用于将过长过大的数据集转换为显示更友好的 tbl_df 类型。
# 使用dplyr包处理数据前，建议先将数据集转换为tbl对象。

#转换为tbl_df类型  
ds <- tbl_df(mtcars)  
#转换为data.frame类型  
df <- as.data.frame(ds)  



# -----------------2.   筛选:  filter   slice()     # 函数通过行号选取数据。

#过滤出cyl == 8的行  
filter(mtcars, cyl == 8)  
filter(mtcars, cyl < 6)  
#过滤出cyl < 6 并且 vs == 1的行  
filter(mtcars, cyl < 6 & vs == 1)  
filter(mtcars, cyl < 6, vs == 1)  
#过滤出cyl < 6 或者 vs == 1的行  
filter(mtcars, cyl < 6 | vs == 1)  
#过滤出cyl 为4或6的行  
filter(mtcars, cyl %in% c(4, 6)) 


#选取第一行数据  
slice(mtcars, 1L)  
filter(mtcars, row_number() == 1L)  
#选取最后一行数据  
slice(mtcars, n())  
filter(mtcars, row_number() == n())  
#选取第5行到最后一行所有数据  
slice(mtcars, 5:n())  
filter(mtcars, between(row_number(), 5, n())) 


names(starwars)
starwars %>% 
  filter(species == "Droid")
#----------------- 4. 选择: select:
# select()用列名作参数来选择子数据集。dplyr包中提供了些特殊功能的函数与select函数结合使用，
# 用于筛选变量，包括starts_with，ends_with，contains，matches，one_of，num_range和everything等。
# 用于重命名时，select()只保留参数中给定的列，rename()保留所有的列，只对给定的列重新命名。
# 原数据集行名称会被过滤掉。

iris <- tbl_df(iris)                   
 
select(iris, starts_with("Petal"))    #选取变量名前缀包含Petal的列  

select(iris, -starts_with("Petal"))   #选取变量名前缀不包含Petal的列
 
select(iris, ends_with("Width"))      #选取变量名后缀包含Width的列  

select(iris, -ends_with("Width"))     #选取变量名后缀不包含Width的列  

select(iris, contains("etal"))        #选取变量名中包含etal的列 

select(iris, -contains("etal"))       #选取变量名中不包含etal的列 

select(iris, matches(".t."))          #正则表达式匹配，返回变量名中包含t的列

select(iris, -matches(".t."))         #正则表达式匹配，返回变量名中不包含t的列  

select(iris, Petal.Length, Petal.Width)   #直接选取列
 
select(iris, -Petal.Length, -Petal.Width) #返回除Petal.Length和Petal.Width之外的所有列  

select(iris, Sepal.Length:Petal.Width)   #使用冒号连接列名，选择多个列 

vars <- c("Petal.Length", "Petal.Width")  
select(iris, one_of(vars))#选择字符向量中的列，select中不能直接使用字符向量筛选，需要使用one_of函数  

select(iris, -one_of(vars))           #返回指定字符向量之外的列  

select(iris, everything())            #返回所有列，一般调整数据集中变量顺序时使用  

select(iris, Species, everything())   #调整列顺序，把Species列放到最前面  

df <- as.data.frame(matrix(runif(100), nrow = 10))  
df <- tbl_df(df[c(3, 4, 7, 1, 9, 8, 5, 2, 6, 10)])  
#选择V4，V5，V6三列  
select(df, V4:V6)  
select(df, num_range("V", 4:6))

#重命名列Petal.Length，返回子数据集只包含重命名的列  
select(iris, petal_length = Petal.Length)  
#重命名所有以Petal为前缀的列，返回子数据集只包含重命名的列  
select(iris, petal = starts_with("Petal"))  
#重命名列Petal.Length，返回全部列  
rename(iris, petal_length = Petal.Length)



starwars %>% 
  select(name, ends_with("color"))   #结尾以color列名



#--------------------5.变形: mutate
# mutate()和transmute()函数对已有列进行数据运算并添加为新列，类似于base::transform() 函数, 
# 不同的是可以在同一语句中对刚增添加的列进行操作。mutate()返回的结果集会保留原有变量，
# transmute()只返回扩展的新变量。原数据集行名称会被过滤掉。

#添加新列wt_kg和wt_t,在同一语句中可以使用刚添加的列  
mutate(mtcars, wt_kg = wt * 453.592, wt_t = wt_kg / 1000)  
#计算新列wt_kg和wt_t，返回对象中只包含新列  
transmute(mtcars, wt_kg = wt * 453.592, wt_t = wt_kg / 1000)  


starwars %>% 
  mutate(name, bmi = mass / ((height / 100)  ^ 2)) %>%
  select(name:mass, bmi)

#----------------- 3. 排列: arrange

#以cyl和disp联合升序排序  
arrange(mtcars, cyl, disp)  
#以disp降序排序  
arrange(mtcars, desc(disp))  


starwars %>% 
  arrange(desc(mass))

starwars %>%
  group_by(species) %>%
  summarise(
    n = n(),
    mass = mean(mass, na.rm = TRUE)
  ) %>%
  filter(n > 1)


#------------------ 6. 去重: distinct
# distinct()用于对输入的tbl进行去重，返回无重复的行，
# 类似于 base::unique() 函数，但是处理速度更快。原数据集行名称会被过滤掉。
df <- data.frame(  
  x = sample(10, 100, rep = TRUE),  
  y = sample(10, 100, rep = TRUE))   
nrow(distinct(df))                    #以全部两个变量去重，返回去重后的行数
nrow(distinct(df, x, y))  
distinct(df, x)                       #以变量x去重，只返回去重后的x值  
distinct(df, y)                       #以变量y去重，只返回去重后的y值
distinct(df, x, .keep_all = TRUE)     #以变量x去重，返回所有变量 
distinct(df, y, .keep_all = TRUE)     #以变量y去重，返回所有变量
distinct(df, diff = abs(x - y))       #对变量运算后的结果去重 



#------------------ 7. 概括: summarise
# 对数据框调用函数进行汇总操作, 返回一维的结果。返回多维结果时会报如下错误：
# Error: expecting result of length one, got : 2
# 原数据集行名称会被过滤掉

 
summarise(mtcars, mean(disp))           #返回数据框中变量disp的均值 
 
summarise(mtcars, sd(disp))             #返回数据框中变量disp的标准差 
 
summarise(mtcars, max(disp), min(disp)) #返回数据框中变量disp的最大值及最小值  
 
summarise(mtcars, n())                  #返回数据框mtcars的行数 

summarise(mtcars, n_distinct(gear))     #返回unique的gear数  
 
summarise(mtcars, first(disp))          #返回disp的第一个值 
  
summarise(mtcars, last(disp))           #返回disp的最后个值


#------------------ 8. 抽样: sample
# 抽样函数，sample_n()随机抽取指定数目的样本，
# sample_frac()随机抽取指定百分比的样本，默认都为不放回抽样，
# 通过设置replacement = TRUE可改为放回抽样，可以用于实现Bootstrap抽样。
# 语法 ：sample_n(tbl, size, replace = FALSE, weight = NULL, .env = parent.frame())

#随机无重复的取10行数据  
sample_n(mtcars, 10)  
#随机有重复的取50行数据  
sample_n(mtcars, 50, replace = TRUE)  
#随机无重复的以mpg值做权重取10行数据  
sample_n(mtcars, 10, weight = mpg)

# 语法 ：sample_frac(tbl, size = 1, replace = FALSE, weight = NULL,.env = parent.frame())

#默认size=1，相当于对全部数据无重复重新抽样  
sample_frac(mtcars)  
#随机无重复的取10%的数据  
sample_frac(mtcars, 0.1)  
#随机有重复的取总行数1.5倍的数据  
sample_frac(mtcars, 1.5, replace = TRUE)  
#随机无重复的以1/mpg值做权重取10%的数据  
sample_frac(mtcars, 0.1, weight = 1 / mpg)



#------------------ 9. 分组: group
# group_by()用于对数据集按照给定变量分组，返回分组后的数据集。
# 对返回后的数据集使用以上介绍的函数时，会自动的对分组数据操作。


#使用变量cyl对mtcars分组，返回分组后数据集  
by_cyl <- group_by(mtcars, cyl)  
#返回每个分组中最大disp所在的行  
filter(by_cyl, disp == max(disp))  
#返回每个分组中变量名包含d的列，始终返回分组列cyl  
select(by_cyl, contains("d"))  
#使用mpg对每个分组排序  
arrange(by_cyl,  mpg)  
#对每个分组无重复的取2行记录  
sample_n(by_cyl, 2)


#使用变量cyl对mtcars分组，然后对分组后数据集使用聚合函数  
by_cyl <- group_by(mtcars, cyl)  
#返回每个分组的记录数  
summarise(by_cyl, n())  
#求每个分组中disp和hp的均值  
summarise(by_cyl, mean(disp), mean(hp))  
#返回每个分组中唯一的gear的值  
summarise(by_cyl, n_distinct(gear))  
#返回每个分组第一个和最后一个disp值  
summarise(by_cyl, first(disp))  
summarise(by_cyl, last(disp))  
#返回每个分组中最小的disp值  
summarise(by_cyl, min(disp))  
summarise(arrange(by_cyl,  disp), min(disp))  
#返回每个分组中最大的disp值  
summarise(by_cyl, max(disp))  
summarise(arrange(by_cyl,  disp), max(disp))  
#返回每个分组中disp第二个值  
summarise(by_cyl, nth(disp,2))

#使用cyl对数据框分组  
grouped <- group_by(mtcars, cyl)  
#获取分组数据集所使用的分组变量  
groups(grouped)  
#ungroup从数据框中移除组合信息，因此返回的分组变量为NULL  
groups(ungroup(grouped))

#返回每条记录所在分组id组成的向量  
group_indices(mtcars, cyl)  

by_cyl <- group_by(mtcars, cyl)  
#返回每个分组记录数组成的向量  
group_size(by_cyl)  
summarise(by_cyl, n())  
table(mtcars$cyl)  
#返回所分的组数  
n_groups(by_cyl)  
length(group_size(by_cyl))  

#使用count对分组计数，数据已按变量分组  
count(mtcars, cyl)  
#设置sort=TRUE，对分组计数按降序排序  
count(mtcars, cyl, sort = TRUE)  
#使用tally对分组计数，需要使用group_by分组  
tally(group_by(mtcars, cyl))  
#使用summarise对分组计数  
summarise(group_by(mtcars, cyl), n()) 

#按cyl分组，并对分组数据计算变量的gear的和  
count(mtcars, cyl, wt = gear)  
tally(group_by(mtcars, cyl), wt = gear)  


#------------------ 10. 数据关联：join
# 数据框中经常需要将多个表进行连接操作, 如左连接、右连接、内连接等，
# dplyr包也提供了数据集的连接操作，类似于 base::merge() 函数。语法如下： 
# #内连接，合并数据仅保留匹配的记录
# inner_join(x,y, by = NULL, copy = FALSE, suffix = c(".x", ".y"), ...) 
# #左连接，向数据集x中加入匹配的数据集y记录
# left_join(x,y, by = NULL, copy = FALSE, suffix = c(".x", ".y"), ...)
# #右连接，向数据集y中加入匹配的数据集x记录
# right_join(x,y, by = NULL, copy = FALSE, suffix = c(".x", ".y"), ...) 
# #全连接，合并数据保留所有记录，所有行
# full_join(x,y, by = NULL, copy = FALSE, suffix = c(".x", ".y"), ...)
# #返回能够与y表匹配的x表所有记录 
# semi_join(x,y, by = NULL, copy = FALSE, ...)
# #返回无法与y表匹配的x表的所有记录
# anti_join(x, y, by = NULL, copy = FALSE, ...) 
df1 = data.frame(CustomerId=c(1:6), sex = c("f", "m", "f", "f", "m", "m"), Product=c(rep("Toaster",3), rep("Radio",3)))  
df2 = data.frame(CustomerId=c(2,4,6,7),sex = c( "m", "f", "m", "f"), State=c(rep("Alabama",3), rep("Ohio",1)))  
#内连接，默认使用"CustomerId"和"sex"连接  
inner_join(df1, df2)  
#左连接，默认使用"CustomerId"和"sex"连接  
left_join(df1, df2)  
#右连接，默认使用"CustomerId"和"sex"连接  
right_join(df1, df2)  
#全连接，默认使用"CustomerId"和"sex"连接  
full_join(df1, df2)  
#内连接，使用"CustomerId"连接，同名字段sex会自动添加后缀  
inner_join(df1, df2, by = c("CustomerId" = "CustomerId"))  
#以CustomerId连接，返回df1中与df2匹配的记录  
semi_join(df1, df2, by = c("CustomerId" = "CustomerId"))  
#以CustomerId和sex连接，返回df1中与df2不匹配的记录  
anti_join(df1, df2) 



#------------------ 11. 集合操作: set
# dplyr也提供了集合操作函数，实际上是对base包中的集合操作的重写，
# 但是对数据框和其它表格形式的数据操作更加高效。语法如下：
# #取两个集合的交集
# intersect(x,y, ...)
# #取两个集合的并集，并进行去重
# union(x,y, ...)
# #取两个集合的并集，不去重
# union_all(x,y, ...)
# #取两个集合的差集
# setdiff(x,y, ...)
# #判断两个集合是否相等
# setequal(x, y, ...)

mtcars$model <- rownames(mtcars)  
first <- mtcars[1:20, ]  
second <- mtcars[10:32, ]  
#取两个集合的交集  
intersect(first, second)  
#取两个集合的并集，并去重  
union(first, second)  
#取两个集合的差集，返回first中存在但second中不存在的记录  
setdiff(first, second)  
#取两个集合的交集，返回second中存在但first中不存在的记录  
setdiff(second, first)  
#取两个集合的交集, 不去重  
union_all(first, second)  
#判断两个集合是否相等，返回TRUE  
setequal(mtcars, mtcars[32:1, ])  




#------------------ 12. 数据合并: bind

one <- mtcars[1:4, ]  
two <- mtcars[11:14, ]  
#按行合并数据框one和two  
bind_rows(one, two)  
#按行合并元素为数据框的列表  
bind_rows(list(one, two))  
#按行合并数据框，生成id列指明数据来自的源数据框，id列的值使用数字代替  
bind_rows(list(one, two), .id = "id")  
#按行合并数据框，生成id列指明数据来自的源数据框，id列的值为数据框名  
bind_rows(list(a = one, b = two), .id = "id")  
#按列合并数据框one和two  
bind_cols(one, two)  
bind_cols(list(one, two)) 

#合并数据框，列名不匹配，因此使用NA替代，使用rbind直接报错  
bind_rows(data.frame(x = 1:3), data.frame(y = 1:4)) 

#合并因子  
f1 <- factor("a")  
f2 <- factor("b")  
c(f1, f2)  
unlist(list(f1, f2))  
#因子level不同，强制转换为字符型  
combine(f1, f2)  
combine(list(f1, f2))





#------------------ 13. 条件语句：ifelse
x <- c(-5:5, NA)  
#替换所有小于0的元素为NA，为了保持类型一致，因此使用NA_integer_  
if_else(x < 0, NA_integer_, x)  
#使用字符串missing替换原数据中的NA元素  
if_else(x < 0, "negative", "positive", "missing")  
#if_else不支持类型不一致，但是ifelse可以  
ifelse(x < 0, "negative", 1)

x <- factor(sample(letters[1:5], 10, replace = TRUE))  
#if_else会保留原有数据类型  
if_else(x %in% c("a", "b", "c"), x, factor(NA))  
ifelse(x %in% c("a", "b", "c"), x, factor(NA)) 

# case_when语句类似于if/else语句。表达式使用“~”连接，
# 左值LHS为条件语句用于判断满足条件的元素，右值为具有相同类型的替换值，用于替换满足条件的元素。
# 语法 ：case_when(...)

#顺序执行各语句对原向量进行替换，因此越普遍的条件需放在最后  
x <- 1:50  
case_when(  
  x %% 35 == 0 ~ "fizz buzz",  
  x %% 5 == 0 ~ "fizz",  
  x %% 7 == 0 ~ "buzz",  
  TRUE ~ as.character(x))  




#------------------ 14. 数据库操作: database
# dplyr也提供了对数据库的连接和操作函数，目前仅支持sqlite, MySQL，postgresql以及google bigquery。
# dplyr可把R代码自动转换为SQL语句，然后在数据库上执行以获取数据。
# 实际的处理过程中，所有的R代码并不是立即执行，而是在实际获取数据的时候，一次性在数据库中执行。
# 下面以sqlite数据库为例。
# 创建和连接数据库: src_sqlite(path, create = FALSE)
# 当create为FALSE（默认），path必须为已存在的数据库路径和全名，为TRUE，
# 会根据设置的path创建sqlite数据库。

#在默认工作路劲下创建sqlite数据库  
my_db <- src_sqlite("dplyrdb.db", create = TRUE) 
#目前数据库中还没有表  
src_tbls(my_db) 

# 导入数据到创建的数据库中并创建相应的表，如果未给出表名则使用传入的data frame名称，
# 导入时可以通过indexes参数给创建的表添加索引, 
# copy_to同时会执行ANALYZE命令以保证表具有最新的统计信息并且执行相应的查询优化。
# 导入数据到远程数据源：
copy_to(dest, df, name =deparse(substitute(df)), temporary, indexes,...)

library(nycflights13)  
#导入flights数据到数据库中，并创建相应的索引  
flights_sqlite <- copy_to(my_db, flights, temporary = FALSE, indexes = list(c("year", "month", "day"), "carrier", "tailnum"))  
#已存在表flights  
src_tbls(my_db) 

# tbl可用于与源数据源(src)中的数据(from)建立连接，from可以是表名或者是SQL语句返回的数据。
# 与数据库建立连接： tbl(src, from, ...)

#查询数据库中表数据，直接给出表名  
tb.flight <- tbl(my_db, 'flights')  
#查询数据库中表数据，使用SQL语句返回数据  
tb.flight2 <- tbl(my_db, sql("SELECT * FROM flights"))


#操作数据库中数据，语句并没有被实际执行，只有显式获取数据时才会执行  
c1 <- filter(tb.flight, year == 2013, month == 1, day == 1)  
c2 <- select(c1, year, month, day, carrier, dep_delay, air_time, distance)  
c3 <- mutate(c2, speed = distance / air_time * 60)  
c4 <- arrange(c3, year, month, day, carrier)  


# 在未显式获取数据时，所有的操作只是生成tbl_sql对象，
# 可以通过以下操作获取返回相应的SQL语句以及执行计划。
# 语法： show_query(x)
# explain(x, ...)


#返回对象c4对应的SQL语句  
show_query(c4)  
#返回对象c4对应的SQL语句以及执行计划  
explain(c4) 


# 对于lazy操作的这种机制，数据操作实际并没有真正的执行查询，如果需要返回数据结果，
# 可以用以下的函数强制执行查询并返回结果。
# #强制执行查询，并返回tbl_df对象到R
# collect(x, ...)
# #强制执行查询，并在源数据库中创建临时表存储结果
# compute(x, name = random_table_name(),temporary = TRUE,
#         unique_indexes = list(), indexes = list(),...)
# #不强制执行查询，拆分复杂的tbl对象，以便添加额外的约束
# collapse(x, ...) 

#执行c4查询，返回对象到R  
tbl_dfight <- collect(c4)  
#执行查询并在数据库中创建临时表，通过src_tbls可查询到新建的temp表  
compute(c4, name = 'temp_flights')  
src_tbls(my_db)  
#实际并没有执行查询，仍可用show_query返回对应的SQL语句  
remote <- collapse(c4)  
show_query(remote) 
























