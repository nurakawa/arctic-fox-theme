# load data
data(trees)

# scatterplot
plot(trees$Height,
     xlab = 'Tree',
     ylab = 'Height (ft)',
     main = c('Scatterplot:','Heights of 31 Cherry Trees'))

par(mfrow=c(1,2))

# histogram
hist(trees$Height,
     breaks = 15,
     xlim = c(60,90),
     freq = F,
     xlab = 'Height (ft)',
     main = c('Histogram:','Heights of 31 Cherry Trees'))

plot(density(trees$Height),
     main = c('Kernel Density Estimate:', 
              'Heights of 31 Cherry Trees'))


par(mfrow=c(2,2))

bws <- c(1, 2, bw.nrd0(trees$Height),5)
for(b in bws){
  plot(density(trees$Height,
               bw=b),
       main = c('Kernel Density Estimate:', 
                'Heights of 31 Cherry Trees'))
}

data(trees)
trees$Height # our data of interest

n <- length(trees$Height)
S <- sd(trees$Height)
sigma_hat <- IQR(trees$Height)/1.34#(qnorm(3/4)-qnorm(1/4))

# Silverman Rule of Thumb
bw.nrd0(trees$Height)
0.9*min(S,sigma_hat)*(n^(-1/5))

# Scott (1992)
bw.nrd(trees$Height)
1.06*min(S,sigma_hat)*(n^(-1/5))


# add some outliers

trees2 <- c(trees$Height, 45)

require(multimode) # for the Silverman test

par(mfrow=c(1,2))
plot(density(trees2), main = 'Heights of Cherry Trees')
plot(density(trees2, bw=bw.crit(trees2)), main = 'Heights of Cherry Trees')

     