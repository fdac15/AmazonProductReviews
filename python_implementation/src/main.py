from python_implementation.src.get_review_info import get_review
from python_implementation.src.get_review_urls import get_urls

# from reviewer most recent page
print("Getting top ten reviews for a User...")
url_set = get_urls('http://www.amazon.com/gp/cdp/member-reviews/A2D1LPEUCTNT8X/ref=cm_cr_tr_tbl_1_sar?ie=UTF8&sort_by=MostRecentReview')

for url in url_set:
    print("Getting item info from review..." + url)

    # Grab the review information
    review = get_review(url)

    # Print the review information
    print("\n***** Item Info *****")
    print("itemNo: " + review.itemNo + "\nitemTitle: " + review.itemTitle + "\nitemUrl: " + review.itemUrl
          + "\nitemBrand: " + review.itemBrand + "\nitemCategory: " + review.itemCategory)
    print("\n***** Review Info *****")
    print("reviewerName: " + review.reviewerName + "\nreviewerUrl: " + review.reviewerUrl + "\ndateReviewed: "
          + review.dateReviewed + "\nreviewRating: " + review.Rating + "\nreviewSummary: " + review.Summary
          + "\nreviewDescription: " + review.Description)
