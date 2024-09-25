########################
## Hemiplasy analysis ##
########################

## This script calculates the HRF (Hemiplasy Risk Factor), i.e. the fraction of 
## incongruency expected to be due to hemiplasy. The script calculates the HRF
## for all non-temrinal branches in the tree except for the root.


## Set the working directory
setwd("")


## Load libraries
library(pepo)
library(tidyverse)
library(ggtree)


## Load the data
# Load the tree
Reference_tree <- read.tree("SpeciesTree.567genes.ASTRAL.tre")


## Prepare the table with branch lengths
Branch_lengths <- prep_branch_lengths(tree = Reference_tree)


## According to MCMCtree, the average mutation rate (mu) of the genes analysed 
## varies between 0.0004 and 0.001. Hence, given this is a key factor in the
## analysis I will calculate the HRF for different mutaiton rates.
## Likewise, this is calculated on amino acid data. This should not be a problem
## because the tree is also calculated based on amino acid substitution rates, 
## but I will add some higher than expected mutation rates just in case.

# Mutation = 0.0001
HRF_0001 <- tree_hrf(edges = Branch_lengths, mutation = 0.0001)
HRF_0001.Data_to_plot <- to_treedata(tree = Reference_tree, HRF_0001 %>%
                                     mutate(cathrf = cut(hrf, breaks=c(0, 0.2, 0.5, 0.8, 1))))
HRF_0001.Plot <- ggtree(HRF_0001.Data_to_plot, aes(colour = hrf), size = 5) + 
                        geom_tiplab(size = 0) + 
                        scale_color_gradient2(name = "HRF (mu = 0.0001)",
                                              limits=c(0,1), low='#008080', 
                                              mid='#f6edbd', high='#ca562c', 
                                              midpoint=0.5, na.value = 'grey90')+
                        theme(legend.position = c(.125, .75), 
                              legend.text = element_text(colour="black", size=20, face="bold"),
                              legend.title = element_text(colour="black", size=20, face="bold"),
                              legend.key.size = unit(2, 'cm'))

HRF_0001.Plot <- flip(HRF_0001.Plot, 40, 41)
HRF_0001.Plot <- flip(HRF_0001.Plot, 26, 72)
HRF_0001.Plot <- flip(HRF_0001.Plot, 18, 19)
HRF_0001.Plot <- flip(HRF_0001.Plot, 52, 57)

# Mutation = 0.0005
HRF_0005 <- tree_hrf(edges = Branch_lengths, mutation = 0.0005)
HRF_0005.Data_to_plot <- to_treedata(tree = Reference_tree, HRF_0005 %>%
                                     mutate(cathrf = cut(hrf, breaks=c(0, 0.2, 0.5, 0.8, 1))))
HRF_0005.Plot <- ggtree(HRF_0005.Data_to_plot, aes(colour = hrf), size = 5) + 
                        geom_tiplab(size = 0) + 
                        scale_color_gradient2(name = "HRF (mu = 0.0005)",
                                              limits=c(0,1), low='#008080', 
                                              mid='#f6edbd', high='#ca562c', 
                                              midpoint=0.5, na.value = 'grey90')+
                        theme(legend.position = c(.125, .75), 
                              legend.text = element_text(colour="black", size=20, face="bold"),
                              legend.title = element_text(colour="black", size=20, face="bold"),
                              legend.key.size = unit(2, 'cm'))

HRF_0005.Plot <- flip(HRF_0005.Plot, 40, 41)
HRF_0005.Plot <- flip(HRF_0005.Plot, 26, 72)
HRF_0005.Plot <- flip(HRF_0005.Plot, 18, 19)
HRF_0005.Plot <- flip(HRF_0005.Plot, 52, 57)

# Mutation = 0.001
HRF_001 <- tree_hrf(edges = Branch_lengths, mutation = 0.001)
HRF_001.Data_to_plot <- to_treedata(tree = Reference_tree, HRF_001 %>%
                                    mutate(cathrf = cut(hrf, breaks=c(0, 0.2, 0.5, 0.8, 1))))
HRF_001.Plot <- ggtree(HRF_001.Data_to_plot, aes(colour = hrf), size = 5) + 
                       geom_tiplab(size = 0) + 
                       scale_color_gradient2(name = "HRF (mu = 0.001)",
                                             limits=c(0,1), low='#008080', 
                                             mid='#f6edbd', high='#ca562c', 
                                             midpoint=0.5, na.value = 'grey90')+
                       theme(legend.position = c(.125, .75), 
                             legend.text = element_text(colour="black", size=20, face="bold"),
                             legend.title = element_text(colour="black", size=20, face="bold"),
                             legend.key.size = unit(2, 'cm'))

HRF_001.Plot <- flip(HRF_001.Plot, 40, 41)
HRF_001.Plot <- flip(HRF_001.Plot, 26, 72)
HRF_001.Plot <- flip(HRF_001.Plot, 18, 19)
HRF_001.Plot <- flip(HRF_001.Plot, 52, 57)

## Visualise the trees
HRF_0001.Plot
HRF_0005.Plot
HRF_001.Plot

## Save the chosen plot
ggsave(HRF_0001.Plot, file="02-HRF.mu_0.0001.tiff", device = "tiff", dpi = 300, bg = NULL,
       width = 40, height = 35, units = "cm")
ggsave(HRF_0005.Plot, file="02-HRF.mu_0.0005.tiff", device = "tiff", dpi = 300, bg = NULL,
       width = 40, height = 35, units = "cm")
ggsave(HRF_001.Plot, file="02-HRF.mu_0.001.tiff", device = "tiff", dpi = 300, bg = NULL,
       width = 40, height = 35, units = "cm")
