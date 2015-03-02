
## @knitr Rmpi-foreach-multipleNodes


library(Rmpi)
library(doMPI)

cl = startMPIcluster()  # by default will start one fewer slave
# than elements in .hosts
                                        

registerDoMPI(cl)
clusterSize(cl) # just to check

nIts <- 50

results <- foreach(i = 1:nIts) %dopar% {
  out = mean(rnorm(1e7))
}
print(unlist(out))

closeCluster(cl)

mpi.quit()



