## Set working directory
setwd("")


## Clean the workspace
rm(list=ls())


## Load the necessary libraries
library(MCMCtreeR, quietly = TRUE, warn.conflicts = FALSE)
library(ggplot2)


#########################################################################
#########################################################################

# ###############################################
# PRIOR:
# ###############################################

# Read the MCMC trace files
mcmc1.p <- read.table("Xenacoelomorpha_priorsampling_chain1.mcmc", head=TRUE)
mcmc2.p <- read.table("Xenacoelomorpha_priorsampling_chain2.mcmc", head=TRUE)

# Plot the estimations of the two chains to make sure they converge
p.mean1 <- apply(mcmc1.p[,2:41], 2, mean) * 100
p.mean2 <- apply(mcmc2.p[,2:41], 2, mean) * 100
plot(p.mean1, p.mean2); abline(0, 1)

## Check the ESS
mean.mcmc1.p <- apply(mcmc1.p[,-1], 2, mean)
ess.mcmc1.p <- apply(mcmc1.p[,-1], 2, coda::effectiveSize)
var.mcmc1.p <- apply(mcmc1.p[,-1], 2, var)
se.mcmc1.p <- sqrt(var.mcmc1.p / ess.mcmc1.p)
cbind(mean.mcmc1.p, ess.mcmc1.p, var.mcmc1.p, se.mcmc1.p)
mcmc1_sse.p <- cbind(mean.mcmc1.p, ess.mcmc1.p, var.mcmc1.p, se.mcmc1.p)

mean.mcmc2.p <- apply(mcmc2.p[,-1], 2, mean)
ess.mcmc2.p <- apply(mcmc2.p[,-1], 2, coda::effectiveSize)
var.mcmc2.p <- apply(mcmc2.p[,-1], 2, var)
se.mcmc2.p <- sqrt(var.mcmc2.p / ess.mcmc2.p)
cbind(mean.mcmc2.p, ess.mcmc2.p, var.mcmc2.p, se.mcmc2.p)
mcmc2_sse.p <- cbind(mean.mcmc2.p, ess.mcmc2.p, var.mcmc2.p, se.mcmc2.p)

write.table(mcmc1_sse.p, file = "Xenacoelomorpha_prior_mcmc1_sse.txt", sep = " ")
write.table(mcmc2_sse.p, file = "Xenacoelomorpha_prior_mcmc2_sse.txt", sep = " ")

# Extract from the tree the maximum and minimum age of the calibrated nodes to 
# make sure they fall within the pre-defined ages
prior_tree <- readMCMCtree(inputPhy = "Xenacoelomorpha_prior_chain1.tre", from.file = TRUE)

prior_tree$nodeAges
write.table(prior_tree$nodeAges, file = "Prior_Node_ages.txt", sep = "\t")

# Create two data frames with the ages information
calibrated_nodes.p <- as.data.frame(prior_tree$nodeAges)[c(11, 2, 1), ]
calibration_points.p <- data.frame(c(175, 500, 540), c(200, 575, 635))

# Plot the ages comparisons
df <- data.frame()

prior_plot <- ggplot(df) + geom_point() + xlim(650, 0) + ylim(0, 40) + xlab("Ages (Million years)") + ylab("")
prior_plot <- prior_plot + geom_segment(aes(x = calibrated_nodes.p[1, 2], xend = calibrated_nodes.p[1, 3], y = 10, yend = 10), colour = "black", size = 3) + 
                           geom_segment(aes(x = calibrated_nodes.p[2, 2], xend = calibrated_nodes.p[2, 3], y = 20, yend = 20), colour = "black", size = 3) + 
                           geom_segment(aes(x = calibrated_nodes.p[3, 2], xend = calibrated_nodes.p[3, 3], y = 30, yend = 30), colour = "black", size = 3)

prior_plot <- prior_plot + geom_segment(aes(x = calibration_points.p[1, 1], xend = calibration_points.p[1, 2], y = 08, yend = 08), colour = "grey", size = 3) + 
                           geom_segment(aes(x = calibration_points.p[2, 1], xend = calibration_points.p[2, 2], y = 18, yend = 18), colour = "grey", size = 3) + 
                           geom_segment(aes(x = calibration_points.p[3, 1], xend = calibration_points.p[3, 2], y = 28, yend = 28), colour = "grey", size = 3)

prior_plot

#########################################################################
#########################################################################

# ###############################################
# POSTERIOR:
# ###############################################

# read in MCMC trace files
mcmc1 <- read.table("Xenacoelomorpha_step2_chain1.mcmc", head=TRUE)
mcmc2 <- read.table("Xenacoelomorpha_step2_chain2.mcmc", head=TRUE)
mcmc3 <- read.table("Xenacoelomorpha_step2_chain3.mcmc", head=TRUE)

# each data frame contains 119 columns:
# MCMC generation number, 17 node ages (divergence times), 50 mean mutation rates,
# 50 rate drift coefficients, and sample log-likelihood values

# to check for convergence of the MCMC runs, we calculate the posterior
# means of times for each run, and plot them against each other
t.mean1 <- apply(mcmc1[,2:41], 2, mean) * 100
t.mean2 <- apply(mcmc2[,2:41], 2, mean) * 100
t.mean3 <- apply(mcmc2[,2:41], 2, mean) * 100
# good convergence is indicated when the points fall on the y = x line.

