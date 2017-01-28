jmb_reanalyse_chain <- function(jags_chain, niters, nthin, quiet) {

  jags_model <- jags_chain$jags_model

  if (quiet) {
    utils::capture.output(jags_model$recompile())
  } else {
    jags_model$recompile()
  }

  jags_model %<>% adapt()

  vars <- names(jags_chain$jags_samples)

  jags_samples <- rjags::jags.samples(model = jags_model, variable.names = vars, n.iter = niters/2, thin = nthin, progress.bar = "none")

  list(jags_model = jags_model, jags_samples = jags_samples)
}

jmb_reanalyse_internal <- function(analysis, parallel, quiet) {
  timer <- timer::Timer$new()
  timer$start()

  niters <- analysis$ngens * 2
  nchains <- length(analysis$jags_chains)
  nthin <- niters * nchains / (2000 * 2)

  analysis$jags_chains %<>% plapply(jmb_reanalyse_chain, .parallel = parallel, niters = niters, nthin = nthin, quiet = quiet)

  mcmcr <- lapply(analysis$jags_chains, function(x) x$jags_samples)
  mcmcr %<>% lapply(mcmcr::as.mcmcr)
  mcmcr %<>% purrr::reduce(mcmcr::bind_chains)

  analysis$mcmcr <- mcmcr
  analysis$ngens <- as.integer(niters)
  analysis$duration %<>% magrittr::add(timer$elapsed())
  analysis
}

jmb_reanalyse <- function(analysis, rhat, minutes, quick, quiet, parallel) {

  if (quick || converged(analysis, rhat) || minutes < elapsed(analysis) * 2) {
    print(glance(analysis))
    return(analysis)
  }

  while (!converged(analysis, rhat) && minutes >= elapsed(analysis) * 2) {
    analysis %<>% jmb_reanalyse_internal(parallel = parallel, quiet = quiet)
    print(glance(analysis))
  }
  analysis
}

#' @export
reanalyse.jmb_analysis <- function(analysis,
                                   rhat = getOption("mb.rhat", 1.1),
                                   minutes = getOption("mb.minutes", 60L),
                                   parallel = getOption("mb.parallel", FALSE),
                                   quick = getOption("mb.quick", FALSE),
                                   quiet = getOption("mb.quiet", TRUE),
                                   beep = getOption("mb.beep", TRUE),
                                   ...) {

  check_count(minutes)
  check_flag(quick)
  check_flag(quiet)
  check_flag(parallel)
  check_flag(beep)

  if (beep) on.exit(beepr::beep())

  rjags::load.module("basemod", quiet = quiet)
  rjags::load.module("bugs", quiet = quiet)

  jmb_reanalyse(analysis, rhat = rhat, minutes = minutes, quick = quick, quiet = quiet, parallel = parallel)
}
