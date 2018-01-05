#!/usr/bin/python
from sys import argv
import csv
from gensim import corpora

documents = [];

mode = argv[1]

# read from csv
with open('../data/preprocessed.csv', 'r') as reviews:
    reader = csv.reader(reviews, delimiter= ';')
    for row in reader:
        if mode in row[0]:
            documents.append(row[2])

# lowercase        
documents = [[word for word in document.lower().split()] for document in documents]

# create dictionary
dictionary = corpora.Dictionary(documents)
dictionary.save('../data/film_reviews.dict')

# create bag of words representations
corpus = [dictionary.doc2bow(document) for document in documents]
corpora.MmCorpus.serialize('../data/corpus.mm', corpus)  # store to disk, for later use
