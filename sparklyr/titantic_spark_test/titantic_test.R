#  https://beta.rstudioconnect.com/content/1518/notebook-classification.html
library(sparklyr)
library(dplyr)
library(tidyr)
library(titanic)
library(ggplot2)
library(purrr)

sc1 <- spark_connect(master = "yarn-client",
                    version="1.6.0", 
                    # config = config,
                    spark_home = '/opt/cloudera/parcels/CDH/lib/spark/')

sc2 <- spark_connect(master = "yarn",
                    version="2.1.0", 
                    app_name = "sparklyr2.1.0",
                    spark_home = '/opt/cloudera/parcels/SPARK2/lib/spark2/') 

train <- spark_read_csv(sc2, name = "titanic", path = "hdfs:///user/dsg/titantic/train.csv")


# --------------------------      data ETL    ----------------------------------
titanic2_tbl <- train %>% 
  dplyr::mutate(Family_Size = SibSp + Parch + 1L) %>%   #Family_size=旁系数量+直系数量 +1(乘船本人)的目的ft_bucketizer区间统计是左开右闭
  dplyr::mutate(Pclass = as.character(Pclass)) %>%      #船舱等级转换字符型
  dplyr::filter(Embarked != "") %>%                     #去掉缺失的登船港口的用户数
  dplyr::mutate(Age = if_else(is.na(Age), mean(Age,na.rm = T), Age)) %>%   #将缺失年龄的用户求平均
  sdf_register("titanic2")      #保存的spark cache中

# Transform family size with Spark ML API
titanic_final_tbl <- titanic2_tbl %>%
  dplyr::mutate(Family_Size = as.numeric(Family_size)) %>%  #将Family_size转换成浮点型才能用于mutate
  sdf_mutate(Family_Sizes = ft_bucketizer(Family_Size, splits = c(1,2,5,12))) %>% 
  #ft_bucketizer将家庭大小分组(分箱（分段处理）：将连续数值转换为离散类别 )默认会将NA 转换成0。
  dplyr::mutate(Family_Sizes = as.character(as.integer(Family_Sizes))) %>%
  sdf_register("titanic_final")

# train验证拆分
# Partition the data
partition <- titanic_final_tbl %>% 
  dplyr::mutate(Survived = as.numeric(Survived), SibSp = as.numeric(SibSp), Parch = as.numeric(Parch)) %>%
  dplyr::select(Survived, Pclass, Sex, Age, SibSp, Parch, Fare, Embarked, Family_Sizes) %>%
  sdf_partition(train = 0.75, test = 0.25, seed = 8585)

# Create table references
train_tbl <- partition$train
test_tbl <- partition$test


# Model survival as a function of several predictors
#  Survived 生存情况 ；Pclass客舱等级（1、2、3）；SibSp在船兄弟姐妹/配偶数量 ；Parch在船父母数/子女数 ；Fare票价 ；Embarked登船港口
ml_formula <- formula(Survived ~ Pclass + Sex + Age + SibSp + Parch + Fare + Embarked + Family_Sizes)




# --------------------------      ML算法    ------------------------------------
ml_log <- ml_logistic_regression(train_tbl, ml_formula)
## Decision Tree
ml_dt <- ml_decision_tree(train_tbl, ml_formula)

## Random Forest
ml_rf <- ml_random_forest(train_tbl, ml_formula)

## Gradient Boosted Tree
ml_gbt <- ml_gradient_boosted_trees(train_tbl, ml_formula)

## Naive Bayes
ml_nb <- ml_naive_bayes(train_tbl, ml_formula)

## Neural Network
ml_nn <- ml_multilayer_perceptron(train_tbl, ml_formula, layers = c(11,15,2))


# --------------------------      验证数据    ----------------------------------
# 用训练的模型对测试数据进行评分。
# Bundle the modelss into a single list object
ml_models <- list(
  "Logistic" = ml_log,
  "Decision Tree" = ml_dt,
  "Random Forest" = ml_rf,
  "Gradient Boosted Trees" = ml_gbt,
  "Naive Bayes" = ml_nb,
  "Neural Net" = ml_nn
)

# Create a function for scoring
score_test_data <- function(model, data=test_tbl){
  pred <- sdf_predict(model, data)
  dplyr::select(pred, Survived, prediction)
}

# Score all the models
ml_score <- lapply(ml_models, score_test_data)

# 比较结果
# 比较模型结果。检查性能指标：提升，AUC和准确性。还要检查特征的重要性，以查看哪些特征最能预测生存。

# 模型升降机
# 提升比较模型预测生存与随机猜测相比有多好。使用下面的函数为测试数据中的每个得分十分位数估计模型提升。
#升降图表明树模型（随机森林，梯度增强树或决策树）将提供最佳预测。

