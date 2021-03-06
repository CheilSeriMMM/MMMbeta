geneqs = function(){
  
  Est <- parameterEstimates(model_fit)
  depVar <- Est$lhs[1]   
  numOfeq <- length(model)
  
  
  makes<-subset(Est, op=='~' | ((op=='~1') & se>0), select=c(lhs, op, rhs, est)) 
  makes$rhs[makes$op=='~1'] <- 'nomeans' 
  makes$est_ <- paste('(', makes$est, ')', sep='') 
  makes$est_1 <- paste(makes$est_, makes$rhs, sep='*') 
  makes$est_1[makes$op=='~1'] <- gsub("[*]nomeans", "", makes$est_1[makes$op=='~1']) 
  
  equationset<-ddply(makes, .(lhs), summarise, equat =paste(est_1, collapse='+')) 
  equationset$equat <- paste("(", equationset$equat, ")", sep="") 
  
  mains<-equationset[equationset$lhs == depVar, 'equat'] 
  mainregressor<-makes[,'rhs'] 
  mainregressor <- rep(mainregressor, numOfeq*2) 
  regressors<-setdiff(setdiff(unique(makes$rhs),unique(makes$lhs)), "nomeans") 
  
  for(i in c(1:length(mainregressor))){ 
    
    elimin <- mainregressor[i] 
    eq_substs <- equationset[equationset$lhs == elimin, 'equat'] 
    
    
    if (length(eq_substs) != 0){ 
      mains_pre <- mains 
      mains<-gsub(elimin, eq_substs, mains) 
    }   
  }
  
  formula <- mains 
  indpvar <- regressors 
  
  coeffmtx <- data.frame(diag(1, length(indpvar), length(indpvar))) 
  colnames(coeffmtx)<-indpvar 
  coeffmtx0 <- data.frame(t(rep(0, length(indpvar)))) 
  colnames(coeffmtx0)<-indpvar 
  constant<-with(coeffmtx0, eval(parse(text=formula))) 
  coefset<-data.frame(var=indpvar, coef=with(coeffmtx, eval(parse(text=formula)))-constant,stringsAsFactors = F)
  
  
  
  a=paste0("ln",ratiolist)
  
  nu_atl_tmp<- intersect(atllist, gsub("ln","",indpvar))
  
  nu_atl<-NULL
  for(i in 1:length(nu_atl_tmp)){
    aa<-nu_atl_tmp[i]
    if(aa%in%grplist){
      nu_atl<-c(nu_atl, paste0(aa,"*",paste0(sub("grp_","",aa),"pricepergrp")))
    }else {
      nu_atl<-c(nu_atl,aa)
    }
    
  } 
  
  nu_atl<-paste(nu_atl,collapse = "+")
  nu_digital<-paste(intersect(digitallist, gsub("ln","",indpvar)),collapse = "+")
  nu_btl<-paste(intersect(btllist, gsub("ln","",indpvar)),collapse = "+")
  
  
  pp= intersect(a,c('lnratio_atl_tocomp', 'lnratio_btl_tocomp', 'lnratio_digital_tocomp'))
  
  
  nulist=NULL
  denolist=NULL
  
  for(i in 1:length(a)){
    nu_tmp=sub("lnratio_","",a[i])
    nu_tmp=sub("_tocomp","",nu_tmp) 
    if(nu_tmp%in%c("atl","btl","digital")){
    nulist=c(nulist,get(paste0("nu_",nu_tmp)))  
    } else{
      nulist=c(nulist,nu_tmp)
    }
    denolist=c(denolist,paste0("comp_",nu_tmp))
  }
  
  
  a1=data.frame(denominator=denolist,
                numerator=nulist,
                var=rep(a,stringsAsFactors=F))
  
  
  
  
  temp1=coefset[!coefset$var %in% a,]
  temp2=coefset[coefset$var %in% a,]
  
  for(i in 1:nrow(temp2)){
    temp<-a1[a1$var==temp2[i,1],]
    temp2[i,"numerator"]<-paste0("log","(",temp[,"numerator"],")")
    temp2[i,"denominator"]<-paste0("log","(",temp[,"denominator"],")")
  }
  
  
  temp1$coef_new=paste0("(",temp1[,"coef"],")")
  temp1$mult=paste(temp1[,"coef_new"],temp1[,1],sep="*")
  
  
  equation_temp1=paste(temp1$mult,collapse="+")
  
  
  temp2$coef_new=paste0("(",temp2[,"coef"],")")
  temp2$mult=paste(temp2[,"coef_new"],"*",temp2[,"numerator"],"-",temp2[,"coef_new"],"*",temp2[,"denominator"],sep="")
  equation_temp2=paste(temp2$mult,collapse="+")
  
  
  
  equation_temp<-paste0(equation_temp1,"+",equation_temp2)
  equation=paste(equation_temp,constant,sep="+")
  
  resltset<-list() 
  resltset$formula <- equation 
  resltset$coefset <- coefset
  resltset$eqs<-equationset$equat
  
  assign('resltset',resltset, envir = .GlobalEnv)
  
  assign('depvar',depVar,envir = .GlobalEnv)
  assign('full_equation',equation,envir = .GlobalEnv)
  assign('inputvar',intersect(setdiff(gsub("ln","",regressors),ratiolist),medialist),equation,envir = .GlobalEnv)
  
  return(resltset)
 }
  
  
