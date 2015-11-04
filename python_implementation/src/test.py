import csv

f = open("my_urls.txt", 'w')

with open("/Users/Curtis/Desktop/Fall 2015/FNDA/AmazonProductReviews/python_implementation/reviews.csv") as csvfile:
    reader = csv.DictReader(csvfile)
    for row in reader:
        if row['itemNo'] == "B013LDXCZM":
            print(row['Description'])
