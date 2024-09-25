## Morphological phylogenetics
Within Xenacoelomorpha, there are many species that are only known from their type localities. For these and other species that have not been collected for years, morphological descriptions become an important tool for inferring their closest relatives. Here, we tested the ability of morphological data to correctly infer acoelomorph phylogenetic relationships.

In recent years, many studies have shown that clustering morphological characters into partitions greatly improves phylogenetic inference. To test this approach in acoelomorphs, we tried several  partition schemes over our morphological matrix (provided here, but also as **Supp. Table S5** in the manuscript). Among these, we created one scheme made of random partitions, meant to work as  null model. Other partitions include grouping by anatomical structure, partitions inferred by [PartitionFinder](https://github.com/brettc/partitionfinder/tree/master), and by homology scores (i.e. a proxy of their evolutionary rate) calculated with [TNT](https://cladistics.org/tnt/).
To run PartitionFinder, use the cfg files provided:

    PartitionFinderMorphology.py AICc-Branches_linked --raxml
    PartitionFinderMorphology.py AICc-Branches_unlinked --raxml
    PartitionFinderMorphology.py BIC-Branches_linked --raxml
    PartitionFinderMorphology.py BIC-Branches_unlinked --raxml

To calculate the Homoplasy Scores we used TNT. This approach is based on a method described by [Goloboff (1993, Cladistics)](https://onlinelibrary.wiley.com/doi/abs/10.1111/j.1096-0031.1993.tb00209.x). These scores are actually called "Inferred Weights (IW)", and measure the number of steps for each character in relation to the number of steps in the tree. Briefly, set the option "Weighting state transformations" with default parameters and the concavity parameter K = 3. Then, infer a parsimony tree using sectorial search and tree fusing with default parameters (but 20 rounds). Optimise the character scores based on the two recovered trees.
Because the weights are continuous characters, we used the k-means algorithm as implemented in R to create the partitions. The most appropriate number of clusters was defined by comparison of the total sum of squares (the average distance of each point to the centre) between  one and 10 clusters. This method identified four clusters with 21 (weights between 3 - 5), 6 (1), 12 (2 - 2.75), and 5 (5.75 - 7) characters.

Once all the partitions have been created, it is time to calculate the likelihood of each partition. We did this using [MrBayes](https://nbisweden.github.io/MrBayes/). Since MrBayes also allows finetuning some model parameters, we took this opportunity to test the likelihood of each partition over nine different models, allowing or not Among Partition Rate Variation, Among Character Rate Variation, and linking or not branch lengths.

    # For each partition simply run
    mb Morphology_FullyPartitioned_1.nex

This analysis identified the partition created by PartitionFinder as the best-fit. However, instead of using just this one, we inferred a phylogenetic tree over all partitions, selecting the best-fit model for each of them. The idea was to test if partitioning the data really affected the tree inference.

    # As before, simply run
    mpirun -np 4 mb Morphology_FullyPartitioned_2.nex

Unfortunately, none of these efforts resulted in a well-supported tree. Very few nodes were correctly inferred and all partitions returned the same topology, suggesting that morphological data is misleading.

![image](https://github.com/saabalde/2024_Acoelomorpha_phylogenomics/blob/main/04-Morphological_phylogenetics/Supplementary_Figure%20S6-Morphological_phylogeny.png)
**Supp. Figure S6:** Phylogenetic tree inferred from morphological data using MrBayes. Branch are colour-coded as Figure 1 in the manuscript. Nodal support represents posterior probabilities and the scale bar substitutions per site.

## Phylogenetic placement
Due to the poor phylogenetic performance of the morphological matrix and given the importance of morphology in acoelomorph classification and taxonomy, we tested an alternative approach. Since we already have a robust phylogeny inferred from transcriptomic data, we wanted to test if we could get better results using phylogenetic placement algorithms. We chose for this the algorithm implemented in [RAxML](https://github.com/amkozlov/raxml-ng).

The RAxML manual suggests to use a ["weighted approach"](https://ieeexplore.ieee.org/document/5586939). Basically it means you first weight the morphological characters, according to their congruence with the reference phylogeny, and then you incorporate those weights into the phylogenetic placement approach. This approach is supposed to improve the accuracy of this analysis by 20% to 25%.

    # Infer the weights of the characters
    raxmlHPC -f u -m ASC_MULTIGAMMA --asc-corr=lewis -t Reference_tree.tre -s Characters.phy -n test -# 1000 -p 12345

    # Use these weights over a new matrix
    raxmlHPC -f v -m ASC_MULTIGAMMA --asc-corr=lewis -t Reference_tree.tre -s All_species.phy -a RAxML_weights.test -n Morphological_placement -# 1000 -p 12345

This approach correctly identified the position (at least to the family level) of 60 out of 83 species (>72%), demonstrating its potential for inferring the classification of new acoelomorph species. A careful evaluation of the results revealed that missing data in the matrix is the main factor leading to species misplacement.

---
