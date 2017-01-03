inits <- function(data, gen_inits, nchains) {
  inits <- list()
  for (i in 1:nchains) {
    inits[[i]] <- gen_inits(data)
  }
  inits
}
