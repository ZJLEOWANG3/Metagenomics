#!/bin/bash
rm -rf pair.identify.txt pair.file.txt pair.original.txt pair.trimmed.txt
for i in $(ls -- *R1.fastq); do 
	a=${i/R1/R2}
	suffix="_R"
	identify=${i%"$suffix"*}
	echo $identify
	echo "${identify}" >> pair.identify.txt
	echo "$i $a" >> pair.original.txt
	echo "./trimmed/$i.trimmed.fastq ./trimmed/$a.trimmed.fastq" >> pair.trimmed.txt # for spades input1 input2
	echo "$i $a ./trimmed/$i.trimmed.fastq ./trimmed/$i.trimmed.removed.fastq ./trimmed/$a.trimmed.fastq ./trimmed/$a.trimmed.removed.fastq" >> pair.file.txt # for trimmomatic input1 input2 output1 output1.removed output2 output2.removed
done
