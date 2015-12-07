setwd('/Users/Joe/Documents/Digital Archelogy/Amazon')

setwd('/Users/T84100/Dropbox/Digital Archelogy')

library(stringr)
if(require('stringr')==FALSE)  install.packages('stringr') ; require('stringr')
if(require('wordcloud')==FALSE)  install.packages('wordcloud') ; require('wordcloud')
if(require('dummy')==FALSE)  install.packages('dummy') ; require('dummy');
if (require('dplyr')==FALSE) install.packages('dplyr');require('dplyr');
if(require('lift')==FALSE)  install.packages('lift') ; require('lift');
if(require('AUC')==FALSE) install.packages('AUC'); require('AUC')
if(require('randomForest')==FALSE) install.packages('randomForest'); require('randomForest')


data <- read.csv('exampleData.csv',header=TRUE,sep=",",stringsAsFactors=FALSE)
source("functions_for_Text_and_Network_Mining(1).R")

t <- table(data$itemCategory); t <- t[order(-t)];

IC <- "Toys & Games"

cat <- data[which(data$itemCategory == IC),]


cat$Summary <- sapply(cat$Summary,function(x) tolower(x))
cat$itemTitle <- sapply(cat$itemTitle,function(x) tolower(x))
cat$itemBrand <- sapply(cat$itemBrand,function(x) tolower(x))
cat$Description <- sapply(cat$Description, function(x) tolower(x))
cat$Description <- sapply(cat$Description, function(x) substr(x,1,200))


#STEP 1: create document by term matrix
sdoc_term_mat <- create_document_term_matrix(cat$Summary)
ddoc_term_mat <- create_document_term_matrix(cat$Description)
itemTitledoc_term_mat <- create_document_term_matrix(cat$itemTitle)
branddoc_term_mat <- create_document_term_matrix(cat$itemBrand)
#investigate output
#doc_term_mat
#inspect(doc_term_mat)

#STEP 2: create adjacency matrix
sadj_mat <- create_adjacency_matrix(sdoc_term_mat)
titleadj_mat <- create_adjacency_matrix(itemTitledoc_term_mat)
brand_adj_mat <- create_adjacency_matrix(branddoc_term_mat)
dadj_mat <- create_adjacency_matrix(ddoc_term_mat)

#adj_mat[[1]][1:10,1:10]


wordAnalysis <- function(x){
  
  size <- sqrt(length(x[[1]]))
  a <- data.frame(x[[1]][1:size,1:size])
  a <- sapply(a,sum); a <- a[order(-a)];
  b <- a[1:size]
  c <- as.numeric(b)
  slist <- names(b)[1:10]
  wc <- wordcloud(names(b),c,scale=c(4,.5),max.words=Inf,random.order=TRUE,
                   random.color=TRUE,color="black")

  net <- plot_network(x)
  return(list(slist,wc,net))
  
}

newlist <- wordAnalysis(sadj_mat); slist <- newlist[[1]]; 
newlist <- wordAnalysis(dadj_mat); dlist <- newlist[[1]]
newlist <- wordAnalysis(titleadj_mat); title_list <- newlist[[1]]
newlist <- wordAnalysis(brand_adj_mat); brand_list <- newlist[[1]]

##### run for loop to make predictors
countWord <- function(wordVector,wordList,type){
  TEMP <- data.frame()
  for(i in 1:length(wordList)){
    if(i==1){
      TEMP <- sapply(gregexpr(wordList[i],wordVector,fixed=TRUE),
                             function(x) sum(x > -1))
    }else{
      temp2 <- sapply(gregexpr(wordList[i],wordVector,fixed=TRUE),
                     function(x) sum(x > -1))
      TEMP <- cbind(TEMP,temp2)
    }
  }
  v <- NULL; for(i in 1:length(wordList)){v[i] <- paste(wordList[i],type,sep="_")};
  colnames(TEMP)[1:10] <- v
  return(TEMP)
}

SummaryWords <- countWord(cat$Summary,slist,"Summary")
DescWords <- countWord(cat$Description,dlist,"Desc")
TitleWords <- countWord(cat$itemTitle,title_list,"title")
BrandWords <- countWord(cat$itemBrand,brand_list,"brand")



