# R_language
## R的一些基础练习与操作和一些常用包的操作练习


# Install R 
## Install in Linux platform

    $ sudo yum install epel-release
    $ sudo yum update
    $ sudo yum install R
## Install in CentOS (integrant install packages)
    
    $ sudo yum install libcurl-devel
    $ sudo yum install openssl-devel
    $ sudo yum install libxml2-devel

# Creat users and insert sudoers

    $ sudo adduser apple
    $ sudo passwd apple
    vm /etc/sudoers 找到 root ALL=(ALL) ALL 在这行下边添加 dsg ALL=(ALL) ALL

# Install rstudio-server 
[官网链接地址](https://www.rstudio.com/products/rstudio/download-server/)


**1. 64bit Install**

    $ wget https://download2.rstudio.org/rstudio-server-rhel-1.1.383-x86_64.rpm
    $ sudo yum install --nogpgcheck rstudio-server-rhel-1.1.383-x86_64.rpm

*2. 32bit Install*

    $ wget https://download2.rstudio.org/rstudio-server-rhel-1.1.383-x86_64.rpm
    $ sudo yum install --nogpgcheck rstudio-server-rhel-1.1.383-x86_64.rpm

## Start Rstudio Server
	
	sudo iptables -I INPUT -p tcp --dport 8787 -j ACCEPT # 有可能防火墙未打开8787端口，需要手动开启
    #查看是否安装正确
    sudo rstudio-server verify-installation
    
    ## 启动
    sudo rstudio-server start
    
    ## 查看状态
    sudo rstudio-server status
    
    ## 停止
    sudo rstudio-server stop

	$ sudo rstudio-server active-sessions 
	$ sudo rstudio-server suspend-session <pid>
	$ sudo rstudio-server suspend-all
	$ sudo rstudio-server offline # 会给当前连接用户下线提示
	$ sudo rstudio-server online
    
    ## 查看服务端ip地址
    ifconfig
    
用google浏览器打开http://you.ip:8787
然后输入用户名和密码，和登录服务器时的用户名和密码一致。

## R packages （[安装r包能让所有用户使用](https://cloud.r-project.org/)）
强烈建议使用root用户或者`sudo R`进入R安装各种包，使包能被安装至
`/usr/lib64/R/library/`

多数包可以通过:<br>
```
install.packages("ggplot2",repos = "http://cran.rstudio.com/",lib ="/usr/lib64/R/library/")
```
的方式安装，但是有的包如Rcpp或者httpuv等还是会报无法编译的错，可以先查看:

    yum list R-\

是否包含需要安装的包，如果有就直接`yum install PACKAGE_NAME`，此外也可以使用如下办法安装： 

    wget http://cran.r-project.org/src/contrib/Rcpp_0.11.1.tar.gz
    sudo R CMD INSTALL --build Rcpp_0.11.1.tar.gz
    
    wget http://cran.r-project.org/src/contrib/httpuv_1.2.3.tar.gz
    sudo R CMD INSTALL --build httpuv_1.2.3.tar.gz 

Fedora提供了一些r软件包的选择。更有限这些软件包的选择已经被移植到了。rpm的名字是
通过添加前缀“r-”从r包名得到。因此全部r-related rpms可以用yum命令列出

`yum list R-\*`

### [shiny-server的安装](https://www.rstudio.com/products/rstudio/download-server/)

    sudo su - \
    -c "R -e \"install.packages('shiny', repos='https://cran.rstudio.com/')\""
    $ wget https://download3.rstudio.org/centos5.9/x86_64/shiny-server-1.5.6.875-rh5-x86_64.rpm
    $ sudo yum install --nogpgcheck shiny-server-1.5.6.875-rh5-x86_64.rpm
	$ sudo start shiny-server
	$ sudo stop shiny-server
	$ sudo restart shiny-server # restart模式不会读取/etc/init/shiny-server.conf中的改动