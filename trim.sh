#!/bin/bash
mkdir -p ./log ./err ./trimmed
mkdir -p ./log/trimmed ./err/trimmed
cat pair.file.txt | while read line
do
suffix="_R1.fastq "
name=${line%${suffix}*}
#echo sbatch --mem 64GB -c 4 -p short -o "./log/trimmed/${name}.out" -e "./err/trimmed/${name}.err" -J "$name" --wrap="module load oracle_java/jdk1.8.0_181; java -jar ~/Jar/Trimmomatic-0.39/trimmomatic-0.39.jar PE $line ILLUMINACLIP:NexteraPE-PE.fa:2:30:10:2:keepBothReads LEADING:3 TRAILING:3 MINLEN:36"
sbatch --mem 64GB -c 4 -p short -o "./log/trimmed/${name}.out" -e "./err/trimmed/${name}.err" -J "$name" --wrap="module load oracle_java/jdk1.8.0_181; java -jar ~/Jar/Trimmomatic-0.39/trimmomatic-0.39.jar PE $line ILLUMINACLIP:/home/li.gua/Jar/Trimmomatic-0.39/adapters/NexteraPE-PE.fa:2:30:10:2:keepBothReads LEADING:3 TRAILING:3 MINLEN:36"
done