################################

####################### merge back on to orginal data #########

cat <- cbind(cat,SummaryWords); cat <- cbind(cat,DescWords)
cat <- cbind(cat,TitleWords); cat <- cbind(cat,BrandWords)

#### format Price
cat$itemPrice <- substr(cat$itemPrice,2,7);cat$itemPrice <- as.numeric(cat$itemPrice); 
cat$itemPrice[is.na(cat$itemPrice)] <- 0

### format date and make recency
temp2 <- NULL
temp3 <- as.Date('2001-01-01')
for(i in 1:length(cat$dateReviewed)){
temp2 <- if(is.na(as.Date(cat$dateReviewed[i],format = "%B %d, %Y")))
                {as.Date(cat$dateReviewed[i],format="%d-%b-%y")}else
                {as.Date(cat$dateReviewed[i],format = "%B %d, %Y")}
temp3[i] <- temp2
}
cat$Recency <- sapply(temp3,function(x) Sys.Date()-x)


cat$y <- cat$Rating; cat$y <- sapply(cat$y,function(x)ifelse(x==5,1,0)); cat$y <- as.factor(cat$y)
cat  <- cat[,!names(cat) %in% c("reviewerName","reviewerUrl","itemNo","itemTitle","itemUrl",
                                "itemBrand","itemCategory","Summary","Description",
                                "dateReviewed","Rating")]
BaseTable <- cat


allind <- sample(x=1:nrow(BaseTable),size=nrow(BaseTable))
#split in three parts 
trainind <- allind[1:round(length(allind)/3)]
valind <- allind[(round(length(allind)/3)+1):round(length(allind)*(2/3))]
testind <- allind[round(length(allind)*(2/3)+1):length(allind)]


intersect(trainind,valind)
intersect(trainind,testind)
intersect(valind,testind)

colnames(BaseTable)
dim(BaseTable)[2]

xTRAIN <- BaseTable[trainind,-c(1,dim(BaseTable)[2])]
yTRAIN <- BaseTable[trainind,dim(BaseTable)[2]]
xVAL <- BaseTable[valind,-c(1,dim(BaseTable)[2])]
yVAL <- BaseTable[valind,dim(BaseTable)[2]]
xTEST <- BaseTable[,-c(1,dim(BaseTable)[2])]
yTEST <- BaseTable[,dim(BaseTable)[2]]
xBIG <- rbind(xTRAIN,xVAL)
yBIG <- append(yTRAIN,yVAL)
yBIG <- as.factor(yBIG)



##### Modeling  #########################
##########################################################################################################

#create a first random forest model
rFmodel <- randomForest(x=xTRAIN,
                        y=yTRAIN,  
                        ntree=1000,
                        xtest=xTEST, ytest=yTEST,
                        importance=TRUE)

numtrees <- which.min(rFmodel$test$err.rate[,1])
rFmodel2 <- randomForest(x=xTRAIN,y=yTRAIN,  ntree=numtrees, importance=TRUE)

output.object <- list(model = rFmodel2,categories = tempcat, ind_length = difftime(end_ind,start_ind,unit = "days"), 
                      dep_length = difftime(end_dep,start_dep,unit = "days"))

importance(rFmodel2)[,"MeanDecreaseAccuracy"]

list <- importance(rFmodel2)[,"MeanDecreaseAccuracy"]
list <- list[order(list)]

predrF <- predict(rFmodel2,xTEST,type="prob")[,2]
importance(rFmodel2)
(varImpPlot(rFmodel2))
(plot(roc(predrF,yTEST)))

AUC <<- (auc(roc(predrF,yTEST)))

library(lift)
(plotLift(predrF,yTEST,cumulative=TRUE))
(TopDec <<- (TopDecileLift(predrF,yTEST)))


(partialPlot(x=rFmodel2,x.var=addiction_Summary,pred.data=xTEST,which.class=1))
(partialPlot(x=rFmodel2,x.var=NbrNewspapers_avg,pred.data=xTEST,which.class=1))








