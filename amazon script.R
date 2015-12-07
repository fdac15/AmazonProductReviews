setwd('/Users/Joe/Documents/Digital Archelogy/Amazon')

amazon_packages()

rev <- read.csv("reviewers_list.csv",header=TRUE)

rev <- rev[which(rev$scraper == "Joe"),]

un <- rev$url_name


url <-  get_review_url(un[1],1)
review_pages(url,1)




  
}

