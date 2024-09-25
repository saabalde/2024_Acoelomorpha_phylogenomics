## Inferring a phylogenomic backbone for Acoelomorpha
This analysis is based on the full dataset without _Notocelis_ and the corresponding subsampled matrices. We ran the same analyses over all matrices with two exceptions: (1) no site-specific models were used over the full dataset due to the size amount of memory required, and (2) we only ran PhyloBayes only over the 300 most complete genes (i.e. those with more species).
Here, the "Occupancy_300genes_Supermatrix.fas" supermatrix will be used as an example, but the same parameters were used for all datasets.

The first analysis we ran was a coalescence tree with [ASTRAL-III](https://github.com/smirarab/ASTRAL). From this repository: "ASTRAL is a tool for estimating an unrooted species tree given a set of unrooted gene trees. ASTRAL is statistically consistent under the multi-species coalescent model (and thus is useful for handling incomplete lineage sorting, i.e., ILS)." Hoerver, the data provided is an already concatenated supermatrix. You can separate it into single genes using [this pipeline by Nathan Whelan](https://github.com/NathanWhelan/Split_supermatrix_into_partitions) after converting the matrix from fasta to phylip.

    # Infer a gene tree per alignment
    for i in *phy
        do
        iqtree -s $i -m MFP -AICc -nt AUTO -bb 1000
    done

    # Concatenate the trees into a single file
    cat *treefile > Occupancy_300genes_Genetrees.trees

    # Run Astral
    java -jar -Xmx12000M astral.5.7.7.jar -i Occupancy_300genes_Genetrees.trees -o Occupancy_300genes_Genetrees.ASTRAL.tre 2> ASTRAL.log

After the ASTRAL tree, we inferred a standard Maximum Likelihood (ML) tree with [IQ-TREE](https://github.com/Cibiv/IQ-TREE). IQ-TREE incorporates [ModelFinder](https://www.nature.com/articles/nmeth.4285), which can be used to infer the best-fit model for each partition.

    iqtree -s Occupancy_300genes_Supermatrix.fas -spp Occupancy_300genes_Partitions.txt -m MFP -nt AUTO -bb 1000 -alrt 1000
    # -bb 1000: run 1000 bootstrap replicates
    # -alrt 1000: run 1000 bootstrap replicates for SH-aLRT, the SH-like approximate likelihood ratio test (single branch test)

Besides this traditional ML tree, we also took advantage of the site-specific models implemented in IQ-TREE. Briefly, IQ-TREE assigns each site to a mixture class, which will group sites evolving under similar conditions. The user can define how many categories to incorporate, changing the number of mixture profiles allowed. Here, we used the 20 (C20) and 60 (C60) profiles. This analysis needs a guide tree, which is used to infer the mixture model parameters. Then, these parameters will be used during tree inference.

    # Infer the guide tree
    iqtree -s Occupancy_300genes_Supermatrix.fas -m LG+F+G -nt AUTO -bb 1000 -alrt 1000

    # Infer the tree under the C20 model
    mkdir C20; cd C20
    iqtree -s Occupancy_300genes_Supermatrix.fas -m LG+C20+F+G -ft ../Occupancy_300genes_Supermatrix.fas.treefile -bb 1000 -nt AUTO -alrt 1000
    
    # Infer the tree under the C60 model
    cd ../; mkdir C60; cd C60
    iqtree -s Occupancy_300genes_Supermatrix.fas -m LG+C60+F+G -ft ../Occupancy_300genes_Supermatrix.fas.treefile -bb 1000 -nt AUTO -alrt 1000

Finally, we also ran [PhyloBayes](https://github.com/bayesiancook/phylobayes) over the 300 most complete genes. This is also a site-specific model but in a Bayesian framework. PhyloBayes is computationally very expensive. All other submatrices did not return a meaningful result (we'll see it in a moment) and were not worth the trouble. We ran four independent chains.

    # Run PhyloBayes
    mpirun -np 16 pb_mpi -d Occupancy_300genes_Supermatrix.fas -s -cat -gtr -dgam 4 Acoelomorpha_300genes_chain1
    mpirun -np 16 pb_mpi -d Occupancy_300genes_Supermatrix.fas -s -cat -gtr -dgam 4 Acoelomorpha_300genes_chain2
    mpirun -np 16 pb_mpi -d Occupancy_300genes_Supermatrix.fas -s -cat -gtr -dgam 4 Acoelomorpha_300genes_chain3
    mpirun -np 16 pb_mpi -d Occupancy_300genes_Supermatrix.fas -s -cat -gtr -dgam 4 Acoelomorpha_300genes_chain4
    # -s:      save the detailed model configuration for each point visited during the run.
    # -cat:    activates the Dirichlet process.
    # -gtr:    specifies a general time reversible matrix.
    # -dgam 4: specifies 4 categories for the discrete gamma distribution.

    # Check the chains convergence
    bpcomp -x 1000 10 Acoelomorpha_300genes_chain1 Acoelomorpha_300genes_chain2
    tracecomp -x 1000 Acoelomorpha_300genes_chain1 Acoelomorpha_300genes_chain2

    bpcomp -x 1000 10 Acoelomorpha_300genes_chain1 Acoelomorpha_300genes_chain3
    tracecomp -x 1000 Acoelomorpha_300genes_chain1 Acoelomorpha_300genes_chain3

    bpcomp -x 1000 10 Acoelomorpha_300genes_chain1 Acoelomorpha_300genes_chain4
    tracecomp -x 1000 Acoelomorpha_300genes_chain1 Acoelomorpha_300genes_chain4

    bpcomp -x 1000 10 Acoelomorpha_300genes_chain2 Acoelomorpha_300genes_chain3
    tracecomp -x 1000 Acoelomorpha_300genes_chain2 Acoelomorpha_300genes_chain3
    
    bpcomp -x 1000 10 Acoelomorpha_300genes_chain2 Acoelomorpha_300genes_chain4
    tracecomp -x 1000 Acoelomorpha_300genes_chain2 Acoelomorpha_300genes_chain4
    
    bpcomp -x 1000 10 Acoelomorpha_300genes_chain3 Acoelomorpha_300genes_chain4
    tracecomp -x 1000 Acoelomorpha_300genes_chain3 Acoelomorpha_300genes_chain4

## Main phylogenomic results
These analyses returned two main results. On one hand, all but the occupancy subsampled matrices failed to confidently resolve inter-family relationships (**Fig. 1**). A quick comparison of these matrices revealed that they all are less informative and have an overall lower bootstrap support than the occupancy ones (**Fig. 2a**). Interestingly, following one of the reviewer's suggestions we also discovered that this result is partly due to a LBA artifact. Removing the Nemertodermatida species from the matrix results in a better acoel tree, although still not fully resolved (**inset of Fig. 1**).

![image](https://github.com/saabalde/2024_Acoelomorpha_phylogenomics/blob/main/03-Phylogenomic_analyses/01-Figure1_IQTREE_rate_567genes.png)
**Figure 1:** Phylogenomic tree showcasing the difficulty of inferring a robust tree from genes filtered by substitution rate. The tree was inferred from the 567 genes with lowest substitution rate, using site-specific models with 20 amino acid categories (C20) in IQ-TREE and using Xenoturbella as the outgroup. Unless otherwise specified, all nodes have good support (bootstrap / SH-like approximate likelihood ratio test). The scale bar indicates substitutions per site. The inset to the left shows a tree inferred from the same matrix but after removing all Nemertodermatida species and using a typical partition model.

On the other hand, the occupancy matrices were capable of confidently resolving inter-family relationships with good support (**Figure 2**). However, IQ-TREE diferred from PhyloBayes and ASTRAL in some nodes.

![image](https://github.com/saabalde/2024_Acoelomorpha_phylogenomics/blob/main/03-Phylogenomic_analyses/02-Figure2_Summary_phylogenomics.png)
**Figure 2:** Summary of the phylogenomic analyses. (a) Proportion of variable sites and average bootstrap support in the supermatrices filtered by occupancy, substitution rate, saturation, compositional heterogeneity, and patristic distances. (b) Gene overlap among the same matrices, displayed as a PCA. The presence and absence of genes on each matrix were used to calculate the two main principal components. Phylogenomic trees inferred from the 300 most complete genes using IQ-TREE and 60 amino acid categories (c) or PhyloBayes (d). Unless otherwise specified, all nodes have maximum support (c: ultrafast bootstrap / SH-like approximate likelihood ratio test; d: posterior probabilities). Species names in grey indicate samples downloaded from the SRA, in black new transcriptomes, and names underlined highlight conflicts between the two topologies. The scale bars indicate substitutions per site.

From these two topologies, we chose the ML one as our working hypothesis as we think it is more robust. PhyloBayes reached convergence in the treespace but not in the continuous parameters of the model, while ASTRAL returned some nodes with very low support and near-zero branch lengths.

## Placing _Notocelis gullmarensis_ in the tree
Inferring the position of _Notocelis_ in the tree is more challenging. This species has a very long branch, leading to errors during tree inference. This analysis is based of the **full dataset**. From this, we created a second dataset composed only of phylogenetically informative genes. We selected these genes based on Likelihood Mapping. The Likelihood Mapping measures the amount of phylogenetic informativeness of a gene or a matrix. (Remember to separate the supermatrix into individual genes.)

    # The four clusters are defined in the file: LikelihoodMapping.Clusters.nex

    # Calculate the informativeness of each gene
    for gene in *fas
        do
        iqtree -s ${gene} -m MFP -nt AUTO -lmap ALL -lmclust LikelihoodMapping.Clusters.nex -n 0 -wql
        rm ${gene}
    done

We kept all genes that accumulate at least 70% of the quartets in one of the corners, regardless of the topology they support. Besides, from these genes, we removed all species that branch out earlier than Proporidae / Isodiametridae. Finally, we also excluded the genes where at least one of the target families was not present.

    # Remove the species from unrelated families
    for i in *fas
        do
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep -v '19_228|19_375|19_380|20_038|20_053|20_082|P15761_149|P15761_157|P15761_165|P15761_173|P15761_181|P15761_189|SRR2500940|SRR2681155|SRR2682004|SRR2682099|SRR2682154|SRR3105703|SRR3105704|SRR5760179|SRR6375633|SRR8454219|SRR8641368' | tr ' ' '\n' > ${i}.tmp
        mv ${i}.tmp ${i}
    done
    
    # Remove the genes where not all families are present
    for i in *fas
        do
        Convolutidae=$( egrep -c 'DRR151142|P15761_125|P15761_141|SRR2681679|SRR8506641|SRR8617822' $i )
        Mecynostomidae=$( egrep -c '20_005|20_115|P15761_110|SRR3105702' $i )
        Dakuidae=$( egrep -c 'P15761_117|20_132' $i )
        Notocelis=$( grep -c '20_023' $i )
        Outgroup=$( egrep -c '20_026|20_063|20_073|20_093|P15761_101|P15761_102|P15761_133|SRR6374833|SRR8524599' $i )

        if [ $Convolutidae -lt 1 ] || [ $Mecynostomidae -lt 1 ] || [ $Dakuidae -lt 1 ] || [ $Notocelis -lt 1 ] || [ $Outgroup -lt 1 ]; then
            rm $i
        fi
    done

    # Rename these sequences
    for i in *fas
        do
        sed -i '/>/! s/\-//g' $i
        mv -- "$i" "${i%.fasta.filtered.mafft.fas}.fasta"
    done
    
    # Realign them
    for f in *fasta
        do
        mafft-linsi $f > $f.mafft
    done
    rm *fasta

    # Clean the alignments
    for i in *mafft
        do
        java -jar BMGE.jar -i $i -t AA -g 0.66:0.79 -of $i.fas > $i.log
    done
    rm *mafft
    
    # Concatenate the resulting genes into a supermatrix
    perl FASconCAT-G_v1.05.pl -l -s > FASconCat.log

Now we have two supermatrices: the full dataset and the phylogenetically informative genes. Run an AU-test to see the support of each topology.

    # For the full dataset
    iqtree -s FullDataset_Supermatrix.fas -spp FullDataset_Partitions.txt -m MFP -nt AUTO -z Alternative_topologies.FullDataset.tres -n 0 -zb 10000 -zw -au -wsl -wpl -safe

    # For the phylogenetically informative genes
    iqtree -s Phylogenetically_informative_genes.fas -spp Phylogenetically_informative_genes_Partitions.txt -m MFP -nt AUTO -z Alternative_topologies.PhylogeneticallyInformative.tres -n 0 -zb 10000 -zw -au -wsl -wpl

With the phylogenetically informative matrix, we also tried MAST. [MAST](http://iqtree.org/doc/Complex-Models#multitree-models) is a new algorithm to test the support of different topologies. It is site based and it allows unlinking different model parameters across sites and topologies. It is more robust than traditional topology tests. Since there are six possible models, we used them all.

    # Each tree has its own GTR model, DNA frequencies and gamma model
    iqtree2 -s Phylogenetically_informative_genes.fas -m "TMIX{LG+FO+G,LG+FO+G,LG+FO+G,LG+FO+G}+TR" -te Alternative_topologies.PhylogeneticallyInformative.tres -nt AUTO
    
    # Link the gamma model
    iqtree2 -s Phylogenetically_informative_genes.fas -m "TMIX{LG+FO,LG+FO,LG+FO,LG+FO}+G+TR" -te Alternative_topologies.PhylogeneticallyInformative.tres -nt AUTO
    
    # Link substitution frequencies
    iqtree2 -s Phylogenetically_informative_genes.fas -m "TMIX{LG+F+G,LG+F+G,LG+F+G,LG+F+G}+TR" -te Alternative_topologies.PhylogeneticallyInformative.tres -nt AUTO
    
    # Unlink the GTR model
    iqtree2 -s Phylogenetically_informative_genes.fas -m "TMIX{LG+F,LG+F,LG+F,LG+F}+G+TR" -te Alternative_topologies.PhylogeneticallyInformative.tres -nt AUTO
    
    # Unlink the gamma model
    iqtree2 -s Phylogenetically_informative_genes.fas -m "LG+FO+TMIX{G,G,G,G}+TR" -te Alternative_topologies.PhylogeneticallyInformative.tres -nt AUTO
    
    # All trees share the same GTR model, DNA frequencies and gamma model
    iqtree2 -s Phylogenetically_informative_genes.fas -m "LG+FO+G+TR" -te Alternative_topologies.PhylogeneticallyInformative.tres -nt AUTO

Unfortunately, neither the phylogenetic analyses nor the topology tests were conclusive. More than one topology received strong support, particularly the two where _Notocelis_ is sister to the Convolutidae+Mecynostomidae clade and the family Dakuidae. At this point, we decided to try to identify the main cause of topological instability in our data.

## Inferring the causes of topological discordance
We considered two potential sources of topological instability: (1) [Hemiplasy](https://academic.oup.com/sysbio/article/57/3/503/1666092), i.e. " the topological discordance between a gene tree and a species tree attributable to lineage sorting", and (2) introgression. Incidentally, one of the reviewers suggested taxon-wise compositional heterogeneity might be an alternative explanation.

To test for the presence of hemiplasy, we used the [R package pepo](https://github.com/guerreror/pepo), which calculates the Hemiplasy risk Factor ("the fraction of incongruence expected to be due to hemiplasy"). We used the ASTRAL tree inferred from the 567 most complete genes as input data. This analysis revealed a high HRF in all internal branches but the one leading to Convolutidae, but nothing specific to _Notocelis_ (**Figure 3a**).

The result of the MAST test suggests there might be some introgression between _Notocelis_ and both Convolutidae and Mecynostomidae. According to the paper, similar support to minor topologies might suggest the presence of introgression. Yet, we had to test this possibility more carefully. Since we have two contrasting topologies, we used two methods based on the D-statistic to test for introgression. We first used the [Dfoil](https://github.com/jbpease/dfoil) algorithm to test introgression over a five-taxa symmetric phylogeny (the IQ-TREE tree). However, this analysis returned a lot of warnings related to data formatting and it was not conclusive. Then, we focused on the more traditional D-statistic calculated over a four-taxon topology (ASTRAL and PhyloBayes trees) using the [evobir R package](https://github.com/coleoguy/evobir).

It makes no sense to work with genes that do not have at least one species of each of the target families, so we filtered these out:

    mkdir Introgression
    for i in *fas
        do
        Convolutidae=$( egrep -c 'DRR151142|P15761_125|P15761_141|SRR2681679|SRR8506641|SRR8617822' $i )
        Mecynostomidae=$( egrep -c '20_005|20_115|P15761_110|SRR3105702' $i )
        Dakuidae=$( egrep -c 'P15761_117|20_132' $i )
        Notocelis=$( grep -c '20_023' $i )
        if [ $Convolutidae -gt 0 ] || [ $Mecynostomidae -gt 0 ] || [ $Dakuidae -gt 0 ] || [ $Notocelis -gt 0 ] || [ $Outgroup -gt 0 ]; then
            cp $i Introgression/
        fi
    done

    cd Introgression

To test for the presence of introgression, we tested all three species combinations for these families (one species per family) using the isodiametrid _Aphanostoma pulchra_ as an outgroup. This resulted in 75 different matrices.

    # Create one directory for each combination where to store these genes
    mkdir -p 07-Genes_New/{01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75}

    # Go through the genes, find the four species of interest, and store them as a new file in the desired directory
    for i in *fasta
        do
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep 'SRR3105702_Childia_submaculatum|P15761_125_Anaperus_rubellus|20_132_Philocelis_karlingi|SRR6374833_Aphanostoma_pulchra' | tr ' ' '\n' > 01/${i}
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep 'SRR3105702_Childia_submaculatum|P15761_125_Anaperus_rubellus|P15761_117_Philactinoposthia_rhammifera|SRR6374833_Aphanostoma_pulchra' | tr ' ' '\n' > 02/${i}
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep 'SRR3105702_Childia_submaculatum|P15761_125_Anaperus_rubellus|20_023_Notocelis_gullmarensis|SRR6374833_Aphanostoma_pulchra' | tr ' ' '\n' > 03/${i}
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep 'SRR3105702_Childia_submaculatum|P15761_141_Anaperus_tvaerminnensis|20_132_Philocelis_karlingi|SRR6374833_Aphanostoma_pulchra' | tr ' ' '\n' > 04/${i}
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep 'SRR3105702_Childia_submaculatum|P15761_141_Anaperus_tvaerminnensis|P15761_117_Philactinoposthia_rhammifera|SRR6374833_Aphanostoma_pulchra' | tr ' ' '\n' > 05/${i}
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep 'SRR3105702_Childia_submaculatum|P15761_141_Anaperus_tvaerminnensis|20_023_Notocelis_gullmarensis|SRR6374833_Aphanostoma_pulchra' | tr ' ' '\n' > 06/${i}
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep 'SRR3105702_Childia_submaculatum|SRR8617822_Neochildia_fusca|20_132_Philocelis_karlingi|SRR6374833_Aphanostoma_pulchra' | tr ' ' '\n' > 07/${i}
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep 'SRR3105702_Childia_submaculatum|SRR8617822_Neochildia_fusca|P15761_117_Philactinoposthia_rhammifera|SRR6374833_Aphanostoma_pulchra' | tr ' ' '\n' > 08/${i}
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep 'SRR3105702_Childia_submaculatum|SRR8617822_Neochildia_fusca|20_023_Notocelis_gullmarensis|SRR6374833_Aphanostoma_pulchra' | tr ' ' '\n' > 09/${i}
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep 'SRR3105702_Childia_submaculatum|SRR2681679_Convolutriloba_macropyga|20_132_Philocelis_karlingi|SRR6374833_Aphanostoma_pulchra' | tr ' ' '\n' > 10/${i}
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep 'SRR3105702_Childia_submaculatum|SRR2681679_Convolutriloba_macropyga|P15761_117_Philactinoposthia_rhammifera|SRR6374833_Aphanostoma_pulchra' | tr ' ' '\n' > 11/${i}
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep 'SRR3105702_Childia_submaculatum|SRR2681679_Convolutriloba_macropyga|20_023_Notocelis_gullmarensis|SRR6374833_Aphanostoma_pulchra' | tr ' ' '\n' > 12/${i}
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep 'SRR3105702_Childia_submaculatum|DRR151142_Praesagittifera_naikaiensis|20_132_Philocelis_karlingi|SRR6374833_Aphanostoma_pulchra' | tr ' ' '\n' > 13/${i}
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep 'SRR3105702_Childia_submaculatum|DRR151142_Praesagittifera_naikaiensis|P15761_117_Philactinoposthia_rhammifera|SRR6374833_Aphanostoma_pulchra' | tr ' ' '\n' > 14/${i}
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep 'SRR3105702_Childia_submaculatum|DRR151142_Praesagittifera_naikaiensis|20_023_Notocelis_gullmarensis|SRR6374833_Aphanostoma_pulchra' | tr ' ' '\n' > 15/${i}
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep '20_115_Childia_crassum|P15761_125_Anaperus_rubellus|20_132_Philocelis_karlingi|SRR6374833_Aphanostoma_pulchra' | tr ' ' '\n' > 16/${i}
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep '20_115_Childia_crassum|P15761_125_Anaperus_rubellus|P15761_117_Philactinoposthia_rhammifera|SRR6374833_Aphanostoma_pulchra' | tr ' ' '\n' > 17/${i}
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep '20_115_Childia_crassum|P15761_125_Anaperus_rubellus|20_023_Notocelis_gullmarensis|SRR6374833_Aphanostoma_pulchra' | tr ' ' '\n' > 18/${i}
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep '20_115_Childia_crassum|P15761_141_Anaperus_tvaerminnensis|20_132_Philocelis_karlingi|SRR6374833_Aphanostoma_pulchra' | tr ' ' '\n' > 19/${i}
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep '20_115_Childia_crassum|P15761_141_Anaperus_tvaerminnensis|P15761_117_Philactinoposthia_rhammifera|SRR6374833_Aphanostoma_pulchra' | tr ' ' '\n' > 20/${i}
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep '20_115_Childia_crassum|P15761_141_Anaperus_tvaerminnensis|20_023_Notocelis_gullmarensis|SRR6374833_Aphanostoma_pulchra' | tr ' ' '\n' > 21/${i}
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep '20_115_Childia_crassum|SRR8617822_Neochildia_fusca|20_132_Philocelis_karlingi|SRR6374833_Aphanostoma_pulchra' | tr ' ' '\n' > 22/${i}
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep '20_115_Childia_crassum|SRR8617822_Neochildia_fusca|P15761_117_Philactinoposthia_rhammifera|SRR6374833_Aphanostoma_pulchra' | tr ' ' '\n' > 23/${i}
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep '20_115_Childia_crassum|SRR8617822_Neochildia_fusca|20_023_Notocelis_gullmarensis|SRR6374833_Aphanostoma_pulchra' | tr ' ' '\n' > 24/${i}
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep '20_115_Childia_crassum|SRR2681679_Convolutriloba_macropyga|20_132_Philocelis_karlingi|SRR6374833_Aphanostoma_pulchra' | tr ' ' '\n' > 25/${i}
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep '20_115_Childia_crassum|SRR2681679_Convolutriloba_macropyga|P15761_117_Philactinoposthia_rhammifera|SRR6374833_Aphanostoma_pulchra' | tr ' ' '\n' > 26/${i}
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep '20_115_Childia_crassum|SRR2681679_Convolutriloba_macropyga|20_023_Notocelis_gullmarensis|SRR6374833_Aphanostoma_pulchra' | tr ' ' '\n' > 27/${i}
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep '20_115_Childia_crassum|DRR151142_Praesagittifera_naikaiensis|20_132_Philocelis_karlingi|SRR6374833_Aphanostoma_pulchra' | tr ' ' '\n' > 28/${i}
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep '20_115_Childia_crassum|DRR151142_Praesagittifera_naikaiensis|P15761_117_Philactinoposthia_rhammifera|SRR6374833_Aphanostoma_pulchra' | tr ' ' '\n' > 29/${i}
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep '20_115_Childia_crassum|DRR151142_Praesagittifera_naikaiensis|20_023_Notocelis_gullmarensis|SRR6374833_Aphanostoma_pulchra' | tr ' ' '\n' > 30/${i}
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep 'P15761_110_Childia_vivipara|P15761_125_Anaperus_rubellus|20_132_Philocelis_karlingi|SRR6374833_Aphanostoma_pulchra' | tr ' ' '\n' > 31/${i}
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep 'P15761_110_Childia_vivipara|P15761_125_Anaperus_rubellus|P15761_117_Philactinoposthia_rhammifera|SRR6374833_Aphanostoma_pulchra' | tr ' ' '\n' > 32/${i}
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep 'P15761_110_Childia_vivipara|P15761_125_Anaperus_rubellus|20_023_Notocelis_gullmarensis|SRR6374833_Aphanostoma_pulchra' | tr ' ' '\n' > 33/${i}
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep 'P15761_110_Childia_vivipara|P15761_141_Anaperus_tvaerminnensis|20_132_Philocelis_karlingi|SRR6374833_Aphanostoma_pulchra' | tr ' ' '\n' > 34/${i}
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep 'P15761_110_Childia_vivipara|P15761_141_Anaperus_tvaerminnensis|P15761_117_Philactinoposthia_rhammifera|SRR6374833_Aphanostoma_pulchra' | tr ' ' '\n' > 35/${i}
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep 'P15761_110_Childia_vivipara|P15761_141_Anaperus_tvaerminnensis|20_023_Notocelis_gullmarensis|SRR6374833_Aphanostoma_pulchra' | tr ' ' '\n' > 36/${i}
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep 'P15761_110_Childia_vivipara|SRR8617822_Neochildia_fusca|20_132_Philocelis_karlingi|SRR6374833_Aphanostoma_pulchra' | tr ' ' '\n' > 37/${i}
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep 'P15761_110_Childia_vivipara|SRR8617822_Neochildia_fusca|P15761_117_Philactinoposthia_rhammifera|SRR6374833_Aphanostoma_pulchra' | tr ' ' '\n' > 38/${i}
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep 'P15761_110_Childia_vivipara|SRR8617822_Neochildia_fusca|20_023_Notocelis_gullmarensis|SRR6374833_Aphanostoma_pulchra' | tr ' ' '\n' > 39/${i}
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep 'P15761_110_Childia_vivipara|SRR2681679_Convolutriloba_macropyga|20_132_Philocelis_karlingi|SRR6374833_Aphanostoma_pulchra' | tr ' ' '\n' > 40/${i}
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep 'P15761_110_Childia_vivipara|SRR2681679_Convolutriloba_macropyga|P15761_117_Philactinoposthia_rhammifera|SRR6374833_Aphanostoma_pulchra' | tr ' ' '\n' > 41/${i}
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep 'P15761_110_Childia_vivipara|SRR2681679_Convolutriloba_macropyga|20_023_Notocelis_gullmarensis|SRR6374833_Aphanostoma_pulchra' | tr ' ' '\n' > 42/${i}
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep 'P15761_110_Childia_vivipara|DRR151142_Praesagittifera_naikaiensis|20_132_Philocelis_karlingi|SRR6374833_Aphanostoma_pulchra' | tr ' ' '\n' > 43/${i}
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep 'P15761_110_Childia_vivipara|DRR151142_Praesagittifera_naikaiensis|P15761_117_Philactinoposthia_rhammifera|SRR6374833_Aphanostoma_pulchra' | tr ' ' '\n' > 44/${i}
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep 'P15761_110_Childia_vivipara|DRR151142_Praesagittifera_naikaiensis|20_023_Notocelis_gullmarensis|SRR6374833_Aphanostoma_pulchra' | tr ' ' '\n' > 45/${i}
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep '20_005_Paramecynostomum_diversicolor|P15761_125_Anaperus_rubellus|20_132_Philocelis_karlingi|SRR6374833_Aphanostoma_pulchra' | tr ' ' '\n' > 46/${i}
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep '20_005_Paramecynostomum_diversicolor|P15761_125_Anaperus_rubellus|P15761_117_Philactinoposthia_rhammifera|SRR6374833_Aphanostoma_pulchra' | tr ' ' '\n' > 47/${i}
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep '20_005_Paramecynostomum_diversicolor|P15761_125_Anaperus_rubellus|20_023_Notocelis_gullmarensis|SRR6374833_Aphanostoma_pulchra' | tr ' ' '\n' > 48/${i}
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep '20_005_Paramecynostomum_diversicolor|P15761_141_Anaperus_tvaerminnensis|20_132_Philocelis_karlingi|SRR6374833_Aphanostoma_pulchra' | tr ' ' '\n' > 49/${i}
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep '20_005_Paramecynostomum_diversicolor|P15761_141_Anaperus_tvaerminnensis|P15761_117_Philactinoposthia_rhammifera|SRR6374833_Aphanostoma_pulchra' | tr ' ' '\n' > 50/${i}
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep '20_005_Paramecynostomum_diversicolor|P15761_141_Anaperus_tvaerminnensis|20_023_Notocelis_gullmarensis|SRR6374833_Aphanostoma_pulchra' | tr ' ' '\n' > 51/${i}
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep '20_005_Paramecynostomum_diversicolor|SRR8617822_Neochildia_fusca|20_132_Philocelis_karlingi|SRR6374833_Aphanostoma_pulchra' | tr ' ' '\n' > 52/${i}
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep '20_005_Paramecynostomum_diversicolor|SRR8617822_Neochildia_fusca|P15761_117_Philactinoposthia_rhammifera|SRR6374833_Aphanostoma_pulchra' | tr ' ' '\n' > 53/${i}
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep '20_005_Paramecynostomum_diversicolor|SRR8617822_Neochildia_fusca|20_023_Notocelis_gullmarensis|SRR6374833_Aphanostoma_pulchra' | tr ' ' '\n' > 54/${i}
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep '20_005_Paramecynostomum_diversicolor|SRR2681679_Convolutriloba_macropyga|20_132_Philocelis_karlingi|SRR6374833_Aphanostoma_pulchra' | tr ' ' '\n' > 55/${i}
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep '20_005_Paramecynostomum_diversicolor|SRR2681679_Convolutriloba_macropyga|P15761_117_Philactinoposthia_rhammifera|SRR6374833_Aphanostoma_pulchra' | tr ' ' '\n' > 56/${i}
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep '20_005_Paramecynostomum_diversicolor|SRR2681679_Convolutriloba_macropyga|20_023_Notocelis_gullmarensis|SRR6374833_Aphanostoma_pulchra' | tr ' ' '\n' > 57/${i}
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep '20_005_Paramecynostomum_diversicolor|DRR151142_Praesagittifera_naikaiensis|20_132_Philocelis_karlingi|SRR6374833_Aphanostoma_pulchra' | tr ' ' '\n' > 58/${i}
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep '20_005_Paramecynostomum_diversicolor|DRR151142_Praesagittifera_naikaiensis|P15761_117_Philactinoposthia_rhammifera|SRR6374833_Aphanostoma_pulchra' | tr ' ' '\n' > 59/${i}
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep '20_005_Paramecynostomum_diversicolor|DRR151142_Praesagittifera_naikaiensis|20_023_Notocelis_gullmarensis|SRR6374833_Aphanostoma_pulchra' | tr ' ' '\n' > 60/${i}
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep '20_082_Haploposthia_lactomaculata|DRR151142_Praesagittifera_naikaiensis|20_132_Philocelis_karlingi|SRR6374833_Aphanostoma_pulchra'  | tr ' ' '\n' > 61/${i}
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep '20_082_Haploposthia_lactomaculata|DRR151142_Praesagittifera_naikaiensis|P15761_117_Philactinoposthia_rhammifera|SRR6374833_Aphanostoma_pulchra'  | tr ' ' '\n' > 62/${i}
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep '20_082_Haploposthia_lactomaculata|DRR151142_Praesagittifera_naikaiensis|20_023_Notocelis_gullmarensis|SRR6374833_Aphanostoma_pulchra'  | tr ' ' '\n' > 63/${i}
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep '20_082_Haploposthia_lactomaculata|P15761_125_Anaperus_rubellus|20_132_Philocelis_karlingi|SRR6374833_Aphanostoma_pulchra'  | tr ' ' '\n' > 64/${i}
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep '20_082_Haploposthia_lactomaculata|P15761_125_Anaperus_rubellus|P15761_117_Philactinoposthia_rhammifera|SRR6374833_Aphanostoma_pulchra'  | tr ' ' '\n' > 65/${i}
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep '20_082_Haploposthia_lactomaculata|P15761_125_Anaperus_rubellus|20_023_Notocelis_gullmarensis|SRR6374833_Aphanostoma_pulchra'  | tr ' ' '\n' > 66/${i}
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep '20_082_Haploposthia_lactomaculata|P15761_141_Anaperus_tvaerminnensis|20_132_Philocelis_karlingi|SRR6374833_Aphanostoma_pulchra'  | tr ' ' '\n' > 67/${i}
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep '20_082_Haploposthia_lactomaculata|P15761_141_Anaperus_tvaerminnensis|P15761_117_Philactinoposthia_rhammifera|SRR6374833_Aphanostoma_pulchra'  | tr ' ' '\n' > 68/${i}
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep '20_082_Haploposthia_lactomaculata|P15761_141_Anaperus_tvaerminnensis|20_023_Notocelis_gullmarensis|SRR6374833_Aphanostoma_pulchra'  | tr ' ' '\n' > 69/${i}
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep '20_082_Haploposthia_lactomaculata|SRR2681679_Convolutriloba_macropyga|20_132_Philocelis_karlingi|SRR6374833_Aphanostoma_pulchra'  | tr ' ' '\n' > 70/${i}
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep '20_082_Haploposthia_lactomaculata|SRR2681679_Convolutriloba_macropyga|P15761_117_Philactinoposthia_rhammifera|SRR6374833_Aphanostoma_pulchra'  | tr ' ' '\n' > 71/${i}
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep '20_082_Haploposthia_lactomaculata|SRR2681679_Convolutriloba_macropyga|20_023_Notocelis_gullmarensis|SRR6374833_Aphanostoma_pulchra'  | tr ' ' '\n' > 72/${i}
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep '20_082_Haploposthia_lactomaculata|SRR8617822_Neochildia_fusca|20_132_Philocelis_karlingi|SRR6374833_Aphanostoma_pulchra'  | tr ' ' '\n' > 73/${i}
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep '20_082_Haploposthia_lactomaculata|SRR8617822_Neochildia_fusca|P15761_117_Philactinoposthia_rhammifera|SRR6374833_Aphanostoma_pulchra'  | tr ' ' '\n' > 74/${i}
        tr '\n' ' ' < $i | sed 's/\ >/\,>/g' | tr ',' '\n' | egrep '20_082_Haploposthia_lactomaculata|SRR8617822_Neochildia_fusca|20_023_Notocelis_gullmarensis|SRR6374833_Aphanostoma_pulchra'  | tr ' ' '\n' > 75/${i}
    done

    # Remove all fasta files without, at least, four species
    for i in */*fasta
        do
	    seqs=$( grep -c '>' ${i} )
	    if [ $seqs -lt 4 ]; then
	        rm ${i}
	    fi
    done

    # Re-align all these files and create a supermatrix
    for i in $( ls * | grep ':' | sed 's/\://g' )
        do
	    cd $i
	    	
	    for gene in *fasta
	        do
		    mafft-linsi ${gene} > ${gene}.fas
		    rm $gene
        done
	
        perl FASconCAT-G_v1.05.pl -l -s > FASconCat.log
	    rm *fasta.fas
        cp FcC_supermatrix.fas ../FcC_supermatrix.${i}.fas

        cd ../	
    done

Now, with the D-statistic.R script, you can calculate the D-statistic for all these matrices.

A lot of the analyses have returned signatures of introgression, mostly between Dakuidae and Mecynostomidae. To make sure this was not an artefact, we also tested different species throughout the tree (selected based on completeness), to see if they are also "hybridizing" with Mecynostomidae and Convolutidae. If so, then we should put these results on hold.
The species selected were: _Eumecynostomum macrobursalium_ and _Aphanostoma virescens_ (“Nadinidae”, same outgroup), _A. pulchra_ and _Haploposthia rubropunctata_ (Isodiametridae, outgroup: _Diopisthoporus gymnopharyngeus_), and _D. gymnopharyngeus_ (Diopisthoporidae, outgroup: _Meara stichopi_). A total of 125 new supermatrices were created, following the same steps as above.

We did find some signal of introgression in all these families, but the z-scores were generally higher when Dakuidae species were considered (i.e. the ABBA-BABA ratio deviates more from zero when Dakuidae is analysed). Besides, all families but Dakuidae present similar z-scores among them and no preference for either Mecynostomidae or Convolutidae (**Figure 3b**). If we consider the result of these families as a background signal, we still find some signal of introgression between Dakuidae and Mecynostomidae, which would explain the instability of these nodes among algorithms and the difficulty of placing _Notocelis_ in the tree.


![image]()
**Figure 3:** Chronogram inferred with MCMCtree, based on three secondary calibrations (highlighted with a black arrowhead) and the 50 most complete genes. The split of each family is marked with a circle, following the same colour scheme from Figs. 1 and 2. The white and grey bars correspond to geological periods. The 95% credible interval of each node shows the full distribution of age estimates.








## Inferring divergence times
We used MCMCtree, included in the program [PAML](http://abacus.gene.ucl.ac.uk/software/paml.html), to infer the divergence times among Acoelomorpha lineages. However, before going into details it is important to explain to decisions that might affect the final result. First, we chose the phylogeny inferred by IQ-TREE, with _Notocelis_ as sister to Dakuidae, as our working hypothesis. Despite some topological problems still remaining, this is the best-supported topology and it generally agrees with the literature. Second, due to the absence of fossils from this group, we relied on secondary calibrations to date our tree.

This is a two-step analysis: first, we inferred a timetree for Bilateria, including three acoelomorph genomes, to obtain the calibration points. Second, we used these estimates to date cladogenetic events in Acoelomorpha.

### 1. Bilateria
This tree was inferred from 18 genomes downloaded from GenBank. The list of species and accession numbers is provided in **Supp. Table S2**, but can also be seen in the file "MCMCtree_Metazoan_genomes_and_calibrations.xlsx". This list includes two Acoela (*Praesagittifera naikaiensis*, *Symsagittifera roscoffensis*) and one Nemrtodermatida (*Nemertoderma westbladi*). The tree topology (see **Supp. Figure S1** in the paper) and calibrations (**Supp. Table S3**, also provided in the attached file) were based on the literature.
Importantly, the position of Xenacoelomorpha in the metazoan tree remains largely disputed. They are either the sister group of all other bilaterians (Nephrozoa hypothesis) or the sister of Ambulacraria (Xenambulacraria hypothesis). Because the selected topology might affect the inferred divergence times, we calculated both.

We provide a step-by-step description of the analysis in the next section (the acoelomorph tree), but the analyses are the same: from the annotated proteomes, infer orthogroups. Pick 50 randomly from those that include all species. Infer a quick tree to estimate the prior for the beta parameter (rgene_gamma = 2 825 1). Run MCMCtree.

### 2. Acoelomorpha
We obtained three calibration points from the previous analysis:
| Calibration | Node | Time range (My) | Description |
|:---:| --- |:---:| --- |
| 1 | Root | 540 - 635 | The upper limit is set to the maximum age of animals |
| 2 | Acoela - Nemertodermatida | 500 - 575 | The split between the two groups could be inferred thanks to the inclusion of *Nemertoderma* in the other tree |
| 3 | *P. naikaiensis* - *S. roscoffensis* | 175 - 200 | The two acoel species in the bilaterian chronogram |

The analysis is based on the 50 most complete genes analysed as independent partitions. We followed [this tutorial](http://abacus.gene.ucl.ac.uk/software/MCMCtree.Tutorials.pdf) to run MCMCtree on protein data.

First, convert the alignments to phylip and concatenate them into a single file. The result should be the "MCMCtree_Supermatrix.phy" file. For the conversion, you can use [this script](https://github.com/josephhughes/Sequence-manipulation/blob/master/Fasta2Phylip.pl) by [Joseph Hughes](https://github.com/josephhughes).

    # Convert fasta to phylip
    for i in $( ls *fas | sed 's/\.fas//g' )
        do
        Fasta2Phylip.pl $i.fas $i.phy
    done

    # Change the separation between the species name in the sequence to five spaces (I did this in a text editor)
    # Change the dots in the species names
    for i in OG*
        do
        sed -i 's/\./\_/g' $i
    done

    # Concatenate the alignments
    for i in *phy
        do
        cat $i >> Supermatrix.phy; echo "" >> Supermatrix.phy
    done

Infer a quick tree to calculate the prior of the substitution rate.

    # Concatenate the alignments
    perl FASconCAT-G_v1.05.pl -l -s > FASconCat.log
    rm OG*.fas

    # Run IQ-TREE
    iqtree -s FcC_supermatrix.fas -spp FcC_supermatrix_partition.txt -m MFP -nt AUTO -bb 1000 -alrt 1000

To calculate the branch length, calculate the average of the two longest branches (0.83335). With an alpha = 2 and assuming they diverged 635 million years ago, the beta of the rate is: 2 * 635 / 0.83335 = 1523.96952061 (ca. 1524). This line in the control file becomes: rgene_gamma = 2 1524 1"

Using the input and control files provided, estimate the Hessian and the Gradient.

    mcmctree MCMC_step1_controlfile.ctl

This will create the Hessian and the Gradient for the analysis. However, the model is the simple Poisson with no gamma rates. We need to modify these files.

    # First delete the "out.BV" and "rst" files.
    rm out.BV rst*

    # Second, modify the "*.tmp" files to read the model parameters from the "wag.dat" file; "model = 2" (empirical rates); add three new lines
    # with the model parameters.
    sed -i '/aaRatefile/ s/=/=\ wag.dat/g' *tmp*ctl
    sed -i '/model/ s/0/2/g' *tmp*ctl | head
    sed -ie '/wag.dat/a fix_alpha\ =\ 0\nalpha\ =\ \.5\nncatG\ =\ 4' tmp*.ctl       # After the line that contains "wag.dat", append three lines

    # Run codeml to recalculate the Hessian matrix and append the Hessian of each gene to the "in.BV" file.
    for i in tmp*ctl
        do
        codeml ${i}; cat rst2 >> in.BV; echo "" >> in.BV
    done

The new "in.BV" file contains the Hessian matrix for each gene calculated with the WAG+GAMMA model. Now we are ready to calculate the divergence times sampling from the priors (usedata = 0) and using empirical data (usedata = 2).

    # Sampling from the prior
    mcmctree MCMC_step2_priorsampling_controlfile.ctl 2>&1 | tee log_MCMCtree_prior.txt

    # Using empirical data
    mcmctree MCMC_step3_controlfile.ctl 2>&1 | tee log_MCMCtree_posterior.txt

Run these analyses twice, with different seeds, to asses convergence. I used the [MCMCtreeR package](https://github.com/PuttickMacroevolution/MCMCtreeR) to do that and plot the tree.

![image](https://github.com/saabalde/2024_Acoelomorpha_phylogenomics/blob/main/03-Phylogenomic_analyses/04-Figure4_Acoelomorpha_chronogram.png)
**Figure 4:** Chronogram inferred with MCMCtree, based on three secondary calibrations (highlighted with a black arrowhead) and the 50 most complete genes. The split of each family is marked with a circle, following the same colour scheme from Figs. 1 and 2. The white and grey bars correspond to geological periods. The 95% credible interval of each node shows the full distribution of age estimates.


---
