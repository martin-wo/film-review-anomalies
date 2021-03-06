#!/usr/bin/python

from gensim import corpora, models

corpus = corpora.MmCorpus('../data/corpus.mm')
dictionary = corpora.Dictionary.load('../data/film_reviews.dict')
lsi = models.LsiModel(corpus, id2word=dictionary, num_topics=300)
lsi.print_topics(10)
lsi.save('./model.lsi')
