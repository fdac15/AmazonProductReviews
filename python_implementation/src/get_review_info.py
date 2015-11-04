from python_implementation.src.reviewClass import Review
from bs4 import BeautifulSoup
import requests

def get_review(url):

    # Reviewer Item Review Page
    response = requests.get(url)
    soup = BeautifulSoup(response.text, 'html.parser')

    # Grab the html from the specific review
    review_page = soup.find("div", {"class": "hReview"})

    # Initialize class
    review = Review()

    # Get Reviewer Info
    try:
        review.reviewerName = review_page.find('span', {"class": "reviewer vcard"}).find("a", {"class": "url fn"}).string
        review.Rating = review_page.find('ul').find("li", {"class": "rating"}).find("abbr", {"class": "value"}).get("title")
        review.Summary = ' '.join(review_page.find('span', {"class": "summary"}).string.split())
        review.Description = ' '.join(review_page.find('span', {"class": "description"}).get_text().split())
        review.reviewerUrl = "http://www.amazon.com" + review_page.find('span', {"class": "reviewer vcard"}).find("a").get('href')
        review.dateReviewed = review_page.find('abbr', {"class": "dtreviewed"}).string
    except AttributeError:
        print("error")

    # Get Item Info
    try:
        review.itemNo = review_page.find('abbr', {"class": "asin"}).string
        review.itemTitle = review_page.find('abbr', {"class": "title"}).string
        review.itemCategory = review_page.find('abbr', {"class": "category"}).string
        review.itemUrl = review_page.find('span', {"class": "item"}).find("a").get('href')
        review.itemBrand = review_page.find('abbr', {"class": "brand"}).string
    except AttributeError:
        print("error")

    return review


