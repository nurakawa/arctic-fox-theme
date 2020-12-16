# Memory issues in R

It's a common problem to run out of memory in an R session. This happens from performing operations on data that take more computational power space than what is allocated to your R. 

To get an understanding of how R uses memory, read this: http://adv-r.had.co.nz/memory.html.

For now, what can you do if you encounter memory issues?

1. Allocate more memory to your R session. If you use Windows you can check the limit using `memory.limit()` and you can increase it. I am not sure if this works on MAC OSX. If not, you can at least check memory allocation by running garbage collection `gc()`. 

To start R with more memory, the way I have been successful is to use the command line and run your R session from there. I recommend to follow this: https://astrostatistics.psu.edu/su07/R/library/base/html/Memory.html.

Please note that this uses a lot of the RAM on your computer, so it's a good idea to not run anything else on your computer at the same time.

2. If your data is big, consider R packages for big data, such as bigmemory. There are also some projects for distributed systems with R.

3. Split your data into smaller datasets and apply operations separately, if possible. This looks like a good read: https://rviews.rstudio.com/2019/07/17/3-big-data-strategies-for-r/

