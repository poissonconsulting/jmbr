jmb_reanalyse_chain <- function(jags_chain, niters, nthin, quiet) {

  jags_model <- jags_chain$jags_model

  vars <- names(jags_chain$jags_samples)

  jags_samples <- rjags::jags.samples(model = jags_model, variable.names = vars, n.iter = niters/2, thin = nthin, progress.bar = "none")

  list(jags_model = jags_model, jags_samples = jags_samples)
}

jmb_reanalyse <- function(analysis, quick, quiet, parallel) {

  if (quick) return(analysis)

  timer <- timer::Timer$new()
  timer$start()

  niters <- analysis$niters * 2
  nchains <- length(analysis$jags_chains)
  nthin <- niters * nchains / (2000 * 2)

  fun <- ifelse(parallel, purrr::pmap, purrr::map)

  analysis$jags_chains %<>% fun(jmb_reanalyse_chain, niters = niters, nthin = nthin, quiet = quiet)

  analysis$niters <- niters
  analysis$duration %<>% magrittr::add(timer$elapsed())
  analysis
}

#' @export
reanalyse.jmb_analysis <- function(analysis,
                                   parallel = getOption("mb.parallel", FALSE),
                                   quick = getOption("mb.quick", FALSE),
                                   quiet = getOption("mb.quiet", TRUE),
                                   beep = getOption("mb.beep", TRUE),
                                   ...) {

  check_flag(quick)
  check_flag(quiet)
  check_flag(parallel)
  check_flag(beep)
  check_unused(...)

  if (beep) on.exit(beepr::beep())

  rjags::load.module("basemod", quiet = quiet)
  rjags::load.module("bugs", quiet = quiet)

  jmb_reanalyse(analysis, quick = quick, quiet = quiet, parallel = parallel)
}
