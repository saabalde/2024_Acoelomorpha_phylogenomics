#!/bin/bash -l
 
#SBATCH -A XX
#SBATCH -p core
#SBATCH -n 16
#SBATCH -t 5-00:00:00
#SBATCH -J IQ-TREE
#SBATCH -o job_iqtree_%j.out
#SBATCH -e job_iqtree_%j.err


## Load modules
module load bioinfo-tools
module load IQTREE/1.6.11


# Input data
supermatrix=../FcC_supermatrix.fas
partitions=../FcC_supermatrix_partitions.txt


## Run IQ-TREE
# Run traditional partition analysis
cd 01-IQTREE
cp $supermatrix ./; cp $partitions ./
iqtree -s FcC_supermatrix.fas -spp FcC_supermatrix_partitions.txt -m MFP -nt AUTO -bb 1000 -alrt 1000


# Run site-specific models
# Guide tree
cd ../02-Guide_tree
cp $supermatrix ./
iqtree -s FcC_supermatrix.fas -m LG+F+G -nt AUTO -bb 1000 -alrt 1000

# C20
cd ../03-C20
cp $supermatrix ./
iqtree -s FcC_supermatrix.fas -m LG+C20+F+G -ft ../02-Guide_tree/FcC_supermatrix.fas.treefile -bb 1000 -nt AUTO -alrt 1000

# C60
cd ../04-C60
cp $supermatrix ./
iqtree -s FcC_supermatrix.fas -m LG+C60+F+G -ft ../02-Guide_tree/FcC_supermatrix.fas.treefile -bb 1000 -nt AUTO -alrt 1000
