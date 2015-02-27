library(Rmpi)
library(doMPI)

cl = startMPIcluster()  # by default will start one fewer slave
# than elements in .hosts
                                        

registerDoMPI(cl)
clusterSize(cl) # just to check

results <- foreach(i = 1:200) %dopar% {
  out = mean(rnorm(1e7))
}

closeCluster(cl)

mpi.quit()
