# 每隔一段时间，我就必须编写一个函数，它包含一个循环，进行上百万次计算。
# 为了确保功能不会陷入无休止的循环，或者仅仅为了满足人类对控制的需要，监视进程是有用的
# 。所以 首先我尝试：
total <- 10
for(i in 1:total){
  print(i)
  Sys.sleep(0.1)
}

# 要么改变R GUI在杂项菜单可以切换通过或告诉R明确通过冲洗空缓冲区缓冲设置。
# console()。像这样，它工作：

total <- 20
for(i in 1:total){
  Sys.sleep(0.1)
  print(i)
  # update GUI console
  flush.console()                          
}

# 这将是更好的有一个真正的进度条。对于不同的进度条，我们可以使用内置的r.utils包。
# 首先，基于文本的进度条：
total <- 20
# create progress bar
pb <- txtProgressBar(min = 0, max = total, style = 3)
for(i in 1:total){
  Sys.sleep(0.1)
  # update progress bar
  setTxtProgressBar(pb, i)
}
close(pb)


# 得到一个GUI的进度条从tcltk包tkprogressbar()功能可以使用。
total <- 20
# create progress bar
require(tcltk)
pb <- tcltk::tkProgressBar(title = "progress bar", min = 0,
                    max = total, width = 300)

for(i in 1:total){
  Sys.sleep(0.1)
  setTkProgressBar(pb, i, label=paste( round(i/total*100, 0),
                                       "% done"))
}
close(pb)



# 使用Windows操作系统的进度条。
pb <- winProgressBar(title = "progress bar", min = 0,
                     max = total, width = 300)

for(i in 1:total){
  Sys.sleep(0.1)
  setWinProgressBar(pb, i, title=paste( round(i/total*100, 0),
                                        "% done"))
}
close(pb)





library(tcltk2)

u <- 1:2000

plot.new()

pb <- tkProgressBar("进度","已完成 %",  0, 100)

for(i in u) {
  
  x<-rnorm(u)
  
  points(x,x^2,col=i)
  
  info <- sprintf("已完成 %d%%", round(i*100/length(u)))
  
  setTkProgressBar(pb, i*100/length(u), sprintf("进度 (%s)", info), info)
  
}

close(pb)#关闭进度条
