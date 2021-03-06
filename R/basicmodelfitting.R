basicmodelfitting = function(){
  
  library(reshape2)
  library(ggplot2)
 resltset<-geneqs()
  
  y_hat=with(stockeddata, exp(eval(parse(text=resltset$eqs[1]))))
    
  temp=data.frame(time=c(1:length(y_hat)),y=exp(stockeddata[,depvar]),y_hat=y_hat)
  temp_melt=melt(temp,id='time')
    
    ggplot()+
      geom_line(aes(x=time, y=value, colour=variable), data=temp_melt, stat="identity") +
      ggtitle("모델 정확도") + 
      theme(legend.position="right", legend.direction="vertical", legend.title = element_blank()) +
      labs(fill="") +
      labs(x='time', y="sales amount") +
      theme_bw() +
      theme(axis.line = element_line(size=1, colour = "black"), panel.grid.major = element_blank(),
            panel.grid.minor = element_blank(), panel.border = element_blank(),
            panel.background = element_blank())
    
  }
