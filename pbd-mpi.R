## @knitr pbd-mpi


library(pbdMPI, quiet = TRUE )
init()

myRank <- comm.rank () # comm index starts at 0 , not 1
comm.print(myRank , all.rank=TRUE)
node <- system("cat /etc/hostname", intern = TRUE) # Sys.getenv("HOSTNAME")
if(myRank == 0) {
    comm.print(paste0("hello, world from ", myRank, " ", node), all.rank=TRUE)
} else comm.print(paste0("goodbye from ", myRank, " ", node), all.rank=TRUE)

if(comm.rank() == 0) print(date())
N.gbd <- 1e7
X.gbd <- matrix ( runif ( N.gbd * 2) , ncol = 2)
r.gbd <- sum ( rowSums ( X.gbd^2) <= 1)
ret <- allreduce ( c ( N.gbd , r.gbd ) , op = "sum" )
PI <- 4 * ret [2] / ret [1]
comm.print(paste0("Pi is roughly: ", PI))
if(comm.rank() == 0) print(date())

finalize ()
