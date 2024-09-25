# A Phylogenomic Backbone for Acoelomorpha Inferred from Transcriptomic Data
## What was this study about?
Xenacoelomorpha are mostly microscopic, benthic, marine worms. They are morphologically very simple, without many of the structures typical of other bilaterians, such as body cavity, through-gut, or circulatory and excretory systems. The uncertain position of Xenacoelomorpha within the metazoan tree (either as sister to Ambulacraria, Xenambulacraria hypothesis, or Protostomes+Deuterostomes, Nephrozoa hypothesis) has understandably attracted a lot of attention, overshadowing the study of phylogenetic relationships within this group. Given that Xenoturbella includes only six species whose relationships are well understood, we decided to focus on the most speciose Acoelomorpha (Acoela + Nemertodermatida). 

![image](https://github.com/saabalde/2024_Acoelomorpha_phylogenomics/blob/main/Acoelomorpha_photos.png)
**A:** Acoela, *Diopisthoporus longitubus*; **B:** Acoela, *Notocelis gullmarensis*; **C:** Nemertodermatida, *Flagellophora apelti*; **D:** Nemertodermatida, *Nemertoderma westbladi*

In this study, we have sequenced 29 new transcriptomes, doubling the number of sequenced species, to infer a backbone tree for Acoelomorpha based on genomic data. We have used this new phylogeny to date main cladogenetic events, infer character evolution, and calculate rates of morphological evolution. Finally, we have also used morphological phylogenetics to test to what extent morphological data can be used in phylogenetic inference.

The recovered (molecular) topology is mostly congruent with previous studies, but *Paratomella* is recovered as the first off-shoot within Acoela, dramatically changing the reconstruction of the ancestral acoel. Besides, we have detected incongruence between the gene trees and the species tree, likely linked to incomplete lineage sorting, and some signal of introgression between the families Dakuidae and Mecynostomidae, which hampers inferring the correct placement of this family and, particularly, of the genus *Notocelis*. Main diversification events within Acoelomorpha coincide with known bilaterian diversification and extinction periods. Although morphological data failed to recover a robust phylogeny, phylogenetic placement has proven to be a suitable alternative when a reference phylogeny is available.

## Repository description
This repository is intended to offer enough details to replicate our study, explaining the reasoning behind some of our decisions. Ideally, the level of detail should be enough to be accessible for people with a low background in phylogenomics, and so we hope it can also be used as a reference in future, similar studies.

We have devided the code in four sections (01-Transcriptomes_assembly, 02-Orthology_search_and_filtering, 03-Phylogenomic_analyses, and 04-Morphological_phylogenetics) to make it easier to digest. Scripts and the data necessary to run the analyses are provided alongside the explanations.

### Data accessibility:
<ul>
    <li><strong>Raw reads:</strong> All transcriptomes can be downloaded from the <a href="https://www.ncbi.nlm.nih.gov/sra/?term=xenacoelomorpha">NCBI SRA</a>. The new transcriptomes are part of the <a href="https://www.ncbi.nlm.nih.gov/bioproject/PRJNA1106782">Bioproject PRJNA1106782</a>.

  </li>
    <li><strong>Other data:</strong> We have created a <a href="https://datadryad.org/stash/share/-j295xDx5ENV04DAmF_IDdEvbUuE24jbi6t_Ug9FmNs
">Dryad repository</a>, which contains: (1) transcriptome assemblies, (2) the TransDecoder output, (3) all alignments, (4) gene trees, (5) the morphological matrix, and (6) the nexus files necessary to replicate the morphological phylogenetic analyses.
</ul>

## Citation
<ul>
  <li>Abalde, S., and Jondelius, U. (accepted, pending minor revisions). A Phylogenomic Backbone for Acoelomorpha Inferred from Transcriptomic Data. <a href="">Systematic Biology</a>.</li>
</ul>

---
