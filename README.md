# [Metagenomics](https://en.wikipedia.org/wiki/Metagenomics)
To process 2022Summer Metagenomics Data. 
- The files have been generated by the Illumina pipeline software v2.18.
- The sequences are in fastq format. The fastq file may contain both "filtered" and "not filtered" reads, depending on the instrument used. Files from the NextSeq500 contain only "not filtered" reads, i.e. reads that pass Illumina's Chastity filter. The pass filter status is indicated by a flag (Y/N) in the sequence header for each read. "Y" in the header means the read is filtered (out), i.e. flagged as low quality.
- Base quality scores are in Sanger FASTQ format (the offest is ASCII 33).

```
sq-myjobs # see what jobs is running
set nu! # vim, hide line number
```

- login NEU Clusters to process the data
``` 
ssh discovery
cd scratch/ZIJIAN/CROPPS_2022_Summer
```

- Get computation node
```
get-node-interactive 
```
## Download
- Make download.sh file 
```
vim download.sh
#!/bin/bash
wget -q -c -O 13697_32712_179493_H5LVWAFX5_CROPPS_11N_ACTCTAGG_R1.fastq.gz "http://cbsuapps.biohpc.cornell.edu/Sequencing/showseqfile.aspx?mode=http&cntrl=162668027&refid=985527"
wget -q -c -O 13697_32712_179493_H5LVWAFX5_CROPPS_11N_ACTCTAGG_R2.fastq.gz "http://cbsuapps.biohpc.cornell.edu/Sequencing/showseqfile.aspx?mode=http&cntrl=1236375108&refid=985528"
wget -q -c -O 13697_32712_179493_H5LVWAFX5_CROPPS_12N_TCTTACGC_R1.fastq.gz "http://cbsuapps.biohpc.cornell.edu/Sequencing/showseqfile.aspx?mode=http&cntrl=13177059&refid=985529"
wget -q -c -O 13697_32712_179493_H5LVWAFX5_CROPPS_12N_TCTTACGC_R2.fastq.gz "http://cbsuapps.biohpc.cornell.edu/Sequencing/showseqfile.aspx?mode=http&cntrl=637362183&refid=985530"
wget -q -c -O 13697_32712_179493_H5LVWAFX5_CROPPS_18N_CTTAATAG_R1.fastq.gz "http://cbsuapps.biohpc.cornell.edu/Sequencing/showseqfile.aspx?mode=http&cntrl=1805060388&refid=985531"
wget -q -c -O 13697_32712_179493_H5LVWAFX5_CROPPS_18N_CTTAATAG_R2.fastq.gz "http://cbsuapps.biohpc.cornell.edu/Sequencing/showseqfile.aspx?mode=http&cntrl=281761865&refid=985532"
wget -q -c -O 13697_32712_179493_H5LVWAFX5_CROPPS_22N_ATAGCCTT_R1.fastq.gz "http://cbsuapps.biohpc.cornell.edu/Sequencing/showseqfile.aspx?mode=http&cntrl=831132020&refid=985533"
wget -q -c -O 13697_32712_179493_H5LVWAFX5_CROPPS_22N_ATAGCCTT_R2.fastq.gz "http://cbsuapps.biohpc.cornell.edu/Sequencing/showseqfile.aspx?mode=http&cntrl=169574154&refid=985534"
```

- Download Data from BioHPC
```
bash download.sh
```

- Save it as a backup
```
sbatch --time 24:00:00 -c 8 -J gzip.raw --wrap="tar -czvf CROPPS_2022_Summer.sorting.tar.gz *.fastq"
mv CROPPS_2022_Summer.sorting.tar.gz /home/li.gua/Downloads/ZIJIAN/CROPPS_2022_Summer.sorting.tar.gz
```

- Extract your data (If error, try redownload your data)
```
gunzip *.gz
```

