## @knitr Rmpi-usingMPIsyntax

# example syntax of standard MPI functions

library(Rmpi)
nSlaves <- 3
mpi.spawn.Rslaves(nslaves = nSlaves)

n <- 5
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

mpi.close.Rslaves()
mpi.exit()
