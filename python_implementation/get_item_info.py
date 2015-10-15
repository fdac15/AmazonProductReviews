from bs4 import BeautifulSoup
import requests

def get_item(URL):

    # Reviewer Item Review Page
    response = requests.get(URL)
    soup = BeautifulSoup(response.text, 'html.parser')

    # Grab the html from the specific review
    review = soup.find("div", {"class": "hReview"})

    # Get Item Info
    try:
        itemNo = review.find('abbr', {"class": "asin"}).string
        itemTitle = review.find('abbr', {"class": "title"}).string
        itemCategory = review.find('abbr', {"class": "category"}).string
        itemUrl = review.find('span', {"class": "item"}).find("a").get('href')
        itemBrand = review.find('abbr', {"class": "brand"}).string
    except AttributeError:
        itemBrand = "None"

    # Get Reviewer Info
    reviewerName = review.find('span', {"class": "reviewer vcard"}).find("a", {"class": "url fn"}).string
    reviewRating = review.find('ul').find("li", {"class": "rating"}).find("abbr", {"class": "value"}).get("title")
    reviewSummary = ' '.join(review.find('span', {"class": "summary"}).string.split())
    reviewDescription = ' '.join(review.find('span', {"class": "description"}).get_text().split())
    reviewerUrl = "http://www.amazon.com" + review.find('span', {"class": "reviewer vcard"}).find("a").get('href')
    dateReviewed = review.find('abbr', {"class": "dtreviewed"}).string

    # Print results
    print("\n***** Item Info *****")
    print("itemNo: " + itemNo + "\nitemTitle: " + itemTitle + "\nitemUrl: " + itemUrl + "\nitemBrand: " + itemBrand + "\nitemCategory: " + itemCategory)
    print("\n***** Review Info *****")
    print("reviewerName: " + reviewerName + "\nreviewerUrl: " + reviewerUrl + "\ndateReviewed: " + dateReviewed + "\nreviewRating: " + reviewRating + "\nreviewSummary: " + reviewSummary + "\nreviewDescription: " + reviewDescription)

