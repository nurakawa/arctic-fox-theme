---
layout: post
title: Spectral Clustering
date: 2018-02-24
categories:
tag: CS
---

<head>
<script type="text/javascript"
    src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML">
</script>
</head>


_This post is based on Chapter 14.5.3 of the second edition of [Elements
of Statistical Learning: Data Mining, Inference, and
Prediction](https://web.stanford.edu/~hastie/ElemStatLearn/) by Trevor
Hastie, Robert Tibshirani, and Jerome Friedman._


Clustering is the process of finding the hidden underlying structure of
data by partioning it into similarity-based groups. Its applications are
widespread - it allows for computers to detect borders in images and
companies to group their customers by their interests. One of the most
popular clustering algorithm is the *k-means* algorithm, which
iteratively partitions *n* observations into *k* clusters. The *kmeans*
problem of clustering is defined as an optimization problem, where the
objective is to find a partition that minimizes the total distance
between observations and their cluster centers. The algorithm is simple,
and, in many cases, effective. However, *k-means* fails to discover
clusters with non-convex shapes. Consider, for example, the figure
below, where synthetic data is arranged in concentric circles. Ideally
the data can be clustered into three groups, where a group corresponds
to a circle. Using k-means to cluster this data gives an incorrect
result:

<img src="../assets/spectral-clustering_files/figure-markdown_strict/concentric circles-1.png" style="display: block; margin: auto;" />

_Plot (1) shows synthetic data in concentric circles, where the blue "X"
marks the single center of three distinct clusters, colored red, pink
and orange. Plot (2) shows the same syntethic data that was clustered
using k-means, where the three cluster centers are blue "X" marks, and
the three clusters are again colored red, pink and orange. In this
example, k-means gives incorrect results. Plot (3) shows the data
projected into a different space, an outcome of Spectral Clustering.
Finally, Plot (4) shows the synthetic data, this come colored with
cluster labels obtained from spectral clustering, which correctly
clusters the data points. The centers marked in blue "X" are obtained
from running k-means on the eigenvectors displayed in plot (3)._

The *k-means* clustering problem minimizes the total Euclidean distance
between points within a cluster, creating spherical partitions. In this
example the true partitions are shaped like the letter "O", a non-convex
shape, while the k-means partions are shaped like ellipses. In such
situations, spectral clustering is an effective alternative. The idea
behind spectral clustering is to formulate a clustering problem as a
graph-partition problem, where we identify connected components with
clusters.

Spectral Clustering
-------------------

Consider the task of partitioning a set of *n* data points into
clusters. The procedure for spectral clustering is as follows:

1.  **Represent the data points as a similarity graph.** Compute the
    pairwise similarities *s*<sub>*i*, *i*′</sub> between each of the
    *n* datapoints. This is in order to represent the data points as an
    undirected similarity graph, *G* = &lt;*V*, *E*&gt;, where the
    vertices *V* are the data points, and the edges *E* are weighted by
    the *s*<sub>*i*, *i*′</sub>. Now, clustering the data points is
    partitioning *G* by its connected components. The most popular
    method for computing the *s*<sub>*i*, *i*′</sub> is with a mutual
    k-nearest neighbors graph. A pair of dat points (*i*, *i*′) is in
    𝒩<sub>*K*</sub>, its set of neighbors, if point *i* is among the
    nearest neighbors of point *i*′, and vice-versa. All symmetric
    nearest neighbors are connected with edges weighted with
    *s*<sub>*i*, *i*′</sub>, and points that are not nearest neighbors
    are not connected.

2.  **Compute the graph Laplacian.** The graph Laplacian **L** can be
    computed as such:

Let **W** = *w*<sub>*i*, *i*′</sub> be the adjancy matrix (matrix of
edge weights) from a similarity graph. Let *G* be a diagonal matrix with
diagonal elements *g*<sub>*i*</sub>, where
*g*<sub>*i*</sub> = ∑<sub>*i*′</sub>*w*<sub>*i*, *i*′</sub>, or the sum
of the edge weights connected to each vertex *i*. Then,
**L** **=** **G** **−** **W**.
 Alternatively, one can compute the Normalized Graph Laplacian, which
standardize the Laplacian with respect to node degrees
*g*<sub>*i*</sub>:
$$\\boldsymbol{\\tilde{L} = I - G^{-1}W}$$

1.  **Compute the eigen-decomposition of L.** Find the *m* eigenvectors
    **Z**<sub>*n* × *m*</sub> corresponding to the *m* smallest
    eigenvalues of *L*, ignoring the trivial constant eigenvector.

2.  **Use a standard clustering method such as k-means to cluster the
    rows of **Z**.** This yields a clustering of the original data
    points.

R Implementation
----------------

Here I present an `R` implementation of spectral clustering. The
function `spectral_clustering()` follows the procedure outlined in the
above section. The final step is performing the kmeans algorithm on two
eigenvectors of the computed graph Laplacian, using the function
`kmeans`, set with `k=3`.


```R
    spectral_clustering <- function(X, # matrix of data points
                                    nn = 10, # the k nearest neighbors 
                                    n_eig = 2) # m eignenvectors to keep
    {
      mutual_knn_graph <- function(X, nn = 10)
      {
        D <- as.matrix( dist(X) ) 
	# matrix of euclidean distances between data points in X
        
        # intialize the knn matrix
        knn_mat <- matrix(0,
                          nrow = nrow(X),
                          ncol = nrow(X))
        
        # find the 10 nearest neighbors for each point
        for (i in 1: nrow(X)) {
          neighbor_index <- order(D[i,])[2:(nn + 1)]
          knn_mat[i,][neighbor_index] <- 1 
        }
       
        # Now we note that i,j are neighbors iff K[i,j] = 1 or K[j,i] = 1 
        knn_mat <- knn_mat + t(knn_mat) # find mutual knn
        
        knn_mat[ knn_mat == 2 ] = 1
        
        return(knn_mat)
      }
      
      graph_laplacian <- function(W, normalized = TRUE)
      {
        stopifnot(nrow(W) == ncol(W)) 
        
        g = colSums(W) # degrees of vertices
        n = nrow(W)
        
        if(normalized)
        {
          D_half = diag(1 / sqrt(g) )
          return( diag(n) - D_half %*% W %*% D_half )
        }
        else
        {
          return( diag(g) - W )
        }
      }
      
      # 1. matrix of similarities
      W = mutual_knn_graph(X) 
      # 2. compute graph laplacian
      L = graph_laplacian(W) 
      # 3. Compute the eigenvectors and values of L
      ei = eigen(L, symmetric = TRUE) 
      n = nrow(L)
      # return the eigenvectors of the n_eig smallest eigenvalues
      return(ei$vectors[,(n - n_eig):(n - 1)]) 

    }

    # do spectral clustering procedure

    X_sc <- spectral_clustering(X)

    # run kmeans on the 2 eigenvectors
    X_sc_kmeans <- kmeans(X_sc, 3)

```

