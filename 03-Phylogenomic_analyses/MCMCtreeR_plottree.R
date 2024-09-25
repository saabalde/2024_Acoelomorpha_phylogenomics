##########################
## MCMCtreeR: Plot tree ##
##########################

## Set working directory
setwd("")


## Load libraries
library(MCMCtreeR, quietly = TRUE, warn.conflicts = FALSE)


## Load data
my_tree <- readMCMCtree(inputPhy = "Xenacoelomorpha_timetree_chain1.tre", from.file = TRUE)
mcmc <- read.table(file = "Xenacoelomorpha_step2_chain1.mcmc", head=TRUE)

# Change tip labels
my_tree$apePhy$tip.label <- c("Thalassoanaperus_rubellus", "Anaperus_tvaerminnensis", 
                              "Neochildia_fusca", "Convolutriloba_macropyga", 
                              "Symsagittifera_roscoffensis", "Praesagittifera_naikaiensis", 
                              "Childia_submaculatum", "Childia_crassum", "Childia_vivipara", 
                              "Paramecynostomum_diversicolor", "Haploposthia_lactomaculata", 
                              "Nadina_sp2", "Aphanostoma_virescens", 
                              "Eumecynostomum_macrobursalium", "Philactinoposthia_rhammifera", 
                              "Philocelis_karlingi", "Notocelis_gullmarensis", 
                              "Baltalimania_agile", "Baltalimania_occulta", 
                              "Praeconvoluta_tigrina", "Aphanostoma_pulchra", 
                              "Praeaphanostoma_sp", "Faerlea_glomerata", 
                              "Haploposthia_rubropunctata", "Kuma_sp5", "Haplogonaria_minima", 
                              "Diopisthoporus_longitubus", "Diopistohoporus_sp1", 
                              "Diopisthoporus_gymnopharyngeus", "Solenofilomorpha_sp9", 
                              "Solenofilomorpha_sp2", "Hofstenia_miamia", "Paratomella_rubra", 
                              "Sterreria_rubra", "Sterreria_lundini", "Sterreria_sp", 
                              "Meara_stichopi", "Nemertoderma_westbladi", "Flagellophora_sp", 
                              "Ascoparia_sp", "Xenoturbella_profunda")

## Plot tree
# Write the node ages to a file
write.table(my_tree$nodeAges, file = "Node_ages.txt", sep = "\t")

# Just plot the tree
MCMC.tree.plot(phy = my_tree, cex.tips = 1, time.correction = 1, 
               scale.res = c("Eon", "Period", "Epoch", "Age"), plot.type = "phylogram", 
               cex.age = 0.6, cex.labels = 0.6, relative.height = 0.08, 
               col.tree = "black", label.offset = 4, node.method = "none", 
               no.margin = TRUE, edge.width = 4)

# Add the uncertainty to each node
MCMC.tree.plot(phy = my_tree, cex.tips = 1, time.correction = 1, 
               scale.res = c("Eon", "Period", "Epoch", "Age"), plot.type = "phylogram", 
               cex.age = 1, cex.labels = 1, relative.height = 0.08, 
               col.tree = "black", label.offset = 0.5, node.method = "bar", 
               lwd.bar = 5, col.age = "red", no.margin = TRUE, edge.width = 4)

# Add the full distribution of the posterior to each node
MCMC.tree.plot(phy = my_tree, cex.tips = 1, time.correction = 1, MCMC.chain = mcmc, 
               scale.res = c("Eon", "Period"), plot.type = "distributions", 
               cex.age = 1, cex.labels = 1, relative.height = 0.05, 
               col.tree = "black", label.offset = 5, density.col = "#00000050", 
               density.border.col = "#00000080", no.margin = TRUE, edge.width = 4)

