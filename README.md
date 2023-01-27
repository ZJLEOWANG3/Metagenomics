# [Metagenomics](https://en.wikipedia.org/wiki/Metagenomics)
To process 2022Summer Metagenomics Data. 
- The files have been generated by the Illumina pipeline software v2.18.
- The sequences are in fastq format. The fastq file may contain both "filtered" and "not filtered" reads, depending on the instrument used. Files from the NextSeq500 contain only "not filtered" reads, i.e. reads that pass Illumina's Chastity filter. The pass filter status is indicated by a flag (Y/N) in the sequence header for each read. "Y" in the header means the read is filtered (out), i.e. flagged as low quality.
- Base quality scores are in Sanger FASTQ format (the offest is ASCII 33).

## to update **.sh** code
- link github
```
git init
git add remote origin
git pull 
git add .
git commit -m "update bash scripts"
git push origin main
```

- download
```
scp li.gua@xfer.discovery.neu.edu:/home/li.gua/scratch/ZIJIAN/CROPPS_2022_Summer/*.sh /Users/zijianleowang/Desktop/NEU_Server
```
## Some Hint
- Learn Slurm and Sbatch [here](https://slurm.schedmd.com/sbatch.html)
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

- Check conda environment
```
conda info --envs
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
- get pair file name for downstream analysis
```
bash get_pari.sh
```

## QC & Trim
```
bash trim.sh
# Eye-check the quality of trimmed reads
vim ./err/trimmed/13697_32712_179493_H5LVWAFX5_CROPPS_11N_ACTCTAGG.err 
```

## Assembly
- Install [SPAdes](https://github.com/ablab/spades)
```
wget http://cab.spbu.ru/files/release3.15.5/SPAdes-3.15.5-Linux.tar.gz
tar -xzf SPAdes-3.15.5-Linux.tar.gz
mv SPAdes-3.15.5-Linux/* ~/opt/spades/3.15.5
```

- Run code
```
spades.sh
```

- sanity check by [blastn](https://blast.ncbi.nlm.nih.gov/Blast.cgi?PROGRAM=blastn&BLAST_SPEC=GeoBlast&PAGE_TYPE=BlastSearch)
```
vim assemble/13697_32712_179493_H5LVWAFX5_CROPPS_18N_CTTAATAG.assembled/contigs.fasta
# copy some sequences from contigs to blastn for sanity check whether it is meaningful or no significance match
```

## Contigs QC
- check contigs statistics using **quast**
```
bash quast.sh
# copy to local and check html files
scp -r li.gua@xfer-00.discovery.neu.edu:/home/li.gua/scratch/ZIJIAN/CROPPS_2022_Summer/quast /Users/zijianleowang/Desktop/NEU_Server
```
- The quast report.html looks like below
![quast report](https://github.com/ZJLEOWANG3/Metagenomics/blob/31123b60c5fe03ea40ed6975f444c2a9c893f583/media/quast.example.png)

- Filter and simplify name using **anvio**
```
conda activate anvio-7
bash anvio.filtsimp.sh # by default, remove contigs length less than 500 bps
```

- map trimmed reads back to filtered contigs
```
bash bowtie2.build.sh # build the reference
bash bowtie2.sh # by default -X 1000 for maximum length fragment
```

- downstream mapping processing
```
bash samtool.view.sh
bash samtool.sort.sh
bash picard.sh # remove duplicates
bash samtool.index.sh # to index bam files
```

## Binning

## Annotation
[ORF](https://www.genome.gov/genetics-glossary/Open-Reading-Frame)
