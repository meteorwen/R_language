
# https://www.jianshu.com/p/5c8c6b170f6f


library(tesseract)
setwd("orc/")
tesseract_info() #查看当前可用语言格式
tesseract_download("chi_tra")
tesseract_download("chi_sim") #chi_sim和chi_tra均是中文训练数据


text_1<-ocr('eng_2.jpg', engine = tesseract("eng"))
cat(text_1) #输出结果

text_2<-ocr('chi_1.jpg', engine = tesseract("chi_sim"))
cat(text_2) #输出结果

text_3<-ocr('chi_2.jpg', engine = tesseract("chi_sim"))
cat(text_3) #输出结果

text_3<-ocr('chi_2.jpg', engine = tesseract("chi_sim"))
cat(text_3) #输出结果


# 批量提取图片文本内容
temp<-list.files(pattern='*.jpg')  #处理默认路径下jpg格式图片
text<-ocr(temp, engine = tesseract("chi_tra"))
cat(text)