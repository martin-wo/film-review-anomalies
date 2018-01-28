#!/usr/bin/python

from sys import argv
import csv
import math

input_file_name = argv[1]
out_name = argv[2]

with open('../data/' + out_name, 'w') as codb:
    with open(input_file_name, 'r') as reviews:
        reader = csv.reader(reviews, delimiter= ',')
        writer = csv.writer(codb, delimiter = ',')
        codb.write('@relation lsa\n')

        for i in range(len(next(reader)) - 2):
            codb.write('@attribute \'nlp_%i\' real\n' % i)
        codb.write('@attribute \'Class\' {n,p}\n')

        codb.write('@data\n')

        for row in reader:
            # extract only p/n label
            label = row[0][-1]
            new_row = [i for i in row[2:]]
            new_row.append(label)
            writer.writerow(new_row)
