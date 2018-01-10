# [install rhadoop](https://github.com/RevolutionAnalytics/RHadoop/wiki)
# 系统要求

官方支持的平台。<br>

- RedHat®EnterpriseLinux®6.5（64位）

支持的Hadoop集群。<br>

- Cloudera CDH 5
- Hortonworks HDP 2.1    

RHadoop是五个R包的集合，允许用户使用Hadoop管理和分析数据。这些软件包已经在最近发布的Cloudera和Hortonworks Hadoop发行版上进行了测试（并且始终在发行之前），并且应该与开源Hadoop和mapR的发行版具有广泛的兼容性。我们通常会测试最近的Revolution R / Microsoft R和CentOS发行版，但是我们希望所有的RHadoop软件包都可以在最近的R和Linux版本上运行。<br>
RHadoop由以下软件包组成：<br>

|names|DESCRIPTION|
|----------|-----------|
|[rhdfs](https://github.com/RevolutionAnalytics/RHadoop/wiki/user%3Erhdfs%3EHome)	|该软件包提供了Hadoop分布式文件系统的基本连接。R程序员可以从R中浏览，读取，写入和修改存储在HDFS中的文件。仅在将运行R客户机的节点上安装此程序包。|
|[rhbase](https://github.com/RevolutionAnalytics/RHadoop/wiki/user%3Erhbase%3EHome)	|该软件包使用Thrift服务器提供与HBASE分布式数据库的基本连接。R程序员可以从R中浏览，读取，写入和修改存储在HBASE中的表。仅在将运行R客户机的节点上安装此程序包。|
|[plyrmr](https://github.com/RevolutionAnalytics/RHadoop/wiki/user%3Eplyrmr%3EHome)	|这个软件包使得将R用户执行常见的数据操纵操作，如在流行软件包，如发现plyr和reshape2，对存储在Hadoop非常大的数据集。就像rmr，它依靠Hadoop MapReduce来执行它的任务，但它提供了一个熟悉plyr的界面，同时隐藏了许多MapReduce的细节。仅安装此软件包中的每个节点。|
|rmr2	|一个允许R开发人员通过Hadoop集群上的Hadoop MapReduce功能在R中执行统计分析的软件包。在群集中的每个节点上安装此软件包。|
|[ravro](https://github.com/RevolutionAnalytics/RHadoop/wiki/user%3Eravro%3EHome)|一个包，它增加了avro从本地和HDFS文件系统读取和写入文件的能力，并添加了一个avro输入格式rmr2。仅在将运行R客户端的节点上安装此软件包。|


## vi /etc/profile 
```
	export JAVA_HOME=/usr/java/jdk1.8
	export JRE_HOME=$JAVA_HOME/jre
	export CLASSPATH=$CLASSPATH:$JAVA_HOME/lib:$JRE_HOME/lib:$HADOOP_HOME/lib
	export PATH=$JAVA_HOME/bin:$PATH:$JRE_HOME/bin
	export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/java/jdk1.7/jre/lib/amd64/server
	
	export HADOOP_HOME=/opt/cloudera/parcels/CDH-5.8.5-1.cdh5.8.5.p0.5/lib/hadoop/
	export YARN_CONF_DIR=$HADOOP_HOME/etc/hadoop
	export HADOOP_CONF_DIR=/etc/hadoop/conf
	export HADOOP_CMD=/opt/cloudera/parcels/CDH-5.8.5-1.cdh5.8.5.p0.5/bin/hadoop
	export HADOOP_STREAMING=/opt/cloudera/parcels/CDH-5.8.5-1.cdh5.8.5.p0.5/lib/hadoop-mapreduce/hadoop-streaming-2.6.0-cdh5.8.5.jar
	export JAVA_LIBRARY_PATH=/opt/cloudera/parcels/CDH-5.8.5-1.cdh5.8.5.p0.5/lib/hadoop/lib/native/
	export HADOOP_OPTS="$HADOOP_OPTS -Djava.library.path=/opt/cloudera/parcels/CDH-5.8.5-1.cdh5.8.5.p0.5/lib/hadoop/lib/native/"
	export R_LIBS=/usr/lib64/R/library/
```
## [Downloader](https://github.com/RevolutionAnalytics/RHadoop/wiki/Downloads)

### install rJava
重要！ 如果rJava的安装失败，则可能需要将R配置为使用Java正确运行。<br>首先，检查一下你是否安装了Java JDK，环境变量JAVA_HOME是否指向Java JDK。<br>要将R配置为使用Java运行，请键入命令：**R CMD javareconf**，然后再次尝试安装rJava。

**[Installing RHadoop on RHEL](https://github.com/RevolutionAnalytics/RHadoop/wiki/Installing-RHadoop-on-RHEL)**
### [install rmr2](https://github.com/RevolutionAnalytics/rmr2/releases/download/3.3.1/rmr2_3.3.1.tar.gz)
1. download rmr2
2. 以下说明适用于安装和配置rmr2。
3. 安装rmr2及其相关的R包。
4. 更新所需的环境变量rmr2。环境的值将取决于您的Hadoop发行版。

重要！这些环境变量只需要在调用rmr2MapReduce作业的节点上设置，如Edge节点。如果您不知道将使用哪个节点，请在每个节点上设置这些变量。另外，建议将这些环境变量添加到文件中，/etc/profile以便它们可供所有用户使用。

- HADOOP_CMD：“hadoop”可执行文件的完整路径。例如：
`
    export HADOOP_CMD=/usr/bin/hadoop
`
- HADOOP_STREAMING：Hadoop Streaming jar文件的完整路径。例如：
`
	export HADOOP_STREAMING=/usr/lib/hadoop/contrib/streaming/hadoop-streaming-<version>.jar
`
在群集中的每个节点上，执行以下操作：
`
	$ wget https://github.com/RevolutionAnalytics/RHadoop/wiki/user%3Ermr%3EHome
`
### install rhdfs (rhdfs仅安装在将运行R客户机的节点上)
```
	$ yum install -y gcc-gfortran gcc gcc-c++ readline-devel libXt-devel
    $ wget https://github.com/RevolutionAnalytics/rhdfs/blob/master/build/rhdfs_1.0.8.tar.gz
	RMR2 (每个跑Mapreduce 的 Nodemanager都要安装)
	$ R
	install.packages(c('stringr',"Rcpp","Rcpp","RJSONIO","bitops","digest","functional","plyr","reshape2","caTools"),
	repos='http://cran.us.r-project.org/',dependencies=TRUE)
    install.packages("rhdfs_1.0.8.tar.gz", repos=NULL, type="source")
```
#### example rhdfs
概述该R包提供了与Hadoop分布式文件系统的基本连接。R程序员可以浏览，读取，写入和修改存储在HDFS中的文件。以下功能是这个软件包的一部分:<br>
1. 文件操作<br>
hdfs.copy，hdfs.move，hdfs.rename，hdfs.delete，hdfs.rm，hdfs.del，hdfs.chown，hdfs.put，hdfs.get<br>
2. 文件读/写<br>
hdfs.file，hdfs.write，hdfs.close，hdfs.flush，hdfs.read，hdfs.seek，hdfs.tell，hdfs.line.reader，hdfs.read.text.file<br>
3. 目录<br>
hdfs.dircreate，hdfs.mkdir<br>
4. 实用程序<br>
hdfs.ls，hdfs.list.files，hdfs.file.info，hdfs.exists<br>
5. 初始化<br>
hdfs.init，hdfs.defaults<br>
```
    > library(rhdfs)
    > hdfs.init()
    > hdfs.ls("/")
```
这个包依赖于rJava
通过这个R包访问HDFS取决于HADOOP_CMD环境变量。HADOOP_CMD指向hadoop二进制文件的完整路径。如果这个变量没有被正确的设置，那么当这个init()函数被调用的时候，这个包会失败,例：

 	HADOOP_CMD=/usr/bin/hadoop

R对象可以通过函数将R对象序列化为HDFS hdfs.write。一个例子如下所示：
``` 
    model <- lm(...)
    modelfilename <- "my_smart_unique_name"
    modelfile <- hdfs.file(modelfilename, "w")
    hdfs.write(model, modelfile)
    hdfs.close(modelfile)
```
R对象可以通过函数进行反序列化到HDFS： hdfs.read。一个例子如下所示：
```
    modelfile = hdfs.file(modelfilename, "r")
    m <- hdfs.read(modelfile)
    model <- unserialize(m)
    hdfs.close(modelfile)
```
### install rhbase
https://github.com/RevolutionAnalytics/RHadoop/wiki/user%3Erhbase%3EHome
以下说明适用于安装和配置rhdfs。

在将运行R客户端的节点上，执行以下操作：<br>
1. 构建并安装Apache Thrift。我们建议您在包含HBase Master的节点上安装。有关构建和安装Thrift的更多详细信息，请参阅http://thrift.apache.org/。<br> 
2. 安装Thrift的依赖关系。在提示符下键入：
```
    yum -y install automake libtool flex bison pkgconfig gcc-c++ boost-devel libevent-devel zlib-devel python-devel ruby-devel openssl-devel
```
**重要！ 如果安装为NON-ROOT，则需要系统管理员来帮助安装这些依赖关系。**<br>

3. [下载Thrift档案](http://archive.apache.org/dist/thrift/0.8.0/thrift-0.8.0.tar.gz)<br>
解压Thrift档案。在提示符下键入：<br>

	tar -xzf thrift-0.8.0.tar.gz
	cd thrift-0.8.0
	./configure --without-ruby --without-python
	make
	make install

**非常重要！**如果以非根用户身份进行安装，那么该命令很可能需要root权限，并且必须由系统管理员执行。<br>
创建一个到Thrift库的符号链接，以便它可以被rhbase包加载。符号链接示例：<br>
`
    ln -s /usr/local/lib/libthrift-0.8.0.so /usr/lib64
`
**重要！**如果以非根用户身份进行安装，则可能需要系统管理员为您执行此命令。

设置PKG_CONFIG_PATH环境变量。在提示符下键入：
`
export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/usr/local/lib/pkgconfig
`
1. [下载rhbase软件包。](https://github.com/RevolutionAnalytics/RHadoop/wiki/Downloads)
2. rhbase仅安装在将运行R客户机的节点上。
```
library(rhbase)
hb.init()
hb.list.tables()
```