# pairwise comparison of posterior times for all runs:
par(mfrow=c(3,1))
plot(t.mean1, t.mean2, main="a) Posterior times, r 1 vs. r 2"); abline(0, 1)
plot(t.mean1, t.mean3, main="a) Posterior times, r 1 vs. r 3"); abline(0, 1)
plot(t.mean2, t.mean3, main="a) Posterior times, r 2 vs. r 3"); abline(0, 1)

# we can calculate the effective sample sizes (ESS) of the parameters
# (you need to have the coda package installed for this to work)
mean.mcmc1 <- apply(mcmc1[,-1], 2, mean)
ess.mcmc1 <- apply(mcmc1[,-1], 2, coda::effectiveSize)
var.mcmc1 <- apply(mcmc1[,-1], 2, var)
se.mcmc1 <- sqrt(var.mcmc1 / ess.mcmc1)
cbind(mean.mcmc1, ess.mcmc1, var.mcmc1, se.mcmc1)
mcmc1_sse <- cbind(mean.mcmc1, ess.mcmc1, var.mcmc1, se.mcmc1)

mean.mcmc2 <- apply(mcmc2[,-1], 2, mean)
ess.mcmc2 <- apply(mcmc2[,-1], 2, coda::effectiveSize)
var.mcmc2 <- apply(mcmc2[,-1], 2, var)
se.mcmc2 <- sqrt(var.mcmc2 / ess.mcmc2)
cbind(mean.mcmc2, ess.mcmc2, var.mcmc2, se.mcmc2)
mcmc2_sse <- cbind(mean.mcmc2, ess.mcmc2, var.mcmc2, se.mcmc2)

mean.mcmc3 <- apply(mcmc3[,-1], 2, mean)
ess.mcmc3 <- apply(mcmc3[,-1], 2, coda::effectiveSize)
var.mcmc3 <- apply(mcmc3[,-1], 2, var)
se.mcmc3 <- sqrt(var.mcmc3 / ess.mcmc3)
cbind(mean.mcmc3, ess.mcmc3, var.mcmc3, se.mcmc3)
mcmc3_sse <- cbind(mean.mcmc3, ess.mcmc3, var.mcmc3, se.mcmc3)

write.table(mcmc1_sse, file = "Xenacoelomorpha_mcmc1_sse.txt", sep = " ")
write.table(mcmc2_sse, file = "Xenacoelomorpha_mcmc2_sse.txt", sep = " ")
write.table(mcmc3_sse, file = "Xenacoelomorpha_mcmc3_sse.txt", sep = " ")

# Extract from the tree the maximum and minimum age of the calibrated nodes to 
# make sure they fall within the pre-defined ages
posterior_tree <- readMCMCtree(inputPhy = "../05-MCMCtree_calculatedivergences/Xenacoelomorpha_timetree_chain1.tre", from.file = TRUE)

posterior_tree$nodeAges
write.table(prior_tree$nodeAges, file = "Posterior_Node_ages.txt", sep = "\t")

# Create two data frames with the ages information
calibrated_nodes <- as.data.frame(posterior_tree$nodeAges)[c(11, 2, 1), ]
calibration_points <- data.frame(c(175, 500, 540), c(200, 575, 635))

# Plot the ages comparisons
df <- data.frame()

posterior_plot <- ggplot(df) + geom_point() + xlim(700, 0) + ylim(0, 40) + xlab("Ages (Million years)") + ylab("")
posterior_plot <- posterior_plot + geom_segment(aes(x = calibrated_nodes[1, 2], xend = calibrated_nodes[1, 3], y = 10, yend = 10), colour = "black", size = 3) + 
                                   geom_segment(aes(x = calibrated_nodes[2, 2], xend = calibrated_nodes[2, 3], y = 20, yend = 20), colour = "black", size = 3) + 
                                   geom_segment(aes(x = calibrated_nodes[3, 2], xend = calibrated_nodes[3, 3], y = 30, yend = 30), colour = "black", size = 3)

posterior_plot <- posterior_plot + geom_segment(aes(x = calibration_points[1, 1], xend = calibration_points[1, 2], y = 08, yend = 08), colour = "grey", size = 3) + 
                                   geom_segment(aes(x = calibration_points[2, 1], xend = calibration_points[2, 2], y = 18, yend = 18), colour = "grey", size = 3) + 
                                   geom_segment(aes(x = calibration_points[3, 1], xend = calibration_points[3, 2], y = 28, yend = 28), colour = "grey", size = 3)

posterior_plot

#########################################################################
#########################################################################

# ###############################################
# PRIOR vs POSTERIOR:
# ###############################################

# Check the distributions of the calibrated nodes in the prior and the
# posterior. This will tell us the difference between the "expected"
# calibration, depending only on the calibrations used, and the "real"
# calibration, based on sequence divergences.

# I will plot only the calibrated nodes, because there is no prior
# information in the others.
par(mfcol=c(3,1))
node_names <- c("Acoelomorpha", "Praesagittifera_Symsagittifera", 
                "Xenacoelomorpha")
count <- 0

for(i in c(2, 11, 1)){
    count <- count + 1
    dpr <- density(mcmc1.p[,i+1], adj=.1) # prior
    dPr <- density(mcmc1[,i+1], adj=.1)   # Posterior
    xl <- range(c(dpr$x, dPr$x))
    yl <- range(c(dpr$y, dPr$y))
    plot(dpr, main= node_names[count], xlab="", ylab="", las=1, xlim=xl, ylim=yl, col="darkgrey")
    lines(dPr, col="black")
}
