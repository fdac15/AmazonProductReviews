import re
import requests
from bs4 import BeautifulSoup

def get_urls(url):

    response = requests.get(url)

    soup = BeautifulSoup(response.text, 'html.parser')
    review_urls = set()

    for link in soup.find_all('a'):
        tmp = link.get('href')
        if tmp and re.search('/review/\w+$', tmp):
                review_urls.add(tmp)

    return review_urls
