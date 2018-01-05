cat ./data/preprocessed.csv | tr ' ' '\n' | sed 's/^.*[0-9];//g' | tr A-Z a-z | sort | uniq | wc -l
