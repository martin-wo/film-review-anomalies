#!/usr/bin/python

from sys import argv
import csv 

review_id_rating = argv[1].split(';')
review_id = review_id_rating[0]
rating = review_id_rating[1]

with open('../data/data_html_ascii.csv', 'r') as reviews:
    reader = csv.reader(reviews, delimiter=';')
    i = 0 # IDs start at 0
    row = next(reader)
    while not (review_id in row[0] and rating == row[1]): 
        if ('test' in row[0]):
            i += 1
        row = next(reader)
    if (review_id in row[0] and rating == row[1]):
	print(i)
