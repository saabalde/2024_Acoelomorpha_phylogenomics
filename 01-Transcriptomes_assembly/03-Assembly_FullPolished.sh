#!/bin/bash -l
 
#SBATCH -A snic2020-15-191
#SBATCH -p core
#SBATCH -n 8
#SBATCH -t 5-00:00:00
#SBATCH -J rcorrector
#SBATCH -o job_rcorrector_%j.out
#SBATCH -e job_rcorrector_%j.err


## Load modules
module load bioinfo-tools
module load jellyfish/2.3.0
module load trimmomatic/0.36
module load prinseq/0.20.4


## Data
# Reads files
reads1=./19-228_1.fastq.gz
reads2=./19-228_2.fastq.gz

# Output files
outfolder=./
output_name=19-228_cor.fastq

## Run Rcorrector
perl ~/bin/rcorrector/run_rcorrector.pl -1 $reads1 -2 $reads2 -k 21 -od $outfolder -t 8

# -1:   comma separated left files
# -2:   comma separated right reads
# -k:   k-mer length
# -od:  output file directory
# -t:   number of threads

## Run Trimmomatic
java -jar $TRIMMOMATIC_HOME/trimmomatic.jar PE 19-228_1.cor.fq.gz 19-228_2.cor.fq.gz -baseout $output_name \
           ILLUMINACLIP:./TruSeq3-PE.fa:2:30:10 \
           SLIDINGWINDOW:4:5 LEADING:5 TRAILING:5 MINLEN:35

# PE:                   paired-end reads
# -basein:              look for the files whose names contain this in the folder and input them
# -baseout:             base fot the output files (e.g., $output_name_1P.fastq")
# ILLUMINACLIP:         remove adapters. Find the adapter sequences in the specified file
# SLIDINGWINDOW:        Performs a sliding window trimming approach. It starts scanning at the 5‟ end 
#                       and clips the read once the average quality within the window falls below a threshold
# LEADING:              Remove bases at the beginning below this quality threshold
# TRAILING:             Remove bases at the end below this quality threshold
# MINLEN:               Remove reads shorter than this value

## Run Prinseq
prinseq-lite -fastq 19-228_cor_1P.fastq -fastq2 19-228_cor_2P.fastq \
             -out_good 19-228_cor_P_good -out_bad 19-228_cor_P_bad \
             -min_qual_mean 20 \
             -ns_max_p 25 \
             -lc_method entropy -lc_threshold 50 \
             -trim_qual_left 30 -trim_qual_right 30 \
             -min_len 40

# -out_good:              prefix for the reads that pass the quality control
# -out_bad:               prefix for the reads that do not pass the quality control
# -min_qual_mean:         filter sequence with quality score mean below this threshold
# -ns_max_p:              filter sequence whose percentage of N's is above the threshold
# -lc_method:             method to filter low complexity sequences
# -lc_threshold:          threshold for such method
# -trim_qual_left/right:  trim sequence by quality score from the 5' / 3'-end under this threshold
# -min_len:               filter sequences shorter than min_len
