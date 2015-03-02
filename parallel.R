## @knitr RlinAlg

# install.packages('RhpcBLASctl')
require(RhpcBLASctl)
# I use RhpcBLASctl to control threading for purpose of demo
# but one can also set OMP_NUM_THREADS in the shell before invoking R
x <- matrix(rnorm(5000^2), 5000)

blas_set_num_threads(4)
system.time({
x <- crossprod(x)
U <- chol(x)
})

blas_set_num_threads(1)
system.time({
x <- crossprod(x)
U <- chol(x)
})

## @knitr foreach

require(parallel) # one of the core R packages
require(doParallel)
# require(multicore); require(doMC) # alternative to parallel/doParallel
# require(Rmpi); require(doMPI) # to use Rmpi as the back-end
library(foreach)

taskFun <- function(){
	mn <- mean(rnorm(10000000))
	return(mn)
}
nCores <- 2  
registerDoParallel(nCores) 
# registerDoMC(nCores) # alternative to registerDoParallel
# cl <- startMPIcluster(nCores); registerDoMPI(cl) # when using Rmpi as the back-end

out <- foreach(i = 1:40) %dopar% {
	cat('Starting ', i, 'th job.\n', sep = '')
	outSub <- taskFun()
	cat('Finishing ', i, 'th job.\n', sep = '')
	outSub # this will become part of the out object
}

## @knitr parallelApply

require(parallel)
nCores <- 2

nSims <- 60
input <- seq_len(nSims) # same as 1:nSims but more robust


testFun <- function(i){
	mn <- mean(rnorm(1000000))
	return(mn)
}

################################
# using forking (mclapply)
################################


system.time(
	res <- mclapply(input, testFun, mc.cores = nCores) 
)

#############################
# using sockets (parLapply)
#############################

# ?clusterApply
cl <- makeCluster(nCores) # by default this uses the PSOCK 
#  mechanism as in the SNOW package - starting new jobs via Rscript 
#  and communicating via sockets

# clusterExport(cl, c('x', 'y')) # if the processes need objects 
#   (x and y, here) from the master's workspace
system.time(
	res <- parSapply(cl, input, testFun) # or parLapply()
)
system.time(
	res2 <- sapply(input, testFun)
)




## @knitr mcparallel

library(parallel)
n <- 10000000
system.time({
	p <- mcparallel(mean(rnorm(n)))
	q <- mcparallel(mean(rgamma(n, shape = 1)))
	res <- mccollect(list(p,q))
})
system.time({
	p <- mean(rnorm(n))
	q <- mean(rgamma(n, shape = 1))
})


## @knitr Rmpi-foreach-oneNode

library(Rmpi)
library(doMPI)

nCores = 2

cl = startMPIcluster(nCores)                                         

registerDoMPI(cl)
clusterSize(cl) # just to check

nIts <- 20

results <- foreach(i = 1:nIts) %dopar% {
  out = mean(rnorm(1e7))
}

print(unlist(results))

closeCluster(cl)



## @knitr sockets-multipleNodes

# multinode example with PSOCK cluster

library(parallel)

machineVec = c(rep("master", 2),
    rep("node001", 2),
    rep("node002", 2))
cl = makeCluster(machineVec)

n = 1e7
clusterExport(cl, c('n'))
fun = function(i)
  out = mean(rnorm(n))
  
result <- parSapply(cl, 1:20, fun)

stopCluster(cl) # not strictly necessary

## @knitr Rmpi-usingMPIsyntax

# example syntax of standard MPI functions

library(Rmpi)
mpi.spawn.Rslaves(nslaves = 3)

n = 5
mpi.bcast.Robj2slave(n)
mpi.bcast.cmd(id <- mpi.comm.rank())
mpi.bcast.cmd(x <- rnorm(id))

mpi.remote.exec(ls(.GlobalEnv), ret = TRUE)

mpi.bcast.cmd(y <- 2 * x)
mpi.remote.exec(print(y))

objs <- c('y', 'z')
# next command sends value of objs on _master_ as argument to rm
mpi.remote.exec(rm, objs)  
mpi.remote.exec(print(z))

# collect results back via send/recv
mpi.remote.exec(mpi.send.Robj(x, dest = 0, tag = 1))
results = list()
for(i in 1:(mpi.comm.size()-1)){
  results[[i]] = mpi.recv.Robj(source = i, tag = 1)
}
  
print(results)

## @knitr RNG-apply

require(parallel)
require(rlecuyer)
nSims <- 250
testFun <- function(i){
	val <- runif(1)
	return(val)
}

nSlots <- 2
RNGkind()
cl <- makeCluster(nSlots)
iseed <- 0
# ?clusterSetRNGStream
clusterSetRNGStream(cl = cl, iseed = iseed)
RNGkind() # clusterSetRNGStream sets RNGkind as L'Ecuyer-CMRG
# but it doesn't show up here on the master
res <- parSapply(cl, 1:nSims, testFun)
clusterSetRNGStream(cl = cl, iseed = iseed)
res2 <- parSapply(cl, 1:nSims, testFun)
identical(res,res2)
stopCluster(cl)

## @knitr RNGstream

RNGkind("L'Ecuyer-CMRG") 
seed <- 0
set.seed(seed) ## now start M workers 
s <- .Random.seed 
for (i in 1:M) { 
	s <- nextRNGStream(s) 
	# send s to worker i as .Random.seed 
} 

## @knitr RNG-mclapply

require(parallel)
require(rlecuyer)
RNGkind("L'Ecuyer-CMRG")
res <- mclapply(seq_len(nSims), testFun, mc.cores = nSlots, 
    mc.set.seed = TRUE) 
# this also seems to reset the seed when it is run
res2 <- mclapply(seq_len(nSims), testFun, mc.cores = nSlots, 
    mc.set.seed = TRUE) 
identical(res,res2)

## @knitr RNG-doMPI

nslaves <- 2
library(doMPI, quietly = TRUE)
cl <- startMPIcluster(nslaves)
registerDoMPI(cl) 
result <- foreach(i = 1:20, .options.mpi = list(seed = 0)) %dopar% { 
	out <- mean(rnorm(1000)) 
}
result2 <- foreach(i = 1:20, .options.mpi = list(seed = 0)) %dopar% { 
	out <- mean(rnorm(1000)) 
}
identical(result, result2)

## @knitr RNG-doRNG

rm(result, result2)
nCores <- 2
library(doRNG, quietly = TRUE)
library(doParallel)
registerDoParallel(nCores) 
result <- foreach(i = 1:20, .options.RNG = 0) %dorng% { 
	out <- mean(rnorm(1000)) 
}
result2 <- foreach(i = 1:20, .options.RNG = 0) %dorng% { 
	out <- mean(rnorm(1000)) 
}
identical(result, result2)

## @knitr RNG-doRNG2

rm(result, result2)
library(doRNG, quietly = TRUE)
library(doParallel)
registerDoParallel(nCores)
registerDoRNG(seed = 0) 
result <- foreach(i = 1:20) %dopar% { 
	out <- mean(rnorm(1000)) 
}
registerDoRNG(seed = 0) 
result2 <- foreach(i = 1:20) %dopar% { 
	out <- mean(rnorm(1000)) 
}
identical(result,result2)

