#!/bin/bash
mkdir -p ./quast ./log/quast ./err/quast
cat pair.identify.txt | while read line
do
contigspath="./assemble/${line}.assembled/contigs.fasta"
output="./quast/${line}.out"
log="./log/quast/${line}.out"
err="./err/quast/${line}.err"
jn=$line
cn=". ~/.bashrc; conda activate metagenomics;quast.py $contigspath -o $output"
sbatch --time 24:00:00 -c 8 -o $log -e $err -J $jn --wrap="$cn"
done
