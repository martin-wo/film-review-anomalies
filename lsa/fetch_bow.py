#!/usr/bin/python
import csv
from gensim import corpora

documents = [];

# read from csv
with open('./data/data_html_ascii.csv', 'r') as reviews:
    reader = csv.reader(reviews, delimiter= ';')
    for row in reader:
        documents.append(row[2])

# lowercase        
documents = [[word for word in document.lower().split()] for document in documents]

# create dictionary
dictionary = corpora.Dictionary(documents)

# create bag of words representations
corpus = [dictionary.doc2bow(document) for document in documents]
corpora.MmCorpus.serialize('data/corpus.mm', corpus)  # store to disk, for later use
