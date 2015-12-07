create_document_term_matrix <- function(data){

      if (!require("SnowballC")) install.packages("SnowballC") ; require("SnowballC")
      if (!require("tm")) install.packages("tm"); library("tm")
      
      myCorpus <- Corpus(VectorSource(data))
      
      cat("Transform to lower case \n")
      #transform all values to lower case
      myCorpus = tm_map(myCorpus, content_transformer(tolower), mc.cores=1)
      
      cat("Remove punctuation \n")
      #remove punctuation
      myCorpus = tm_map(myCorpus, removePunctuation, mc.cores=1)
      
      cat("Remove numbers \n")
      #remove numbers
      myCorpus = tm_map(myCorpus, removeNumbers,  mc.cores=1)
      
      cat("Remove stopwords \n")
      #remove stopwords
      myStopwords = c(stopwords('english'))
      myCorpus = tm_map(myCorpus, removeWords, myStopwords, mc.cores=1)
      
      #cat("Stem corpus \n")
      #stem corpus
      # myCorpus = tm_map(myCorpus, stemDocument, mc.cores=1);
      #  myCorpus = tm_map(myCorpus, stemCompletion, dictionary=dictCorpus);
      
      cat("Create document by term matrix \n")
      #create document term matrix
      myDtm = DocumentTermMatrix(myCorpus, control = list(wordLengths = c(2, Inf)))
      myDtm
}


#object= output from function create_document_term_matrix (a document by term matrix)
#probs= select only vertexes with degree greater than or equal to quantile given by the value of probs
create_adjacency_matrix <- function(object, probs=0.99){
      
      cat("Create adjacency matrix \n")
      #create adjacency matrix
      if (!require("sna")) install.packages("sna"); library("sna")
      Z <- t(as.matrix(object)) %*% as.matrix(object) 
      
      cat("Apply filtering \n")
      ind <- sna::degree(as.matrix(Z),cmode = "indegree") >= quantile(sna::degree(as.matrix(Z),cmode = "indegree"),probs=0.99)
      #ind <- sna::betweenness(as.matrix(Z)) >= quantile(sna::betweenness(as.matrix(Z)),probs=0.99)
      

      Z <- Z[ind,ind]        
      
      cat("Resulting adjacency matrix has ",ncol(Z)," rows and columns \n")
      dim(Z)
      list(Z=Z,termbydocmat=object,ind=ind)
}


#object: output from the create_adjacency_matrix function
plot_network <- function(object){
      
      #create graph from adjacency matrix
      if (!require("igraph")) install.packages("igraph") ; library(igraph)
      g <- graph.adjacency(object$Z, weighted=TRUE, mode ='undirected')
      g <- simplify(g)
      # set labels and degrees of vertices
      V(g)$label <- V(g)$name
      V(g)$degree <- igraph::degree(g)
      
      layout <- layout.auto(g)
      opar <- par()$mar; par(mar=rep(0, 4)) #Give the graph lots of room
      #adjust the widths of the edges and add distance measure labels
      #use 1 - binary (?dist) a proportion distance of two vectors
      #1 is perfect and 0 is no overlap (using 1 - binary)
      edge.weight <- 7  #a maximizing thickness constant
      z1 <- edge.weight*(1-dist(t(object$termbydocmat)[object$ind,], method="binary"))
      E(g)$width <- c(z1)[c(z1) != 0] #remove 0s: these won't have an edge
      clusters <- spinglass.community(g)
      cat("Clusters found: ", length(clusters$csize),"\n")
      cat("Modularity: ", clusters$modularity,"\n")
      plot(g, layout=layout, vertex.color=rainbow(4)[clusters$membership],
        vertex.frame.color=rainbow(4)[clusters$membership] )
}


