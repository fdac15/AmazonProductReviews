import re
import requests
from bs4 import BeautifulSoup

def get_urls(url):

    review_urls = set()
    for pageNumber in range(1, 11):

        newurl = re.sub(r'page=\d+', "page=" + str(pageNumber), url)
        response = requests.get(newurl)
        soup = BeautifulSoup(response.text, 'html.parser')

        for link in soup.find_all('a'):
            tmp = link.get('href')
            if tmp and re.search('/review/\w+$', tmp):
                review_urls.add(tmp)

    return review_urls
