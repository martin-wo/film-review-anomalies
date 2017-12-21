#!/usr/bin/python

from gensim import models

lsi = models.LsiModel.load('./model.lsi')

for topic in lsi.print_topics(100):
    print topic
