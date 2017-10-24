# install package keras and tensorflow #

----------
## install Anaconda ##

[https://docs.anaconda.com/anaconda/install/](https://docs.anaconda.com/anaconda/install/ "install_anaconda")

    yum install zlib-devel openssl-devel

----------
此后依照提示操作即可（最简便的方式就是，让ENTER就ENTER，问yes或no，输入yes，三个yes分别代表同意license、使用默认的安装路径、自动向.bashrc写入路径) <br>
尽量使用R语言所登录的用户安装，这里默认是rstudio-server登录的dsg用户登录安装到 dsg用户根目录中

    $ wget https://repo.continuum.io/archive/Anaconda3-5.0.0.1-Linux-x86_64.sh
    $ md5sum Anaconda3-5.0.0.1-Linux-x86_64.sh 
    $ bash Anaconda3-5.0.0.1-Linux-x86_64.sh 
    Please, press ENTER to continue
    >>>
    Do you accept the license terms? [yes|no]
    >>> yes
    Anaconda3 will now be installed into this location:
    root/anaconda3
    - Press ENTER to confirm the location
    - Press CTRL-C to abort the installation
    - Or specify a different location below
    >>> 
	installation finished.
	Do you wish the installer to prepend the Anaconda3 install location
	to PATH in your /root/.bashrc ? [yes|no]
	[no] >>> yes
	
	Appending source /root/anaconda3/bin/activate to /root/.bashrc
	A backup will be made to: /root/.bashrc-anaconda3.bak
	
	
	For this change to become active, you have to open a new terminal.
	
	Thank you for installing Anaconda3!
	$ source ~/.bashrc
	$ python3
	>>> 1+1
	>>> quit()

	$ conda install tensorflow
	$ conda install keras

**进入R_terminal运行：**<br>

![](https://i.imgur.com/eJnJ6ZQ.jpg)

    > library(keras)
    > library(reticulate)
    > library(tensorflow)
    > use_condaenv("r-tensorflow")
    > reticulate::use_python("/home/dsg/anaconda3/bin/python")
    > reticulate::use_virtualenv("/home/dsg/anaconda3/lib/python3.6/site-packages/tensorflow")
    > reticulate::py_available()
    [1] TRUE
    > reticulate::py_config()
    python: /home/dsg/anaconda3/bin/python
    libpython:  /home/dsg/anaconda3/lib/libpython3.6m.so
    pythonhome: /home/dsg/anaconda3:/home/dsg/anaconda3
    version:3.6.2 |Anaconda custom (64-bit)| (default, Sep 30 2017, 18:42:57)  [GCC 7.2.0]
    numpy:  /home/dsg/anaconda3/lib/python3.6/site-packages/numpy
    numpy_version:  1.13.1
    keras:  /home/dsg/anaconda3/lib/python3.6/site-packages/keras
    
    python versions found: 
     /home/dsg/anaconda3/bin/python
     /usr/bin/python
    > reticulate::import("keras.models")
    Module(keras.models)
    > reticulate::conda_list()
    [1] name   python
    <0 rows> (or 0-length row.names)
    > # sess <- tf$Session()
    > # hello <- tf$constant('Hello, TensorFlow!')
    > # sess$run(hello)
    > reticulate::py_module_available("keras")
    [1] TRUE
    > data <- dataset_mnist()









































