#!/usr/bin/python
import csv 
from gensim import models, corpora

lsi = models.LsiModel.load('./model.lsi')
dictionary = corpora.Dictionary.load('../data/film_reviews.dict')
documents = [];
annotations = [];

# read from csv
with open('../data/preprocessed.csv', 'r') as reviews:
    reader = csv.reader(reviews, delimiter= ';')
    for row in reader:
        if ('train' in row[0]):
            document = row[2].lower().split()
            bow = dictionary.doc2bow(document)
            topics_representation = lsi[bow]
            annotations.append([row[0]] + [value for (key, value) in topics_representation])

with open('../data/lsa_annotations.csv', 'w') as annotations_csv:
    writer = csv.writer(annotations_csv, delimiter = ';')
    for row in annotations:
        writer.writerow(row)
