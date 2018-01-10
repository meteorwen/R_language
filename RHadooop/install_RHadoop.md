# install rhadoop
    install.packages("rJava")
## /etc/profile 
 
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


## install rhdfs
	$ yum install -y gcc-gfortran gcc gcc-c++ readline-devel libXt-devel
    $ wget https://github.com/RevolutionAnalytics/rhdfs/blob/master/build/rhdfs_1.0.8.tar.gz
	RMR2 (每个跑Mapreduce 的 Nodemanager都要安装)
	$ R
	install.packages("stringr",repos='http://cran.us.r-project.org/',dependencies=TRUE)
	install.packages("Rcpp", repos='http://cran.us.r-project.org/',dependencies=TRUE)
	install.packages("RJSONIO",repos='http://cran.us.r-project.org/',dependencies=TRUE)
	install.packages("bitops", repos='http://cran.us.r-project.org/',dependencies=TRUE)
	install.packages("digest", repos='http://cran.us.r-project.org/',dependencies=TRUE)
	install.packages("functional", repos='http://cran.us.r-project.org/',dependencies=TRUE)
	install.packages("plyr", repos='http://cran.us.r-project.org/',dependencies=TRUE)
	install.packages("reshape2", repos='http://cran.us.r-project.org/',dependencies=TRUE)
	install.packages("caTools", repos='http://cran.us.r-project.org/',dependencies=TRUE)
    install.packages("rhdfs_1.0.8.tar.gz", repos=NULL, type="source")