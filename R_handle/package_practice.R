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
names(starwars)
starwars %>% 
  filter(species == "Droid")

starwars %>% 
  select(name, ends_with("color"))   #结尾以color列名

starwars %>% 
  mutate(name, bmi = mass / ((height / 100)  ^ 2)) %>%
  select(name:mass, bmi)

starwars %>% 
  arrange(desc(mass))

starwars %>%
  group_by(species) %>%
  summarise(
    n = n(),
    mass = mean(mass, na.rm = TRUE)
  ) %>%
  filter(n > 1)























