jmb_analyse_chain <- function(inits, loaded, data, monitor, niters, ngens, nthin, quiet) {

  capture_output <- if (quiet) function(x) suppressWarnings(capture.output(x)) else eval

  capture_output(
    jags_model <- rjags::jags.model(loaded, data, inits = inits, n.adapt = 0, quiet = quiet)
  )

  niters <- niters * nthin
  adapted <- rjags::adapt(jags_model, n.iter = floor(niters / 2),
                          progress.bar = "none", end.adaptation = TRUE)

  if (!adapted) warning("incomplete adaptation")

  update(jags_model, n.iter = floor(niters / 2), progress.bar = "none")

  monitor <- monitor[monitor %in% stats::variable.names(jags_model)]

  jags_samples <- rjags::jags.samples(model = jags_model, variable.names = monitor,
                                      n.iter = niters, thin = nthin, progress.bar = "none")

  list(jags_model = jags_model, jags_samples = jags_samples)
}

#' @export
analyse1.jmb_model <- function(model, data, loaded, nchains, niters, nthin, quiet, glance, parallel, ...) {

  timer <- timer::Timer$new()
  timer$start()

  obj <- list(model = model, data = data)

  data %<>% mbr::modify_data(model = model)

  inits <- inits(data, model$gen_inits, nchains = nchains)

  monitor <- mbr::monitor(model)
  monitor <- monitor[!monitor %in% names(data)]

  jags_chains <- llply(inits, .fun = jmb_analyse_chain,
                       .parallel = parallel,
                       loaded = loaded,
                       data = data,
                       monitor = monitor,
                       niters = niters,
                       nthin = nthin,
                       quiet = quiet)

  mcmc <- llply(jags_chains, function(x) x$jags_samples)
  mcmc <- lapply(mcmc, function(x) mcmcr::as.mcmcr(lapply(x, mcmcr::as.mcmcarray)))
  mcmc <- Reduce(mcmcr::bind_chains, mcmc)

  obj %<>% c(inits = list(inits),
             jags_chains = list(jags_chains),
             mcmcr = list(mcmc),
             nthin = nthin)

  obj$duration <- timer$elapsed()
  class(obj) <- c("jmb_analysis", "mb_analysis")

  if (glance) print(glance(obj))

  obj
}
