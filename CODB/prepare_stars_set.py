#!/usr/bin/python

from sys import argv
import csv
import math
import re

input_file_name = argv[1]
out_name = argv[2]

with open('../data/' + out_name, 'w') as codb:
    with open(input_file_name, 'r') as reviews:
        reader = csv.reader(reviews, delimiter= ',')
        writer = csv.writer(codb, delimiter = ',')
        codb.write('@relation stars\n')

        for i in range(len(next(reader)) - 2):
            codb.write('@attribute \'feature_%i\' real\n' % i)
        codb.write('@attribute \'Class\' {1,2,3,4,5,6,7,8,9,10}\n')

        codb.write('@data\n')
        with open ('../data/data_html_ascii.csv', 'r') as db:
            db_content = db.read()
            for row in reader:
                # extract only p/n label
                # label = row[0][-1]
                m = re.search('\n' + row[0] + ';(\d+)', db_content)
                label = m.group(1)
                new_row = [i for i in row[2:]]
                new_row.append(label)
                writer.writerow(new_row)
