rm(list=ls())
setwd("/Users/mballin2/Dropbox/2TEACHING/UT/Spring2015_DataMining/CLASS7_Mon_Feb2")

#compile functions
source("functions_for_Text_and_Network_Mining.R")

#read in tweets from disk
df <- read.csv("tweets.csv")

#Look at data
df$text

#STEP 1: create document by term matrix
doc_term_mat <- create_document_term_matrix(df$text)
#investigate output
doc_term_mat
inspect(doc_term_mat)

#STEP 2: create adjacency matrix
adj_mat <- create_adjacency_matrix(doc_term_mat)
adj_mat[[1]][1:10,1:10]

set.seed(1)
#STEP 3: run this multiple times until you are satisfied (see notes to know why this changes with each execution)
plot_network(adj_mat)


