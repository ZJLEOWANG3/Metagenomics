#!/bin/bash

cat pair.identify.txt | while read line
do
dir="samtool/$line"
mkdir -p ./$dir ./log/$dir ./err/$dir

pathin="bowtie2/$line.sam"
log="./log/$dir/${line}.out"
err="./err/$dir/${line}.err"
jn=$line

cn="~/opt/htslib/1.15.1/bin/samtools view -F 0x4 ${pathin} > ${dir}.sam"
sbatch --time 24:00:00 -c 8 -o $log -e $err -J $jn --wrap="$cn"
done
