#!/bin/bash -l
 
#SBATCH -A snic2020-15-191
#SBATCH -C mem256GB
#SBATCH -p core
#SBATCH -n 20
#SBATCH -t 3-00:00:00
#SBATCH -J Trinity
#SBATCH -o job_trinity_%j.out
#SBATCH -e job_trinity_%j.err


## Load modules
module load bioinfo-tools
module load trinity/2.11.0


## Data
outfolder=./trinity/


## Run Trinity
Trinity --seqType fq --max_memory 240G --CPU 20 \
        --left  ./19-228_1.fastq.gz \
        --right ./19-228_2.fastq.gz \
        --trimmomatic

# seqType: format of reads files
# --max_memory : amout of RAM used during Jellyfidh k-mer
# --CPU: number of parallel processes
# --output: path to the directory where to save the results. If it doesn't exit
#           it will be created
# --normalize_reads: normalize the reads during the assembly process
# --min_contig_length: minimum length of the built contigs

