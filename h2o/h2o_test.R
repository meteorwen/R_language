# install H2O 

 #   yum install -y  R-devel.x86_64 libcurl-devel.x86_64
 #   > library(h2o)
 #   > demo(h2o.glm)



library(h2o)

demo(h2o.glm)
# -1表示使用你机器上所有的核
# max_mem_size参数表示允许h2o使用的最大内存
h2o.init(nthreads = -1, max_mem_size = "6G")

#可以直接从一个URL中导入数据
loan_csv <- "https://raw.githubusercontent.com/h2oai/app-consumer-loan/master/data/loan.csv"
data <- h2o.importFile(loan_csv)   

dim(data) 
# 163,987 rows x 15 columns

# 由于我们是一个二分类问题，我们必须指定响应变量为一个因子类型(factor)，
# 若响应变量为0/1,H2O会认为他是一个数值，那将意味着H2O会训练一个回归模型：
#编码为因子类型
data$bad_loan <- as.factor(data$bad_loan)

#查看因子levels
h2o.levels(data$bad_loan)

#将训练集，验证集与测试集
#按比例分别设为70%, 15%, 15%
splits <- h2o.splitFrame(data = data, 
                         ratios = c(0.7, 0.15),   
                         #设定种子保证可重复性                         
                         seed = 1) 

train <- splits[[1]]
valid <- splits[[2]]
test <- splits[[3]]

# 我们来看下数据各部分的大小，注意h2o.splitFrame函数为了运行效率采用的是近似拆分方法而不是精确拆分，
# 故你会发现数据大小不是精确的70%, 15%与15%
nrow(train)  
# 114908
nrow(valid) 
# 24498
nrow(test)  
# 24581
y <- "bad_loan"
x <- setdiff(names(data),c(y, "int_rate")) 


# 下面我们将训练几个模型，主要的模型包括H20监督算法的：
# 
#1 广义线性回归模型 (GLM)
#2 随机森林模型(RF)
#3 GBM(也称GBDT)
#4 深度学习(DL)
#5 朴素贝叶斯(NB)

#####################            1.广义线性回归模型 (GLM)        ##################
# 让我们从一个基本的二元广义线性回归开始：默认情况下h2o.glm采用一个带正则项的弹性网模型(Elastic Net Model)。
glm_fit1 <- h2o.glm(x = x, 
                    y = y, 
                    training_frame = train,
                    model_id = "glm_fit1",
                    family = "binomial") 

# 下面我们将通过验证集来进行一些自动调参工作，需要设置lambda_search = True。
# 因为我们的GLM模型是带正则项的，所以我们需要找到一个合适的正则项大小来防止过拟合。
# 这个模型参数lambda是控制GLM模型的正则项大小，通过设定lambda_search = TRUE 
# 我们能自动找到一个lambda 的最优值，这个自动寻找的方法是通过在验证集上指定一个lambda,
# 验证集上的最优lambda即我们要找的lambda。

glm_fit2 <- h2o.glm(x = x, 
                    y = y, 
                    training_frame = train,
                    model_id = "glm_fit2",
                    family = "binomial",
                    validation_frame = valid,
                    lambda_search = TRUE)

# 让我们在测试集上看下2个GLM模型的表现：
glm_perf1 <- h2o.performance(model = glm_fit1,
                             newdata = test)
glm_perf2 <- h2o.performance(model = glm_fit2,
                             newdata = test)

# 如果你不想输出模型全部的评测对象，我们也只输出你想要的那个评测
h2o.auc(glm_perf1)  
h2o.auc(glm_perf2)
# 比较测试集训练集验证集上的AUC
h2o.auc(glm_fit2, train = TRUE)  
h2o.auc(glm_fit2, valid = TRUE)  
glm_fit2@model$validation_metrics

#####################            2.随机森林模型(RF)        ##################
# H2O的随机森林算法实现了标准随机森林算法的分布式版本和变量重要性的度量，
# 首先我们使用一个默认参数来训练一个基础的随机森林模型。随机森林模型将从因变量编码推断因变量分布。
rf_fit1 <- h2o.randomForest(x = x,
                            y = y,
                            training_frame = train,
                            model_id = "rf_fit1",
                            seed = 1) # 设置随机数以便结果复现.
# 下面我们通过设置参数ntrees = 100来增加树的大小，在H2O中树的默认大小为50。
# 通常来说增加树的大小RF的表现会更好。相比较GBM模型，RF通常更加不易过拟合。
# 在下面的GBM例子中你将会看到我们需要额外的设置early stopping来防止过拟合。

#当参数stopping_rounds > 0时，检验集使用valid
rf_fit2 <- h2o.randomForest(x = x,
                            y = y,
                            training_frame = train,
                            model_id = "rf_fit2",     
                            ntrees = 100,
                            seed = 1)

