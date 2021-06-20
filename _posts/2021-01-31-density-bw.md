---
layout: post
title: Kernel Density Estimation using density():<br> How does R select the bandwidth? 
date: 2021-01-31
categories:
tag: statistics
---
<head>
<script type="text/javascript"
    src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML">
</script>
</head>


Kernel density estimation is a key tool in statistical inference. It's often used for exploratory data analysis (For example, you might want to see how some variables are distributed before applying a statistical test). It can also be first step in more complex analysis. 

<b>It's also one of the easiest tools to use in R without having to know the complete mechanism behind it.</b> An R user can quickly get a density estimate using the built-in function `density()`, which **automatically selects the right bandwidth for your data**. The question is, how does R do that? And why should we need to know?

This blog post gives a simple explanation, with a reproducible example in R. The code can be found at the end of the post.


## Example: Heights of Cherry Trees 

Let's begin with a simple example of when you would want to estimate a density. 

Suppose you are a botanist who studies cherry trees. You want to get an idea of how high can cherry trees grow. You therefore collect a sample of 31 felled cherry trees and measure their heights. Let's see what the distribution of heights looks like:

<img src="{{site.baseurl}}/assets/images/histogram-density-trees.png"/>

Our first estimator, the histogram estimator, gives us a good idea of how our data are distributed. We can easily see that the average height of a cherry tree in our sample is somewhere between 75 and 80 feet. The histogram partitions the domain (here, the set of possible cherry tree heights) into equally-spaced bins, and it estimates the density at each bin as the count of observations falling in the bin.

Our second estimator, the Kernel Density Estimator, is a smoothed version of the histogram. Visually, it's a lot easier to see how our data are distributed, and where the center of the data lies. We can see that the heights of cherry trees are roughly symmetric with the center of the distribution around 76 feet (the sample mean and mode is 76 feet).

## Kernel Density Estimation: A Quick Overview

More generally, we can say that we are in the following situation: we have a single variable $$X = X_1 \dots X_n$$ drawn $$iid$$ from a  distribution with underlying probability density function $$f$$. Our goal is to construct an estimator $$\hat{f}$$ that is a probability density function. A Kernel Density Estimator $$\hat{f}_{\text{KDE}}(x)$$ is

$$ \hat{f}_{\text{KDE}}(x) = n^{-1}h^{-1}\sum_{i=1}^{n}K(h^{-1}(x - X_{i}))$$

where 
* $$K$$ is a kernel, a weighting function, often taken to be a symmetric probability density function 
* $$h$$ is the bandwidth, which is a smoothing parameter. You can think of it along the same lines as the bin width of a histogram estimator


You can think of this estimator as fitting masses above each data point and summing them. $$K$$ determines the form of the mass, and $$h$$ determines the width. 


## Selecting the bandwidth

When fitting this estimator, we decide what Kernel to use, and what bandwidth to select. While there are differences between Kernels in terms of efficiency, the choice of Kernel does not matter too much, in most cases. The choice of bandwidth, however, is critical.

<img src="{{site.baseurl}}/assets/images/kde-bws.png"/>

Let's return to our cherry tree example. Here, we display the Kernel Density Estimates with different values of $$h$$: 1, 2, 2.704 (the default bandwidth selected by R) and 5. While the differences are nominally small, the outcome are wildly different. Looking clockwise, starting from the top-left, we see the first two estimates are undersmoothed. We would not want this visualization of our data. The last estimate is over-smoothed - the density looks perfectly symmetric, missing the actual distribution of the data. 

Needless to say, even a small difference in $$h$$ can yield a very different estimator. So, how do we know what $$h$$ to select?

An estimator can be thought of as "good" if it has as low global error as possible. In density estimation, we measure error in terms of the Mean Integrated Squared Error:

$$\text{MISE}(\hat{f}) = E\int_{}^{}(\hat{f}(x) - f(x))^2$$

