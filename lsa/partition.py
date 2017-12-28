#!/usr/bin/python

import csv

training_set = []
test_set = []

with open('../data/lsa_annotations.csv', 'r') as annotations:
    reader = csv.reader(annotations, delimiter= ';')
    for row in reader:
        if 'train' in row[0]:
            training_set.append(row)
        else:
            test_set.append(row)

with open('../data/lsa_train.csv', 'w') as training_csv:
    writer = csv.writer(training_csv, delimiter = ';')
    for row in training_set:
        writer.writerow(row)

with open('../data/lsa_test.csv', 'w') as test_csv:
    writer = csv.writer(test_csv, delimiter = ';')
    for row in test_set:
        writer.writerow(row)
