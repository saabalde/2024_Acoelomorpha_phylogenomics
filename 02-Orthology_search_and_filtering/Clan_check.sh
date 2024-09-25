#!/bin/bash -l
 
#SBATCH -A XX
#SBATCH -p core
#SBATCH -n 5
#SBATCH -t 2:00:00
#SBATCH -J Clan_check
#SBATCH -o job_clan_check_%j.out
#SBATCH -e job_clan_check_%j.err

module load bioinfo-tools
module load IQTREE/1.6.11



mkdir 14-Clan_test
cp 13-Symmetry_tests/*fas 14-Clan_test/
cd 14-Clan_test

# Create a "Clans.txt" analysis defining _Faerlea_ as part of Proporidae:
# 20_026.Haplogonaria_minima 20_063.Faerlea_glomerata 20_073.Kuma_sp5 20_082.Haploposthia_lactomaculata 20_093.Haploposthia_rubropunctata

# Infer a gene tree for each of the alignments
for i in *fas
    do
    iqtree -s $i -m MFP -AICc -nt AUTO
done

# Concatenate all gene trees into a single file
cat *treefile Trees_clan_check.phy

# Run the Clan test
clan_check -f Trees_clan_check.phy -c Clans.txt
