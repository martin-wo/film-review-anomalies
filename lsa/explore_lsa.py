#!/usr/bin/python

from gensim import models

lsi = models.LsiModel.load('./model.lsi')
print lsi.print_topics(10)
