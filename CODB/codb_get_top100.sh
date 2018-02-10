DATASET=$1;
echo $DATASET;
rm results_codb_$DATASET"_top100.txt";
while read r; do
    LNR=`echo $r | sed -n 's/.*(\([0-9]\+\)\.).*/\1/p'`;
    if ! [[ -z "$LNR" ]] ; then
        let LNR++;
        sed $LNR"q;d" ../data/$DATASET"_998_final.csv" | sed 's/^\(.*\),\(pos\|neg\).*/\1/' >> results_codb_$DATASET"_top100.txt";
    fi;
done < codb_$DATASET"_998_final.out";