# 比较2个RF模型的性能
rf_perf1 <- h2o.performance(model = rf_fit1,
                            newdata = test)
rf_perf2 <- h2o.performance(model = rf_fit2,
                            newdata = test)
rf_perf1
rf_perf2

# 提取测试集AUC
h2o.auc(rf_perf1)  
h2o.auc(rf_perf2)

# 有时我们会不设定验证集，而直接使用交叉验证来看模型的表现。
# 下面我们将使用随机森林作为例子，来展示使用H2O进行交叉验证。你不需要自定义代码或循环，
# 您只需在nfolds参数中指定所需折的数量。注意k-折交叉验证将会训练k个模型，故时间是原来额k倍：
rf_fit3 <- h2o.randomForest(x = x,
                            y = y,
                            training_frame = train,
                            model_id = "rf_fit3",
                            seed = 1,
                            nfolds = 5) 

# 评估交叉训练的AUC
h2o.auc(rf_fit3, xval = TRUE)


#####################           3. Gradient Boosting Machine(gbdt/gbm)      ##################
# H2O的GBM提供了一个随机GBM,向较原始的GBM会有一点性能上的提升。现在我们来训练一个基础的GBM模型。
# 如果没有通过distribution参数明确指定，则GBM模型将从因变量编码推断因变量分布。
gbm_fit1 <- h2o.gbm(x = x,
                    y = y,
                    training_frame = train,
                    model_id = "gbm_fit1",
                    seed = 1) # 设置随机数以便结果复现.
# 下面我们将通过设置ntrees=500来增加GBM中树的数量。H2O中默认树的数量为50，
# 所以这次GBM的运行时间会是默认情况的10倍。增加树的个数是通常会提高模型的性能，
# 但是你必须小心，使用那么多树有可能会导致过拟合。你可以通过设置early stopping来自动寻找最优的树的个数。
# 在后面的例子中我们会讨论early stopping。

gbm_fit2 <- h2o.gbm(x = x,
                    y = y,
                    training_frame = train,
                    model_id = "gbm_fit2", 
                    ntrees = 500,
                    seed = 1)
# 下面我们仍然会设置ntrees = 500，但这次我们会设置early stopping来防止过拟合。
# 所有的H2O算法都提供early stopping然而在默认情况下是不启用的(除了深度学习算法)。
# 这里有几个参数设置来控制early stopping，
# 所有参数共有如下3个参数：stopping_rounds, stopping_metric以及stopping_tolerance。
# stopping_metric参数是你的评测函数，在这里我们使用AUC。score_tree_interval参数是随机森林和GBM的特有参数。
# 设置score_tree_interval = 5将在每五棵树之后计算得分。
# 我们下面设置的参数指定模型将在三次评分间隔后停止训练，若AUC增加没有超过0.0005。
# 由于我们指定了一个验证集，所以将在验证集上计算AUC的stopping_tolerance，而不是训练集AUC。

gbm_fit3 <- h2o.gbm(x = x,
                    y = y,
                    training_frame = train,
                    model_id = "gbm_fit3",
                    validation_frame = valid,
                    ntrees = 500,
                    
                    #用于early stopping参数
                    score_tree_interval = 5,      
                    stopping_rounds = 3,  
                    stopping_metric = "AUC",      
                    stopping_tolerance = 0.0005,
                    seed = 1)                     

# GBM性能比较
gbm_perf1 <- h2o.performance(model = gbm_fit1,
                             newdata = test)
gbm_perf2 <- h2o.performance(model = gbm_fit2,
                             newdata = test)
gbm_perf3 <- h2o.performance(model = gbm_fit3,
                             newdata = test)
gbm_perf1
gbm_perf2
gbm_perf3                                         

# 提取测试集AUC
h2o.auc(gbm_perf1)  
h2o.auc(gbm_perf2)  
h2o.auc(gbm_perf3)
# 为了检查评分历史，请在已经训练的模型上使用scoring_history方法，若不指定，
# 它会计算不同间隔的得分，请参阅下面h2o.scoreHistory()。gbm_fit2只使用了训练集没有使用验证集，
# 故只对训练集来计算模型的历史得分。只有使用训练集（无验证集）对“gbm_fit2”进行训练，因此仅为训练集绩效指标计算得分记录。

h2o.scoreHistory(gbm_fit2)
# 当使用early stopping时，我们发现我们只使用了95棵树而不是全部的500棵。
# 由于我们在gbm_fit3中使用了验证集，训练集与验证集的历史得分都被存储了下来。
# 我们来观察验证集的AUC，以确认stopping tolerance是否被强制执行。

h2o.scoreHistory(gbm_fit3)

