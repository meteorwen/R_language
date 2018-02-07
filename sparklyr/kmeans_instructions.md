# install R #
## centOS Installation of the necessary packages on the platform
    $ sudo yum install libcurl-devel
    $ sudo yum install openssl-devel
    $ sudo yum install libxml2-devel

## Linux Platform installation

    $ sudo yum install epel-release
    $ sudo yum update
    $ sudo yum install R

## package install

**install.packages('PACKAGE_NAME', repos = 'http://cran.rstudio.com/')**

    install.packages('sparklyr',repos = 'http://cran.rstudio.com/')
    install.packages('dplyr',repos = 'http://cran.rstudio.com/')
    install.packages('magrittr',repos = 'http://cran.rstudio.com/')

----------
# install rhadoop
    install.packages("rJava ")

## install rhdfs

    wget https://github.com/RevolutionAnalytics/rhdfs/blob/master/build/rhdfs_1.0.8.tar.gz
    > install.packages("/root/r_packages_download/rhdfs_1.0.8.tar.gz", repos=NULL, type="source")
 
## install 
----------
# install H2O 

    yum install -y  R-devel.x86_64 libcurl-devel.x86_64
    > library(h2o)
    > demo(h2o.glm)

----------


# dsg sparklyr function #

----------

## ml_kmeans ##

    ml_kmeans(x,
    			centers, 
    			iter.max = 100,
    			features = tbl_vars(x),
      			compute.cost = TRUE,
    			tolerance = 1e-04, 
    			ml.options = ml_options(), ...)
### Arguments


1. x	： 一个可以对Spark DataFrame（通常为a tbl_spark）强制的对象 。
2. centers	： 要计算的集群中心数。
3. iter.max	：	要使用的最大迭代次数。
4. features	： 用于模型的功能（术语）的名称适合。	
5. compute.cost	：是否k-means使用Spark的computeCost计算模型的成本。
6. tolerance	：Param为迭代算法的收敛公差。
7. ml.options	：可选参数，用于影响生成的模型。查看 ml_options更多详情。

## Execute Script
### training
    sudo -udsg Rscript kmeans_model.R hdfs:///user/dsg/iris/iris1.csv hdfs:///user/dsg/model/ kmeans_model1 3 10
### predicting
	sudo -udsg Rscript kmeans_predict.R hdfs:///user/dsg/model/ kmeans_model4.rda hdfs:///user/dsg/iris/iris2.csv 


# note
训练集数据与测试集数据结构必须一样，尤其是列名必须一致，最好lab列名指定为“lab”