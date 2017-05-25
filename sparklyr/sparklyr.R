install.packages("devtools") #第三方工具包，用于下载github上下载package
library(devtools) 
devtools::install_github('apache/spark@v2.0.0', subdir='R/pkg') #install package of SparkR
devtools::install_github("hadley/lazyeval")  
#下载dplyr”不满足要求，需要下载the latest development version
devtools::install_github("hadley/dplyr") 
#需要下载这个版本的dplyr的包，需要安装Rtools工具
devtools::install_github("rstudio/sparklyr")

install.packages("backports")

Install.packages("rJava")

spark_install(version = "2.0.0")
# install.packages("sparklyr")
packageVersion("sparklyr")
library(sparklyr)
library(dplyr)
library(SparkR)


Sys.setenv(SPARK_HOME='/usr/lib/spark')

sc <- spark_connect(master = "yarn-client")

# Sys.setenv(SPARK_HOME = "/root/spark")
# 
# Sys.setenv(HADOOP_CONF_DIR = '/etc/hadoop/conf.cloudera.hdfs')
# 
# Sys.setenv(YARN_CONF_DIR = '/etc/hadoop/conf.cloudera.yarn')
# 
# config <- spark_config()
# 
# config$spark.executor.instances <- 4
# 
# config$spark.executor.cores <- 4
# 
# config$spark.executor.memory <- "4G"

# sc <- spark_connect(master="yarn-client", config=config)


# sc <- spark_connect(master = "spark://192.168.2.20:7077",
#                     spark_home = "/root/spark/",
#                     method = c("shell", "livy", "test"),
#                     app_name = "sparklyr")
# 
sc <- spark_connect(master = "192.168.2.20:7077")

sc <- spark_connect(master = "local",version="2.0.0")
sc <- spark_connect(master = "local",version="2.0.0")
install.packages(c("nycflights13", "Lahman"))
iris_tbl <- copy_to(sc, iris)
flights_tbl <- copy_to(sc, nycflights13::flights, "flights")
batting_tbl <- copy_to(sc, Lahman::Batting, "batting")
src_tbls(sc)

flights_tbl %>% filter(dep_delay == 2)

delay <- flights_tbl %>% 
  group_by(tailnum) %>%
  summarise(count = n(), dist = mean(distance), delay = mean(arr_delay)) %>%
  filter(count > 20, dist < 2000, !is.na(delay)) %>%
  collect

library(ggplot2)
ggplot(delay, aes(dist, delay)) +
  geom_point(aes(size = count), alpha = 1/2) +
  geom_smooth() +
  scale_size_area(max_size = 2)

batting_tbl %>%
  select(playerID, yearID, teamID, G, AB:H) %>%
  arrange(playerID, yearID, teamID) %>%
  group_by(playerID) %>%
  filter(min_rank(desc(H)) <= 2 & H > 0)

library(DBI)
iris_preview <- dbGetQuery(sc, "SELECT * FROM iris LIMIT 10")
iris_preview

# copy mtcars into spark
mtcars_tbl <- copy_to(sc, mtcars)

# transform our data set, and then partition into 'training', 'test'
partitions <- mtcars_tbl %>%
  filter(hp >= 100) %>%
  mutate(cyl8 = cyl == 8) %>%
  sdf_partition(training = 0.5, test = 0.5, seed = 1099)

# fit a linear model to the training dataset
fit <- partitions$training %>%
  ml_linear_regression(response = "mpg", features = c("wt", "cyl"))
summary(fit)


temp_csv <- tempfile(fileext = ".csv")
temp_parquet <- tempfile(fileext = ".parquet")
temp_json <- tempfile(fileext = ".json")

spark_write_csv(iris_tbl, temp_csv)
iris_csv_tbl <- spark_read_csv(sc, "iris_csv", temp_csv)

spark_write_parquet(iris_tbl, temp_parquet)
iris_parquet_tbl <- spark_read_parquet(sc, "iris_parquet", temp_parquet)

spark_write_json(iris_tbl, temp_json)
iris_json_tbl <- spark_read_json(sc, "iris_json", temp_json)

src_tbls(sc)


# write a CSV 
tempfile <- tempfile(fileext = ".csv")
write.csv(nycflights13::flights, tempfile, row.names = FALSE, na = "")

# define an R interface to Spark line counting
count_lines <- function(sc, path) {
  spark_context(sc) %>% 
    invoke("textFile", path, 1L) %>% 
    invoke("count")
}

# call spark to count the lines of the CSV
count_lines(sc, tempfile)



















