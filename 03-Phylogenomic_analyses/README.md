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

![image](https://github.com/saabalde/2024_Acoelomorpha_phylogenomics/blob/main/Acoelomorpha_photos.png)
**Fig. 1:** Phylogenomic tree showcasing the difficulty of inferring a robust tree from genes filtered by substitution rate. The tree was inferred from the 567 genes with lowest substitution rate, using site-specific models with 20 amino acid categories (C20) in IQ-TREE and using Xenoturbella as the outgroup. Unless otherwise specified, all nodes have good support (bootstrap / SH-like approximate likelihood ratio test). The scale bar indicates substitutions per site. The inset to the left shows a tree inferred from the same matrix but after removing all Nemertodermatida species and using a typical partition model.

On the other hand, the occupancy matrices were capable of confidently resolving inter-family relationships with good support (**Figure 2**). However, IQ-TREE diferred from PhyloBayes and ASTRAL in some nodes.

![image](https://github.com/saabalde/2024_Acoelomorpha_phylogenomics/blob/main/Acoelomorpha_photos.png)
**Fig. 1:** Summary of the phylogenomic analyses. (a) Proportion of variable sites and average bootstrap support in the supermatrices filtered by occupancy, substitution rate, saturation, compositional heterogeneity, and patristic distances. (b) Gene overlap among the same matrices, displayed as a PCA. The presence and absence of genes on each matrix were used to calculate the two main principal components. Phylogenomic trees inferred from the 300 most complete genes using IQ-TREE and 60 amino acid categories (c) or PhyloBayes (d). Unless otherwise specified, all nodes have maximum support (c: ultrafast bootstrap / SH-like approximate likelihood ratio test; d: posterior probabilities). Species names in grey indicate samples downloaded from the SRA, in black new transcriptomes, and names underlined highlight conflicts between the two topologies. The scale bars indicate substitutions per site.













###################
###################
###################

## Placing _Notocelis gullmarensis_ in the tree
bb