Which is a global measure of Mean Squared Error, a standard measure of error in statistics. The optimal $$h$$ would be that which minimizes the MISE of the Kernel Density Estimator.

We can derive an exact expression for MISE$$(\hat{f}_{\text{KDE}}(.))$$, but it relies on $$h$$ in a complicated manner. Instead, we can derive an asymptotic expression, the AMISE:


$$\text{AMISE}(\hat{f}_{\text{KDE}}(.)) = \frac{1}{4}h^{4}\mu_{2}^{2}R(f'') + \frac{1}{nh}R(K)$$

where
$$\mu_2 = \int_{}^{}K(u)u^2du$$ and
$$R(K) = \int_{}^{}K^2(u)du$$


Once we select the kernel, it would be straightforward to solve for $$h$$. However, we see one big issue: this expression is that it relies on our unknown density $$f$$! 


### Silverman's Rule of Thumb

One way around this is to reference a known distribution. Suppose $$f$$ is Normally distributed with some mean $$\mu$$ and variance $$\sigma^2$$. Then we can obtain the second moment of $$f$$ and, after some calculation, obtain 

$$h_{\text{AMISE}} = \Bigg(\frac{8\sqrt{\pi}R(K)}{3\mu_2^{2}}\Bigg)^{1/5}\sigma n^{-1/5}$$


If we take the Gaussian Kernel $$K$$ (this is the default in R), we can consider two good options for estimating $$\sigma$$: the sample standard deviation $$S$$, where $$\bar{X}$$ is the sample mean, 

$$S = \sqrt{\frac{1}{n-1} \sum_{i=1}^{n}(X_{i} - \bar{X})^2}$$


or the standardized sample interquartile range, 


$$\hat{\sigma} = \frac{\text{Q3 - Q1}}{\Phi^{-1}(3/4) - \Phi^{-1}(1/4)}$$


we get the following rule-of-thumb badwidth selection rule:

$$\hat{h} = \Bigg(\frac{8\sqrt{\pi}R(K)}{3\mu_2^{2}}\Bigg)^{1/5} \text{min}(S, \hat{\sigma}) n^{-1/5}$$


For a standard Normal Kernel, this is 
$$1.06\text{min}(S, \hat{\sigma}) n^{-1/5}$$. 

This is implemented in R as the function `bw.nrd()`. Silverman's Rule of Thumb recommends to use 

$$0.9\text{min}(S, \hat{\sigma}) n^{-1/5}$$ 

instead, in order to not miss bimodality. This calculation is exactly what R uses to select the bandwidth! We can take a quick look:

```r
data(trees)
trees$Height # our data of interest

n <- length(trees$Height)
S <- sd(trees$Height)
sigma_hat <- IQR(trees$Height)/1.34#(qnorm(3/4)-qnorm(1/4))

# Silverman Rule of Thumb
bw.nrd0(trees$Height)
# [1] 2.70368
0.9*min(S,sigma_hat)*(n^(-1/5))
# [1] 2.70368

# Scott (1992)
bw.nrd(trees$Height)
# [1] 3.184335
1.06*min(S,sigma_hat)*(n^(-1/5))
# [1] 3.184335
```

### So, Why does it matter?

The default Silverman rule-of-thumb estimator might be the best choice for some situations, but it might not the best choice for others. In our example, the default badwidth makes sense to use. 

Now, let's suppose that the scientist found one more tree: a young tree that is only 45 feet tall. Not knowing that the tree is still growing, the scientist adds it to his sample. With the default bandwidth, the density becomes the lefthand plot. From inspection, it looks like the data are multimodal, when in reality, there's just an outlier!

<img src="{{site.baseurl}}/assets/images/density-outliers.png"/>


Knowing that our smallest tree is merely an outlier, we can assume that our underlying distribution has only one mode. Then, using another rule from Silverman, we can select a bandwidth that ensures unimodality. This yields the righthand plot, which is much more realistic.


## References








