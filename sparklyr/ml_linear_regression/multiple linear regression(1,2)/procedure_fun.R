# judge type of df  to vector
judge_df <- function(df){
  a <- sapply(df,class)
  b <- vector()
  for(i in 1:length(a)){
    if(a[i]=="integer" | a[i]=="numeric"){
      b[i]=T
    }else{
      b[i]=F
    }
  } 
  return(b)
}

# judge_df(train)