# Lift function
calculate_lift <- function(scored_data) {
  scored_data %>%
    dplyr::mutate(bin = ntile(desc(prediction), 10)) %>% 
    dplyr::group_by(bin) %>% 
    dplyr::summarize(count = sum(Survived)) %>% 
    dplyr::mutate(prop = count / sum(count)) %>% 
    dplyr::arrange(bin) %>% 
    dplyr::mutate(prop = cumsum(prop)) %>% 
    dplyr::select(-count) %>% 
    dplyr::collect() %>% 
    as.data.frame()
}

# Initialize results
ml_gains <- data.frame(bin = 1:10, prop = seq(0, 1, len = 10), model = "Base")

# Calculate lift
for(i in names(ml_score)){
  ml_gains <- ml_score[[i]] %>%
    calculate_lift %>%
    dplyr::mutate(model = i) %>%
    rbind(ml_gains, .)
}

# Plot results
ggplot(ml_gains, aes(x = bin, y = prop, colour = model)) +
  geom_point() + geom_line() +
  ggtitle("Lift Chart for Predicting Survival - Test Data Set") + 
  xlab("") + ylab("")


# AUC和准确性
# 尽管ROC曲线不可用，但Spark ML确实支持ROC曲线下的区域。此度量标准捕获特定截止值的性能。AUC越高越好。
# Function for calculating accuracy
calc_accuracy <- function(data, cutpoint = 0.5){
  data %>% 
    dplyr::mutate(prediction = if_else(prediction > cutpoint, 1.0, 0.0)) %>%
    ml_classification_eval("prediction", "Survived", "accuracy")
}

# Calculate AUC and accuracy
perf_metrics <- data.frame(
  model = names(ml_score),
  AUC = 100 * sapply(ml_score, ml_binary_classification_eval, "Survived", "prediction"),
  Accuracy = 100 * sapply(ml_score, calc_accuracy),
  row.names = NULL, stringsAsFactors = FALSE)

# Plot results
gather(perf_metrics, metric, value, AUC, Accuracy) %>%
  ggplot(aes(reorder(model, value), value, fill = metric)) + 
  geom_bar(stat = "identity", position = "dodge") + 
  coord_flip() +
  xlab("") +
  ylab("Percent") +
  ggtitle("Performance Metrics")

# --------------------------      特色重要    ----------------------------------
# 将每个模型所识别的特征作为生存的重要预测因子进行比较也很有意义。
#逻辑回归和树模型实现了特征重要性度量。性别，票价和年龄是一些最重要的特征。

# Initialize results
feature_importance <- data.frame()

# Calculate feature importance
for(i in c("Decision Tree", "Random Forest", "Gradient Boosted Trees")){
  feature_importance <- ml_tree_feature_importance(sc2, ml_models[[i]]) %>%
    dplyr::mutate(Model = i) %>%
    dplyr::mutate(importance = as.numeric(levels(importance))[importance]) %>%
    dplyr::mutate(feature = as.character(feature)) %>%
    rbind(feature_importance, .)
}

# Plot results
feature_importance %>%
  ggplot(aes(reorder(feature, importance), importance, fill = Model)) + 
  facet_wrap(~Model) +
  geom_bar(stat = "identity") + 
  coord_flip() +
  xlab("") +
  ggtitle("Feature Importance")


# --------------------------      运行时间    ----------------------------------
# 训练模型的时间很重要。使用以下代码评估每个模型的n时间并绘制结果。
#请注意，梯度增强树木和神经网络需要相当长的时间来训练其他方法。
# Number of reps per model
n <- 10

# Format model formula as character
format_as_character <- function(x){
  x <- paste(deparse(x), collapse = "")
  x <- gsub("\\s+", " ", paste(x, collapse = ""))
  x
}

# Create model statements with timers
format_statements <- function(y){
  y <- format_as_character(y[[".call"]])
  y <- gsub('ml_formula', ml_formula_char, y)
  y <- paste0("system.time(", y, ")")
  y
}

# Convert model formula to character
ml_formula_char <- format_as_character(ml_formula)

# Create n replicates of each model statements with timers
all_statements <- sapply(ml_models, format_statements) %>%
  rep(., n) %>%
  parse(text = .)

# Evaluate all model statements
res  <- map(all_statements, eval)

# Compile results
result <- data.frame(model = rep(names(ml_models), n),
                     time = sapply(res, function(x){as.numeric(x["elapsed"])})) 

# Plot
result %>% ggplot(aes(time, reorder(model, time))) + 
  geom_boxplot() + 
  geom_jitter(width = 0.4, aes(colour = model)) +
  scale_colour_discrete(guide = FALSE) +
  xlab("Seconds") +
  ylab("") +
  ggtitle("Model training times")

spark_disconnect(sc2)