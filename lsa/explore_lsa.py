#!/usr/bin/python

from gensim import models

lsi = models.LsiModel.load('./model.lsi')

for topic in lsi.print_topics(300):
    print topic
