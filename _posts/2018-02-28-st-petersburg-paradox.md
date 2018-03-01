---
layout: post
title: The St. Petersburg Paradox
date: 2018-02-28
categories:
---

<head>
<script type="text/javascript"
    src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML">
</script>
</head>

<br>
A friend of mine recently told me about the St. Petersburg Paradox, a puzzle presented by Daniel Bernoulli to the Imperial Academy of Sciences in St. Petersburg, Russia, in 1738. 

Suppose you play the following game at a casino:

<i>The game master starts with $1 on the table, and tells you to flip a coin. If you flip "Heads", the game master doubles the money to $2. You flip the coin again. If you again get "Heads", then the money on the table becomes $4, then $8, $16, $32, and so on. If you flip "Tails", the game is over, and you take the money from the table (however, if you flip "Tails" on the first trial, you take $0). </i>

The game master charges you $100 to play this game. Would that be a fair price to charge?

Let's consider a few scenarios. Suppose you play the game once, and you roll two heads in a row before hitting a tail. Then, your flip pattern is "H, H, T". Your expected payoff would be $$-100 + 2^2 = -96.$$ Now suppose you roll three heads in a row, and then a tail. Then, your flip pattern is "H, H, H, T", your expected payoff is: $$ -100 + 2^3 = -92. $$ In order to actually make money from this game, you would have to flip at least 
100 heads in a row! Given that this has probability $$\frac{1}{2^{100}}$$, you intuitively would not pay more than $5-10 for this game.


Now, let $$k$$ denote the number of heads in a row that you flip. We can take the Expected Value of your payoff, in other words the amount of money you expect to make if you play this game repeatedly for a long time. Your expected payoff is: 

$$  -100 + \sum_{k=0}^{\infty}{ P(k) 2^k }$$

$$= -100 + \sum_{k=0}^{\infty}{ \frac{1}{(2^{k+1})} 2^k }$$

$$= -100 + \sum_{k=0}^{\infty}{ \frac{1}{2} }$$

$$= -100 + \frac{1}{2} + \frac{1}{2} + \frac{1}{2} + \frac{1}{2} + ... + $$

$$= \infty $$


If you keep playing this game for an indefinite amount of time, your expected payoff is actually infinite. Therefore, it is in the best interest of a casino to not offer this game!

## The Paradox

If this game were to be offered, you should be willing to pay any price to play. The paradox is that our intuition says the opposite, despite the infinite expected value. There have been several proposed solutions to the paradox, one of which lead to the introduction of the utility function. You can read about the history of mathematicians tackling this problem, as well as some of its applications, [here](http://personal.psu.edu/dsr11/bgsu/bgtalk1.pdf).


## R Simulation

Here is a simple simulation of this game in R. It is a fun exercise to run the simulation for a large number of trials and see the results! 


```r
# coin flip
flip_coin <- function(){sample(c(1,0),1)} # here, H is 1, and T is 0

# game
game <- function(payoff=0, n_heads=0) #start with 0 earnings and 0 heads
{
  if(flip_coin() == 1){ # if you flip H
    n_heads <- n_heads + 1 # you got 1 more H in a row
    payoff <- 2^n_heads # you receive double your money
    
    game(payoff, n_heads)
  }
  else{
    return(payoff)
  }
}

Simulate_game <- function(n){
  results <- integer(n)
  i <- 1
  while(n > 0)
  {
    results[i] <- Game()
    n <- n - 1; i <- i + 1
  }
  return(results)
}


# based on:  https://gist.github.com/grano/fc854a2ffb2d6af8793b#file-st-petersburg-simulations-r

library(ggplot2)

RunSimulation <- function(timesToPlay=10000) {
  results <- rep(NA, timesToPlay)
  rollingAvg <- rep(NA, timesToPlay)
  for(i in 1:timesToPlay) {
    results[i] <- mean(Simulate_game(10))
    rollingAvg[i] <- mean(results[1:i])
  }
  
  df <- data.frame("mean_payoff" = rollingAvg,
                   "number_trials" = 1:timesToPlay)
  
  
  ggplot(df, 
       aes(x=number_trials,
           y=mean_payoff)) + geom_line() +
    ggtitle("Simulation of St. Peterburg Game")
}

RunSimulation()

```

<img src="{{site.baseurl}}/static/game_plot.png"/>




## References

Richards, Donald. "The St. Petersburg Paradox and the Quantification of Irrational Exuberance." Penn State University. [Source](http://personal.psu.edu/dsr11/bgsu/bgtalk1.pdf)

Granowitz, Andy. "Gist: Simulations and graph or rolling average for St. Petersburg paradox". [Source](https://gist.github.com/grano/fc854a2ffb2d6af8793b#file-st-petersburg-simulations-r)

and special thanks to my friend [Jens](https://github.com/jensmalm)!










