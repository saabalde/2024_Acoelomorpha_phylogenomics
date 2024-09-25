#!/bin/bash -l
 
#SBATCH -A XX
#SBATCH -p core
#SBATCH -n 5
#SBATCH -t 2:00:00
#SBATCH -J PhyloPyPruner
#SBATCH -o job_phylopypruner_%j.out
#SBATCH -e job_phylopypruner_%j.err

# Format alignments 
orthofinder2phylopypruner Species.list 01-OrthoFinder_Alignments

# format gene trees
for i in 02-Orthofinder_Genetrees/*tree.txt
    do
    sed -i 's/19_228\_/19_228\./g' $i
    sed -i 's/19_375\_/19_375\./g' $i
    sed -i 's/19_380\_/19_380\./g' $i
    sed -i 's/20_005\_/20_005\./g' $i
    sed -i 's/20_022\_/20_022\./g' $i
    sed -i 's/20_023\_/20_023\./g' $i
    sed -i 's/20_026\_/20_026\./g' $i
    sed -i 's/20_038\_/20_038\./g' $i
    sed -i 's/20_053\_/20_053\./g' $i
    sed -i 's/20_063\_/20_063\./g' $i
    sed -i 's/20_073\_/20_073\./g' $i
    sed -i 's/20_078\_/20_078\./g' $i
    sed -i 's/20_082\_/20_082\./g' $i
    sed -i 's/20_093\_/20_093\./g' $i
    sed -i 's/20_115\_/20_115\./g' $i
    sed -i 's/20_132\_/20_132\./g' $i
    sed -i 's/DRR151142\_/DRR151142\./g' $i
    sed -i 's/P15761_101\_/P15761_101\./g' $i
    sed -i 's/P15761_102\_/P15761_102\./g' $i
    sed -i 's/P15761_110\_/P15761_110\./g' $i
    sed -i 's/P15761_117\_/P15761_117\./g' $i
    sed -i 's/P15761_125\_/P15761_125\./g' $i
    sed -i 's/P15761_133\_/P15761_133\./g' $i
    sed -i 's/P15761_141\_/P15761_141\./g' $i
    sed -i 's/P15761_149\_/P15761_149\./g' $i
    sed -i 's/P15761_157\_/P15761_157\./g' $i
    sed -i 's/P15761_165\_/P15761_165\./g' $i
    sed -i 's/P15761_173\_/P15761_173\./g' $i
    sed -i 's/P15761_181\_/P15761_181\./g' $i
    sed -i 's/P15761_189\_/P15761_189\./g' $i
    sed -i 's/SRR2500940\_/SRR2500940\./g' $i
    sed -i 's/SRR2681155\_/SRR2681155\./g' $i
    sed -i 's/SRR2681679\_/SRR2681679\./g' $i
    sed -i 's/SRR2682004\_/SRR2682004\./g' $i
    sed -i 's/SRR2682099\_/SRR2682099\./g' $i
    sed -i 's/SRR2682154\_/SRR2682154\./g' $i
    sed -i 's/SRR3105702\_/SRR3105702\./g' $i
    sed -i 's/SRR3105703\_/SRR3105703\./g' $i
    sed -i 's/SRR3105704\_/SRR3105704\./g' $i
    sed -i 's/SRR3105705\_/SRR3105705\./g' $i
    sed -i 's/SRR5760179\_/SRR5760179\./g' $i
    sed -i 's/SRR6374833\_/SRR6374833\./g' $i
    sed -i 's/SRR6375633\_/SRR6375633\./g' $i
    sed -i 's/SRR8454219\_/SRR8454219\./g' $i
    sed -i 's/SRR8506641\_/SRR8506641\./g' $i
    sed -i 's/SRR8524599\_/SRR8524599\./g' $i
    sed -i 's/SRR8617822\_/SRR8617822\./g' $i
    sed -i 's/SRR8641368\_/SRR8641368\./g' $i

    sed -i 's/\_OF\_/\.OF\@/g' $i

    mv -- "$i" "${i%_tree.txt}.tre"
done

## Run PhyloPyPruner

# Alignments and gene trees need to be in the same directory
mkdir 03-PhyloPyPruner_input
cp 01-OrthoFinder_Alignments/* 03-PhyloPyPruner_input/
cp 02-Orthofinder_Genetrees/*  03-PhyloPyPruner_input/

# Run PhyloPyPruner
phylopypruner --dir 03-PhyloPyPruner_input/ --output 04-PhyloPyPruner_output --no-supermatrix --trim-lb 5 --min-support 60 --mask pdist \
              --outgroup SRR2500940_Xenoturbella_profunda --prune LS --min-taxa 5

