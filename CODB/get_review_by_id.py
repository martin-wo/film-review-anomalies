#!/usr/bin/python

from sys import argv
import csv

review_id = argv[2]
mode = argv[1]

with open('../data/data_html_ascii.csv', 'r') as reviews:
    reader = csv.reader(reviews, delimiter=';')
    i = 0 # IDs start at 0
    row = next(reader)
    while not (i == int(review_id) and mode in row[0]): 
        if (mode in row[0]):
            i += 1
        row = next(reader)
    print(row)

