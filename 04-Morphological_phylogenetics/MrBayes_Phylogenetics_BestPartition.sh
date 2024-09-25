#!/bin/bash

#SBATCH -A snic2022-22-758
#SBATCH -p core
#SBATCH -n 8
#SBATCH -t 2-00:00:00
#SBATCH -J MrBayes
#SBATCH -o mrbayes_%j.out
#SBATCH -e mrbayes_%j.err


## Load modules
module load bioinfo-tools
module load mrbayes/3.2.7a-mpi


## Run MrBayes
#mpirun -np 4 mb Morphology_FullyPartitioned_2.nex
#mpirun -np 4 mb Morphology_HomoplasyScores_5.nex
#mpirun -np 4 mb Morphology_Morphology_p1_6.nex
#mpirun -np 4 mb Morphology_Morphology_p2_4.nex
#mpirun -np 4 mb Morphology_PartitionFinder_4.nex
#mpirun -np 4 mb Morphology_RandomPartition_2.nex
#mpirun -np 4 mb Morphology_Unpartitioned_2.nex



## sump and sumt commands are used to summarise the results.
## 25% of the generations and trees are discarded as burnin

# execute File.nex (comment the mcmc block just in case)
# sump burnin = 1250
# sumt burnin = 1250
