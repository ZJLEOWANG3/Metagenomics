#!/bin/bash

cat pair.identify.txt | while read line
do
dir="bowtie2/$line"
mkdir -p ./$dir ./log/$dir ./err/$dir

#contigspath="./anvio/anvio.filtsimp/${line}.fasta"
id="./$dir/${line}.refidx"
log="./log/$dir/${line}.out"
err="./err/$dir/${line}.err"
jn=$line

cn="~/opt/bowtie/2.4.5/bin/bowtie2 -x $id -1 ${line}_R1.fastq -2 ${line}_R2.fastq -S ${dir}.${line}.sam --very-sensitive-local -I 0 -X 1000"
sbatch --time 24:00:00 -c 8 -o $log -e $err -J $jn --wrap="$cn"
done
