## @knitr pbd-apply


library(pbdMPI, quiet = TRUE )
init()

if(comm.rank()==0) {
    x <- matrix(rnorm(1e6*50), 1e6)
}

sm <- comm.timer(pbdApply(x, 1, mean, pbd.mode = 'mw', rank.source = 0))
if(comm.rank()==0) {
    print(sm)
}

finalize()
