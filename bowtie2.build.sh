#!/bin/bash

cat pair.identify.txt | while read line
do
dir="bowtie2/$line"
mkdir -p ./$dir ./log/$dir ./err/$dir

contigspath="./anvio/anvio.filtsimp/${line}.fasta"
id="./$dir/${line}.refidx"
log="./log/$dir/${line}.build.out"
err="./err/$dir/${line}.build.err"
jn="${line}.build"

cn="~/opt/bowtie/2.4.5/bin/bowtie2-build $contigspath $id"
sbatch --time 24:00:00 -c 8 -o $log -e $err -J $jn --wrap="$cn"
done
