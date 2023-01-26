#!/bin/bash

cat pair.identify.txt | while read line
do
dir="picard/$line"
mkdir -p ./$dir ./log/$dir ./err/$dir

pathin="samtool/$line.bam"
log="./log/$dir/${line}.out"
err="./err/$dir/${line}.err"
jn=$line

cn="module load oracle_java/jdk1.8.0_181;java -jar ~/Jar/picard.jar MarkDuplicates REMOVE_DUPLICATES=true I=$pathin \
O=${dir}_rmdup.bam M=${dir}_rmdup_metrics.txt"
sbatch --time 24:00:00 -c 8 -o $log -e $err -J $jn --wrap="$cn"
done
