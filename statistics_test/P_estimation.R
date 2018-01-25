#*****************
#本程序利用R分布别做出单个、双个正态分布总体
#区间估计的均值和双侧、单侧置信区间
#包含4个函数
#*****************

#单个正态分布
#u的区间估计，sigma已知
onenorm_u_sigma<-function(X,sigma,alpha=0.99){
  n<-length(X);
  tmpx<-sigma*qnorm(1-alpha/2)/sqrt(n);
  a<-mean(X)-tmpx;b<-mean(X)+tmpx;#双侧
  cat("其",alpha*100,"%双侧置信区间是：[",a,",",b,"]","\n")
  
  bu<-mean(X)+sigma*qnorm(1-alpha)/sqrt(n)#单侧上限
  ad<-mean(X)-sigma*qnorm(1-alpha)/sqrt(n)#单侧下限
  cat("其",alpha*100,"%单侧置信区间上限是：",bu,"\n下限是",ad,"\n")
}

#u的区间估计，sigma未知
onenorm_u_sd<-function(X,alpha=0.99){
  n<-length(X);
  tmpx<-sd(X)*qt(1-alpha/2,n-1)/sqrt(n);
  a<-mean(X)-tmpx;b<-mean(X)+tmpx;#双侧
  cat("其",alpha*100,"%双侧置信区间是：[",a,",",b,"]","\n")
  
  bu<-mean(X)+sd(X)*qt(1-alpha,n-1)/sqrt(n)#单侧上限
  ad<-mean(X)-sd(X)*qt(1-alpha,n-1)/sqrt(n)#单侧下限
  cat("其",alpha*100,"%单侧置信区间上限是：",bu,"\n下限是",ad,"\n")
}

#sigma的区间估计，u已知
onenorm_sigma_u<-function(X,u,alpha=0.99){
  n<-length(X);
  a<-sum((X-u)^2)/qchisq(1-alpha/2,n);
  b<-sum((X-u)^2)/qchisq(alpha/2,n);#双侧
  cat("其",alpha*100,"%双侧置信区间是：[",a,",",b,"]","\n")
  
  bu<-sum((X-u)^2)/qchisq(alpha,n)#单侧上限
  ad<-sum((X-u)^2)/qchisq(1-alpha,n)#单侧下限
  cat("其",alpha*100,"%单侧置信区间上限是：",bu,"\n下限是",ad,"\n")
}

#sigma的区间估计，u未知
onenorm_sigma_sd<-function(X,alpha=0.99){
  n<-length(X);
  a<-(n-1)*sd(X)^2/qchisq(1-alpha/2,n-1);
  b<-(n-1)*sd(X)^2/qchisq(alpha/2,n-1);#双侧
  cat("其",alpha*100,"%双侧置信区间是：[",a,",",b,"]","\n")
  
  bu<-(n-1)*sd(X)^2/qchisq(alpha,n-1)#单侧上限
  ad<-(n-1)*sd(X)^2/qchisq(1-alpha,n-1)#单侧下限
  cat("其",alpha*100,"%单侧置信区间上限是：",bu,"\n下限是",ad,"\n")
}

##两个正态分布
#u1-u2的区间估计，sigma1,sigma2已知
twonorm_du_sigma<-function(X,Y,sigma1,sigma2,alpha=0.99){
  m<-length(X);
  n<-length(Y);
  tmp<-sqrt(sigma1^2/m+sigma2^2/n)*qnorm(1-alpha/2);
  a<-mean(X)-mean(Y)-tmp;
  b<-mean(X)-mean(Y)+tmp;#双侧
  cat("其",alpha*100,"%双侧置信区间是：[",a,",",b,"]","\n")
  
  bu<-mean(X)-mean(Y)+sqrt(sigma1^2/m+sigma2^2/n)*qnorm(1-alpha);#单侧上限
  ad<-mean(X)-mean(Y)-sqrt(sigma1^2/m+sigma2^2/n)*qnorm(1-alpha);#单侧下限
  cat("其",alpha*100,"%单侧置信区间上限是：",bu,"\n下限是",ad,"\n")
}

#u1-u2的区间估计，sigma1,sigma2未知
twonorm_du_sd<-function(X,Y,alpha=0.99){
  m<-length(X);
  n<-length(Y);
  Sw<-sqrt((m-1)*sd(X)^2+(n-1)*sd(Y)^2)/(m+n-2);
  tmp<-Sw*sqrt(1/m+1/n)*qt(1-alpha/2,m+n-2);
  a<-mean(X)-mean(Y)-tmp;
  b<-mean(X)-mean(Y)+tmp;#双侧
  cat("其",alpha*100,"%双侧置信区间是：[",a,",",b,"]","\n")
  
  bu<-mean(X)-mean(Y)+Sw*sqrt(1/m+1/n)*qt(1-alpha,m+n-2);#单侧上限
  ad<-mean(X)-mean(Y)-Sw*sqrt(1/m+1/n)*qt(1-alpha,m+n-2);#单侧下限
  cat("其",alpha*100,"%单侧置信区间上限是：",bu,"\n下限是",ad,"\n")
}

#sigma1^2/sigma2^2的区间估计，u1,u2已知
twonorm_sigma_u<-function(X,Y,u1,u2,alpha=0.99){
  m<-length(X);
  n<-length(Y);
  numerator<-n*sum((X-u1)^2)/m/sum((Y-u2)^2);
  a<-numerator/qf(1-alpha/2,m,n)
  b<-numerator/qf(alpha/2,m,n)#双侧
  cat("其",alpha*100,"%双侧置信区间是：[",a,",",b,"]","\n")
  
  bu<-numerator/qf(alpha,m,n)#单侧上限
  ad<-numerator/qf(1-alpha,m,n)#单侧下限
  cat("其",alpha*100,"%单侧置信区间上限是：",bu,"\n下限是",ad,"\n")
}

#sigma1^2/sigma2^2的区间估计，u1,u2未知
twonorm_sigma_sd<-function(X,Y,alpha=0.99){
  m<-length(X);
  n<-length(Y);
  numerator<-sd(X)^2/sd(Y)^2;
  a<-numerator/qf(1-alpha/2,m-1,n-1)
  b<-numerator/qf(alpha/2,m-1,n-1)#双侧
  cat("其",alpha*100,"%双侧置信区间是：[",a,",",b,"]","\n")
  
  bu<-numerator/qf(alpha,m-1,n-1)#单侧上限
  ad<-numerator/qf(1-alpha,m-1,n-1)#单侧下限
  cat("其",alpha*100,"%单侧置信区间上限是：",bu,"\n下限是",ad,"\n")
}




xx<-c(159,158,164,169,161,161,160,157,158,163,161,154,166,168,159)

x <- c(6.48,4.00,5.54,6.89,5.14,4.60,3.67,4.32,4.80,7.50)
y <- c(4.16,10.77,9.08,5.95,6.36,3.77,5.18,6.76,3.86,3.63)






























