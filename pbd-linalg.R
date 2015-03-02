## @knitr pbd-linalg

library(pbdDMAT, quiet = TRUE )

n <- 4096*2

# if you are putting multiple processes on node
# you may want to prevent threading of the linear algebra:
# library(RhpcBLASctl)
# blas_set_num_threads(1)

init.grid()

if(comm.rank()==0) print(date())

# pbd allows for parallel I/O, but here
# we keep things simple and distribute
# an object from one process
if(comm.rank() == 0) {
    x <- rnorm(n^2)
    dim(x) <- c(n, n)
} else x <- NULL
dx <- as.ddmatrix(x)

timing <- comm.timer(sigma <- crossprod(dx))

if(comm.rank()==0) {
    print(date())
    print(timing)
}

timing <- comm.timer(out <- chol(sigma))

if(comm.rank()==0) {
    print(date())
    print(timing)
}


finalize()
