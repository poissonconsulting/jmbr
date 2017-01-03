inits <- function(data, gen_inits, nchains) {
  if (identical(gen_inits(data), list())) return(NULL)

  inits <- list()
  for (i in 1:nchains) {
    inits[[i]] <- gen_inits(data)
  }
  inits
}
