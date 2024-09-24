## Inferring a phylogenomic backbone for Acoelomorpha
This analysis is based on the full dataset without _Notocelis_ and the corresponding subsampled matrices. We ran the same analyses over all matrices with two exceptions: (1) no site-specific models were used over the full dataset due to the size amount of memory required, and (2) we only ran PhyloBayes over a matrix including the 300 most complete genes (i.e. those with more species). This latter matrix is not included in the repository, but it can be easily created from the 367 occupancy dataset or using genesortR as before.
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








###################
###################
###################

## Placing _Notocelis gullmarensis_ in the tree
bb
