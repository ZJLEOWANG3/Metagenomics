#!/bin/bash
dir="anvio/anvio.filtsimp"
mkdir -p ./$dir ./log/$dir ./err/$dir
cat pair.identify.txt | while read line
do
contigspath="./assemble/${line}.assembled/contigs.fasta"
output="./$dir/${line}.fasta"
log="./log/$dir/${line}.out"
err="./err/$dir/${line}.err"
jn=$line
cn=". ~/.bashrc; conda activate anvio-7;anvi-script-reformat-fasta $contigspath -l 500 --simplify-names -o $output"
sbatch --time 24:00:00 --mem 196GB -c 8 -o $log -e $err -J $jn --wrap="$cn"
done
