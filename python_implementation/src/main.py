from get_review_info import get_review
from get_review_urls import get_urls
import csv

with open('/home/jhughe39/AmazonProductReviews/python_implementation/reviews.csv', 'a', newline='') as csvfile:

    # header for csv file
    fn = ['reviewerID', 'reviewerName', 'reviewerUrl', 'itemNo', 'itemTitle', 'itemUrl', 'itemBrand', 'itemPrice',
          'itemCategory', 'dateReviewed', 'Rating', 'Summary', 'Description']

    # open csv file for writing
    reviewWriter = csv.DictWriter(csvfile, delimiter=',', fieldnames=fn)
    reviewWriter.writeheader()

    with open("/home/jhughe39/AmazonProductReviews/reviewers_list.csv") as ouputfile:
        reader = csv.DictReader(ouputfile)
        for row in reader:

            # only scrape my data
            if row['scraper'] == "Curtis" and row['X'] > 353:
                usrid = row['url_name']

                # get top 100 review urls for user
                url_set = get_urls('http://www.amazon.com/gp/cdp/member-reviews/' + usrid
                                   + '?ie=UTF8&display=public&page=1&sort_by=MostRecentReview')

                # get review information from each page
                for url in url_set:
                    review = get_review(url, usrid)
                    reviewWriter.writerow(review.__dict__)