# 查看下这个模型的历史得分
plot(gbm_fit3, timestep = "number_of_trees", 
     metric = "AUC")
plot(gbm_fit3, timestep = "number_of_trees", 
     metric = "logloss")




#####################          4.深度学习(DL)     ##################

# H2O的深度学习算法是多层前馈人工神经网络，它也可以用于训练自动编码器。 
# 在这个例子中，我们将训练一个标准的监督预测模型。
# 首先我们将使用默认参数训练一个基础深度学习模型，如果没有通过distribution参数明确指定，
# 则DL模型将从因变量编码推断因变量分布。若H2O的DL算法运行在多核上，那么H2O的DL算法将无法重现。
# 所以在这个例子中，下面的性能指标可能与你在机器上看到的不同。
# 在H2O的DL中，默认情况下启用early stopping，所以下面的训练集中将会默认使用early stopping参数来 进行early stopping。

dl_fit1 <- h2o.deeplearning(x = x,
                            y = y,
                            training_frame = train,
                            model_id = "dl_fit1",
                            seed = 1)
# 用新的结构和更多的epoch训练DL。下面我们通过设置epochs=20来增加epochs,默认为10。
# 通常来说增加epochs深度神经网络的表现会更好。相比较GBM模型，RF通常更加不易过拟合。
# 在下面的GBM例子中你将会看到我们需要额外的设置early stopping来防止过拟合。
# 但是你必须小心，不要过拟合你的数据。你可以通过设置
# 
# early stopping来自动寻找最优的epochs数。
# 与其他H2O中的算法不同，H2O的深度学习算法会默认使用early stopping 
# 所以为了比较我们先不使用 early stopping，通过设置stopping_rounds=0。

dl_fit2 <- h2o.deeplearning(x = x,
                            y = y,
                            training_frame = train,
                            model_id = "dl_fit2", 
                            epochs = 20,
                            hidden= c(10,10),
                            
                            # 禁用 early stopping
                            stopping_rounds = 0, 
                            seed = 1)
# 使用 early stopping来训练DL模型。这次我们会使用跟dl_fit2相同的参数，并在这基础上加上early stopping。
# 通过验证集来进行early stopping。

dl_fit3 <- h2o.deeplearning(x = x,
                            y = y,
                            training_frame = train,
                            model_id = "dl_fit3",
                            epochs = 20,
                            
                            #深度学习中默认使用early stopping
                            validation_frame = valid,     
                            
                            #以下参数用于参数early stopping
                            hidden = c(10,10),
                            score_interval = 1,           
                            stopping_rounds = 3,
                            stopping_metric = "AUC",   
                            stopping_tolerance = 0.0005, 
                            seed = 1)   

#比较一下这3个模型
dl_perf1 <- h2o.performance(model = dl_fit1,
                            newdata = test)
dl_perf2 <- h2o.performance(model = dl_fit2,
                            newdata = test)
dl_perf3 <- h2o.performance(model = dl_fit3,
                            newdata = test)
dl_perf1
dl_perf2
dl_perf3

# 提取验证集AUCh2o.auc(dl_perf1)  
h2o.auc(dl_perf2)  
h2o.auc(dl_perf3)

# 计算历史得分
h2o.scoreHistory(dl_fit3)

# 查看第三个DL模型的历史得分
plot(dl_fit3, timestep = "epochs", metric = "AUC")

#####################           5. 朴素贝叶斯(NB)      ##################

# 朴素贝叶斯算法(NB)在效果上通常会比RF与GBM差，但它仍然是一个受欢迎的算法，
# 尤其在文本领域(例如，当您的输入文本被编码为“词袋”时"Bag of Words")。
# 朴素贝叶斯算法只能用作二分类与多分类任务，不能用作回归。
# 因此响应变量必须是因子类型，不能是数值类型。首先我们使用默认参数来训练一个基础的NB模型。
nb_fit1 <- h2o.naiveBayes(x = x,
                          y = y,
                          training_frame = train,
                          model_id = "nb_fit1")
# 下面我们使用拉普拉斯平滑来训练NB模型。朴素贝叶斯算法的几个可调模型参数之一是拉普拉斯平滑的量。
# 默认情况下不会使用拉普拉斯平滑。

nb_fit2 <- h2o.naiveBayes(x = x,
                          y = y,
                          training_frame = train,
                          model_id = "nb_fit2",
                          laplace = 6)

# 比较2个NB模型
nb_perf1 <- h2o.performance(model = nb_fit1,
                            newdata = test)
nb_perf2 <- h2o.performance(model = nb_fit2,
                            newdata = test)
nb_perf1
nb_perf2

# 提取测试集 AUC
h2o.auc(nb_perf1)  
h2o.auc(nb_perf2)

