## Prepare PE Name
- Write **get_pari.sh** to get pair file name
```
#!/bin/bash                                                                                                         
rm -rf pair.file.txt pair.original.txt pair.trimmed.txt                                                             
for i in $(ls -- *R1.fastq); do                                                                                     
    a=${i/R1/R2}                                                                                                    
    echo "$i $a" >> pair.original.txt                                                                               
    echo "./trimmed/$i.trimmed.fastq ./trimmed/$a.trimmed.fastq" >> pair.trimmed.txt # for spades input1 input2     
    echo "$i $a ./trimmed/$i.trimmed.fastq ./trimmed/$i.trimmed.removed.fastq ./trimmed/$a.trimmed.fastq ./trimmed/$a.trimmed.removed.fastq" >> pair.file.txt # for trimmomatic input1 input2 output1 output1.removed output2 output2.removed                       
done

bash get_pari.sh
```

## QC & Trim
- Establish **trim.sh** to submit batch jobs; the results in err file
```
#!/bin/bash
mkdir -p ./log ./err ./trimmed
mkdir -p ./log/trimmed ./err/trimmed
cat pair.file.txt | while read line                                                                                               
do
suffix="_R1.fastq "
name=${line%${suffix}*}
sbatch --mem 64GB -c 4 -p short -o "./log/trimmed/${name}.out" -e "./err/trimmed/${name}.err" -J "$name" --wrap="module load oracle_java/jdk1.8.0_181; java -jar ~/Jar/Trimmomatic-0.39/trimmomatic-0.39.jar PE $line ILLUMINACLIP:NexteraPE-PE.fa:2:30:10:2:keepBothReads LEADING:3 TRAILING:3 MINLEN:36"
done
```

- Eye-check the quality of trimmed reads
```
vim ./err/trimmed/13697_32712_179493_H5LVWAFX5_CROPPS_11N_ACTCTAGG.err 
```

## Assembly
- Install [SPAdes](https://github.com/ablab/spades)
```
wget http://cab.spbu.ru/files/release3.15.5/SPAdes-3.15.5-Linux.tar.gz
tar -xzf SPAdes-3.15.5-Linux.tar.gz
mv SPAdes-3.15.5-Linux/* ~/opt/spades/3.15.5
```

- Assemble trimmed reads into contigs by SPAdes, **spades.sh**
```
#!/bin/bash
rm -rf ./assemble.txt
mkdir -p ./assemble ./log/assemble ./err/assemble
cat pair.trimmed.txt | while read line
do
 
suffix="_R1.fastq.trimmed"
name=${line%${suffix}*}
name=${name##*/}
input1=${line% *}
input2=$(cut -d " " -f2- <<< $line)
output="./assemble/${name}.assembled"
log="./log/assemble/${name}.out"
err="./err/assemble/${name}.err"
jn="${name}.spades"
 
if [[ -d $output ]]; then
echo "Restart from last"
cn=". /home/li.gua/.local/env/python-3.10-venv/bin/activate;~/opt/spades/3.15.5/bin/spades.py --restart-from last -o $output "
else
echo "No Last Checkpoint, begin from start"
cn=". /home/li.gua/.local/env/python-3.10-venv/bin/activate;~/opt/spades/3.15.5/bin/spades.py --sc --careful -m 196 -k 21,33,55,77 -1 $input1 -2 $input2 -o $output "
fi
 
echo $output >> assemble.txt
sbatch --time 24:00:00 --mem 196GB -c 8 -o $log -e $err -J $jn --wrap="$cn"
 
done
```

## Contigs QC
- check contigs statistics using **quast**
```
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
sbatch --time 24:00:00 --mem 196GB -c 8 -o $log -e $err -J $jn --wrap="$cn"
done
```

```
scp -r li.gua@xfer-00.discovery.neu.edu:/home/li.gua/scratch/ZIJIAN/CROPPS_2022_Summer/quast /Users/zijianleowang/Desktop/NEU_Server
```

- Filter and simplify name using **anvio**
```
conda info --envs
conda activate anvio-7
```
- Using customized script **anvio.filtsimp.sh** to process it
```
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
cn=". ~/.bashrc; conda activate anvio-7;anvi-script-reformat-fasta $contigspath -l 1500 --simplify-names -o $output"
sbatch --time 24:00:00 --mem 196GB -c 8 -o $log -e $err -J $jn --wrap="$cn"
done
```

## Binning

## Annotation
[ORF](https://www.genome.gov/genetics-glossary/Open-Reading-Frame)
