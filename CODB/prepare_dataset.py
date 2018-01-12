#!/usr/bin/python

from sys import argv
import csv
import math

mode = argv[1]

with open('../data/codb_dataset.arff', 'w') as codb:
    with open('../data/lsa_' + mode + '.csv', 'r') as reviews:
        reader = csv.reader(reviews, delimiter= ';')
        writer = csv.writer(codb, delimiter = ',')
        codb.write('@relation lsa\n')

        for i in range(len(next(reader)) - 1):
            codb.write('@attribute \'lsa_%i\' real\n' % i)
        codb.write('@attribute \'Class\' {n,p}\n')
        codb.write('@data\n')

        for row in reader:
            # extract only p/n lable
            label = row[0][-1]
            row[0:-1] = [i for i in row[1:]]
            row[-1] = label
            writer.writerow(row)
