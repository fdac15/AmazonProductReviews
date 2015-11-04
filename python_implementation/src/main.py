from python_implementation.src.get_review_info import get_review
from python_implementation.src.get_review_urls import get_urls
import csv

with open('/Users/Curtis/Desktop/Fall 2015/FNDA/AmazonProductReviews/python_implementation/reviews.csv', 'w', newline='') as csvfile:

    # header for csv file
    fn = ['reviewerID', 'reviewerName', 'reviewerUrl', 'itemNo', 'itemTitle', 'itemUrl', 'itemBrand', 'itemPrice',
          'itemCategory', 'dateReviewed', 'Rating', 'Summary', 'Description']

    # open csv file for writing
    reviewWriter = csv.DictWriter(csvfile, delimiter=',', fieldnames=fn)
    reviewWriter.writeheader()

    with open("/Users/Curtis/Desktop/Fall 2015/FNDA/AmazonProductReviews/reviewers_list.csv") as ouputfile:
        reader = csv.DictReader(ouputfile)
        for row in reader:

            # only scrape my data
            if row['scraper'] == "Curtis":
                usrid = row['url_name']

                # get top 100 review urls for user
                url_set = get_urls('http://www.amazon.com/gp/cdp/member-reviews/' + usrid
                                   + '?ie=UTF8&display=public&page=1&sort_by=MostRecentReview')

                # get review information from each page
                for url in url_set:
                    review = get_review(url, usrid)
                    reviewWriter.writerow(review.__dict__)

                # To grab all data remove break
                break
