from get_review_urls import get_urls
from get_item_info import get_item

# from reviewer most recent page
print("Getting top ten reviews for a User...")
url_set = get_urls('http://www.amazon.com/gp/cdp/member-reviews/A2D1LPEUCTNT8X/ref=cm_cr_tr_tbl_1_sar?ie=UTF8&sort_by=MostRecentReview')
# url_set = get_urls('http://www.amazon.com/gp/cdp/member-reviews/A1E1LEVQ9VQNK/ref=cm_cr_tr_tbl_2_sar?ie=UTF8&sort_by=MostRecentReview')

for url in url_set:
    print("Getting item info from review..." + url)
    get_item(url)

# get_item("http://www.amazon.com/review/R1T5OX82F58LET")
