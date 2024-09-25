#!/bin/bash
#SBATCH --job-name=MrBayes
#SBATCH --chdir=.
#SBATCH --output=mrbayes_%j.out
#SBATCH --error=mrbayes_%j.err
#SBATCH --ntasks=4
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --qos=long30
#SBATCH --time=7-00:00:00


## Load modules
module load MrBayes/3.1.2


## Run MrBayes
#srun --mpi=pmi2 mb Morphology_FullyPartitioned_1.nex
#srun --mpi=pmi2 mb Morphology_FullyPartitioned_2.nex
#srun --mpi=pmi2 mb Morphology_FullyPartitioned_3.nex
#srun --mpi=pmi2 mb Morphology_FullyPartitioned_4.nex
#srun --mpi=pmi2 mb Morphology_FullyPartitioned_5.nex
#srun --mpi=pmi2 mb Morphology_FullyPartitioned_6.nex
#srun --mpi=pmi2 mb Morphology_FullyPartitioned_7.nex
#srun --mpi=pmi2 mb Morphology_FullyPartitioned_8.nex
#srun --mpi=pmi2 mb Morphology_FullyPartitioned_9.nex
#srun --mpi=pmi2 mb Morphology_HomoplasyScores_1.nex
#srun --mpi=pmi2 mb Morphology_HomoplasyScores_2.nex
#srun --mpi=pmi2 mb Morphology_HomoplasyScores_3.nex
#srun --mpi=pmi2 mb Morphology_HomoplasyScores_4.nex
#srun --mpi=pmi2 mb Morphology_HomoplasyScores_5.nex
#srun --mpi=pmi2 mb Morphology_HomoplasyScores_6.nex
#srun --mpi=pmi2 mb Morphology_HomoplasyScores_7.nex
#srun --mpi=pmi2 mb Morphology_HomoplasyScores_8.nex
#srun --mpi=pmi2 mb Morphology_HomoplasyScores_9.nex
#srun --mpi=pmi2 mb Morphology_Morphology_p1_1.nex
#srun --mpi=pmi2 mb Morphology_Morphology_p1_2.nex
#srun --mpi=pmi2 mb Morphology_Morphology_p1_3.nex
#srun --mpi=pmi2 mb Morphology_Morphology_p1_4.nex
#srun --mpi=pmi2 mb Morphology_Morphology_p1_5.nex
#srun --mpi=pmi2 mb Morphology_Morphology_p1_6.nex
#srun --mpi=pmi2 mb Morphology_Morphology_p1_7.nex
#srun --mpi=pmi2 mb Morphology_Morphology_p1_8.nex
#srun --mpi=pmi2 mb Morphology_Morphology_p1_9.nex
#srun --mpi=pmi2 mb Morphology_Morphology_p2_1.nex
#srun --mpi=pmi2 mb Morphology_Morphology_p2_2.nex
#srun --mpi=pmi2 mb Morphology_Morphology_p2_3.nex
#srun --mpi=pmi2 mb Morphology_Morphology_p2_4.nex
#srun --mpi=pmi2 mb Morphology_Morphology_p2_5.nex
#srun --mpi=pmi2 mb Morphology_Morphology_p2_6.nex
#srun --mpi=pmi2 mb Morphology_Morphology_p2_7.nex
#srun --mpi=pmi2 mb Morphology_Morphology_p2_8.nex
#srun --mpi=pmi2 mb Morphology_Morphology_p2_9.nex
#srun --mpi=pmi2 mb Morphology_PartitionFinder_1.nex
#srun --mpi=pmi2 mb Morphology_PartitionFinder_2.nex
#srun --mpi=pmi2 mb Morphology_PartitionFinder_3.nex
#srun --mpi=pmi2 mb Morphology_PartitionFinder_4.nex
#srun --mpi=pmi2 mb Morphology_PartitionFinder_5.nex
#srun --mpi=pmi2 mb Morphology_PartitionFinder_6.nex
#srun --mpi=pmi2 mb Morphology_PartitionFinder_7.nex
#srun --mpi=pmi2 mb Morphology_PartitionFinder_8.nex
#srun --mpi=pmi2 mb Morphology_PartitionFinder_9.nex
#srun --mpi=pmi2 mb Morphology_RandomPartition_1.nex
#srun --mpi=pmi2 mb Morphology_RandomPartition_2.nex
#srun --mpi=pmi2 mb Morphology_RandomPartition_3.nex
#srun --mpi=pmi2 mb Morphology_RandomPartition_4.nex
#srun --mpi=pmi2 mb Morphology_RandomPartition_5.nex
#srun --mpi=pmi2 mb Morphology_RandomPartition_6.nex
#srun --mpi=pmi2 mb Morphology_RandomPartition_7.nex
#srun --mpi=pmi2 mb Morphology_RandomPartition_8.nex
#srun --mpi=pmi2 mb Morphology_RandomPartition_9.nex
#srun --mpi=pmi2 mb Morphology_Unpartitioned_1.nex
#srun --mpi=pmi2 mb Morphology_Unpartitioned_2.nex
#srun --mpi=pmi2 mb Morphology_Unpartitioned_3.nex
#srun --mpi=pmi2 mb Morphology_Unpartitioned_4.nex
#srun --mpi=pmi2 mb Morphology_Unpartitioned_5.nex
#srun --mpi=pmi2 mb Morphology_Unpartitioned_6.nex
#srun --mpi=pmi2 mb Morphology_Unpartitioned_7.nex
#srun --mpi=pmi2 mb Morphology_Unpartitioned_8.nex
#srun --mpi=pmi2 mb Morphology_Unpartitioned_9.nex
