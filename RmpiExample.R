library(Rmpi)
nSlaves <- 3
mpi.spawn.Rslaves(nslaves = nSlaves)

n <- 2000
mpi.bcast.Robj2slave(n)

mpi.bcast.cmd(set.seed(mpi.comm.rank()))
mpi.bcast.cmd(y <- crossprod(matrix(rnorm(n^2), n)))

mpi.bcast.cmd(sumdiag <- sum(diag(y)))
mpi.remote.exec(print(sumdiag))

mpi.remote.exec(mpi.send.Robj(sumdiag, dest = 0, tag = 1))
results=list(); length(results) <- nSlaves
for(i in 1:nSlaves)
    results[[i]] = mpi.recv.Robj(source = i, tag = 1)
    

# out <- mpi.gather.Robj(sumdiag) # not working
mpi.close.Rslaves()

print(results)

# if started with mpirun, invoke:
# mpi.exit()
