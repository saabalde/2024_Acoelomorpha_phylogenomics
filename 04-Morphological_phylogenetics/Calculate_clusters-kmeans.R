#setwd("")

data <- dataframe(Character = c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 
								21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 
								39, 40, 41, 42, 43, 44),
				  Inferred_Weights = c(6.85000, 4.00000, 3.50000, 3.20000, 5.75000, 2.00000, 6.10000, 1.00000, 
									   1.00000, 4.43750, 3.75000, 2.00000, 1.00000, 1.00000, 2.00000, 4.10000, 
									   3.20000, 2.00000, 2.00000, 7.00000, 3.20000, 3.00000, 3.87500, 4.71429, 
									   6.50000, 4.50000, 4.25000, 3.00000, 4.00000, 2.00000, 4.00000, 4.00000, 
									   4.00000, 2.00000, 2.00000, 1.00000, 3.00000, 5.00000, 2.75000, 4.20000, 
									   2.00000, 2.00000, 1.00000, 2.00000))


## Calculate the optimum number of clusters
# Calculate the "sum within clusters"
cluster_01 <- kmeans(x = data$Inferred_Weights, centers = 1, iter.max = 100, nstart = 1)
cluster_02 <- kmeans(x = data$Inferred_Weights, centers = 2, iter.max = 100, nstart = 1)
cluster_03 <- kmeans(x = data$Inferred_Weights, centers = 3, iter.max = 100, nstart = 1)
cluster_04 <- kmeans(x = data$Inferred_Weights, centers = 4, iter.max = 100, nstart = 1)
cluster_05 <- kmeans(x = data$Inferred_Weights, centers = 5, iter.max = 100, nstart = 1)
cluster_06 <- kmeans(x = data$Inferred_Weights, centers = 6, iter.max = 100, nstart = 1)
cluster_07 <- kmeans(x = data$Inferred_Weights, centers = 7, iter.max = 100, nstart = 1)
cluster_08 <- kmeans(x = data$Inferred_Weights, centers = 8, iter.max = 100, nstart = 1)
cluster_09 <- kmeans(x = data$Inferred_Weights, centers = 9, iter.max = 100, nstart = 1)
cluster_10 <- kmeans(x = data$Inferred_Weights, centers = 10, iter.max = 100, nstart = 1)

# Plot these results
sum_clusters <- data.frame(n_clusters = c(1:10),
                   Within_cluster_sum = c(sum(cluster_01$withinss), sum(cluster_02$withinss),
                                                  sum(cluster_03$withinss), sum(cluster_04$withinss),
                                                  sum(cluster_05$withinss), sum(cluster_06$withinss),
                                                  sum(cluster_06$withinss), sum(cluster_08$withinss),
                                                  sum(cluster_09$withinss), sum(cluster_10$withinss)))
plot(sum_clusters$n_clusters, sum_clusters$Within_cluster_sum, type = "b",
     xlab = "Number of clusters", ylab = "Total sum within clusters") 
axis(side = 1, at = c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10))

## Group the characters in clusters (three)
final_clustering <- kmeans(x = data$Inferred_Weights, centers = 4, iter.max = 100, nstart = 1)
final_clustering$cluster

## Save this result
data[, 3] <- final_clustering$cluster
names(data)[3] <- "Partition"

write.table(data, file = "Partitioned_characters.txt", sep = "\t", dec = ".")
