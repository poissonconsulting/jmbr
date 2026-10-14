inits <- function(data, gen_inits, nchains, seed) {
  rng_names <- paste0(
    "base::",
    c(
      "Wichmann-Hill",
      "Marsaglia-Multicarry",
      "Super-Duper",
      "Mersenne-Twister"
    )
  )

  withr::with_seed(seed, {
    rng_seeds <- sample.int(.Machine$integer.max, nchains)

    inits <- list()
    for (i in 1:nchains) {
      rng <- list(
        .RNG.name = rng_names[(i - 1) %% length(rng_names) + 1],
        .RNG.seed = rng_seeds[i]
      )
      inits[[i]] <- c(gen_inits(data), rng)
    }
  })

  inits
}
