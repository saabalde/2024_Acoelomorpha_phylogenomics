#!/bin/bash -l
 
#SBATCH -A snic2020-15-191
#SBATCH -C mem256GB
#SBATCH -p core
#SBATCH -n 20
#SBATCH -t 1-00:00:00
#SBATCH -J TransPi
#SBATCH -o job_transpi_%j.out
#SBATCH -e job_transpi_%j.err


## Load modules
module load bioinfo-tools


## Data
# Input reads
# This program doesn't accept variables for the reands names. Even if such variable includes the quotes (''), it just reads the R1 and uses it as left and right.

# Working directory

# Output directory


## running TransPi
# Full analysis
#nextflow run TransPi.nf --all --reads 'P15761_101_R[1,2].fastq.gz' --k 21,31,41 --maxReadLen 50 -profile conda --myConda
