#!/usr/bin/python

import csv

codb = {'lsa_train' : set(), 'lsa_test' : set(), 'nlp_train' : set(), 'nlp_test' : set()}
rfoex = {'lsa_train' : set(), 'lsa_test' : set(), 'nlp_train' : set(), 'nlp_test' : set()}

with open('results_codb_top100.csv', 'r') as codb_file:
    codb_reader = csv.reader(codb_file, delimiter= ',')
    for row in codb_reader:
        codb['lsa_train'].add(row[0])
        codb['lsa_test'].add(row[1])
        codb['nlp_train'].add(row[2])
        codb['nlp_test'].add(row[3])

with open('results_rfoex_top100.csv', 'r') as rfoex_file:
    rfoex_reader = csv.reader(rfoex_file, delimiter= ',')
    for row in rfoex_reader:
        rfoex['lsa_train'].add(row[0])
        rfoex['lsa_test'].add(row[1])
        rfoex['nlp_train'].add(row[2])
        rfoex['nlp_test'].add(row[3])

print ('LSA_TRAIN \t LSA_TEST \t NLP_TRAIN \t NLP_TEST')
print (str(len(codb['lsa_train'] & rfoex['lsa_train'])) + '\t\t' + str(len(codb['lsa_test'] & rfoex['lsa_test'])) +
        '\t\t' +
str(len(codb['nlp_train'] & rfoex['nlp_train'])) + '\t\t' + str(len(codb['nlp_test'] & rfoex['nlp_test'])))
