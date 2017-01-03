inits <- function(data, gen_inits, nchains) {
  rngs <- rjags::parallel.seeds("base::BaseRNG", nchains)

  if (identical(gen_inits(data), list())) return(rngs)

  inits <- list()
  for (i in 1:nchains) {
    inits[[i]] <- c(gen_inits(data), rngs[[i]])
  }

  inits
}
