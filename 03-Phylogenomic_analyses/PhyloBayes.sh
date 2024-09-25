#!/bin/bash

#SBATCH -A XX
#SBATCH -p core
#SBATCH -n 20
#SBATCH -t 10-00:00:00
#SBATCH -J PhyloBayes
#SBATCH -o job_phylobayes_%j.out
#SBATCH -e job_phylobayes_%j.err


## Load modules
module load bioinfo-tools
module load phylobayesmpi/1.8


## Run PhyloBayes
mpirun -np 16 pb_mpi -d FcC_supermatrix.phy -s -cat -gtr -dgam 4 Acoelomorpha_300genes_chain1

# Resume
#mpirun -np 20 pb_mpi Acoelomorpha_300genes_chain1

# -np -> number of processes running in parallel.
# pb_mpi -> defines the chain which is gonna be drawn. Better explanation in the
#           manual.
# -d -> specify the dataset.
# -dc -> removes the constant sites.
# -cat -> activates the Dirichlet process, I suppose it means the Dirichlet
#         Theorem.
# -gtr -> it specifies a general time reversible matrix: exchangeabilities are
#         free parameters, with prior distribution a product of independent 
#         exponential distribuitions of mean 1.
# -dgam n -> it specifies n categories for the discrete gamma distribution.
# chain_1 is the name of the chain. Can be changed.


## Assess convergence
#bpcomp -x 1000 10 Acoelomorpha_300genes_chain Acoelomorpha_300genes_chain2
#tracecomp -x 1000 Acoelomorpha_300genes_chain1 Acoelomorpha_300genes_chain2

#bpcomp -x 1000 10 Acoelomorpha_300genes_chain1 Acoelomorpha_300genes_chain3
#tracecomp -x 1000 Acoelomorpha_300genes_chain1 Acoelomorpha_300genes_chain3

#bpcomp -x 1000 10 Acoelomorpha_300genes_chain1 Acoelomorpha_300genes_chain4
#tracecomp -x 1000 Acoelomorpha_300genes_chain1 Acoelomorpha_300genes_chain4

#bpcomp -x 1000 10 Acoelomorpha_300genes_chain2 Acoelomorpha_300genes_chain3
#tracecomp -x 1000 Acoelomorpha_300genes_chain2 Acoelomorpha_300genes_chain3

#bpcomp -x 1000 10 Acoelomorpha_300genes_chain2 Acoelomorpha_300genes_chain4
#tracecomp -x 1000 Acoelomorpha_300genes_chain2 Acoelomorpha_300genes_chain4

#bpcomp -x 1000 10 Acoelomorpha_300genes_chain3 Acoelomorpha_300genes_chain4
#tracecomp -x 1000 Acoelomorpha_300genes_chain3 Acoelomorpha_300genes_chain4
