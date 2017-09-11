jmb_reanalyse_chain <- function(jags_chain, ngens, nthin, quiet) {
  jags_model <- jags_chain$jags_model

  if (quiet) {
    utils::capture.output(jags_model$recompile())
  } else {
    jags_model$recompile()
  }
  monitor <- names(jags_chain$jags_samples)

  if (quiet) {
    utils::capture.output(jags_samples <- rjags::jags.samples(model = jags_model, variable.names = monitor, n.iter = ngens/2L, thin = nthin, progress.bar = "none"))
  } else {
    utils::capture.output(jags_samples <- rjags::jags.samples(model = jags_model, variable.names = monitor, n.iter = ngens/2L, thin = nthin, progress.bar = "none"))
  }
  list(jags_model = jags_model, jags_samples = jags_samples)
}

jmb_reanalyse_internal <- function(object, parallel, quiet) {
  timer <- timer::Timer$new()
  timer$start()

  ngens <- object$ngens * 2L
  nchains <- length(object$jags_chains)
  nthin <- ngens * nchains / (2000 * 2)

  object$jags_chains %<>% llply(.fun = jmb_reanalyse_chain, .parallel = parallel, ngens = ngens, nthin = nthin, quiet = quiet)

  mcmcr <- llply(object$jags_chains, function(x) x$jags_samples)
  mcmcr %<>% llply(mcmcr::as.mcmcr)
  mcmcr %<>% purrr::reduce(mcmcr::bind_chains)

  object$mcmcr <- mcmcr
  object$ngens <- as.integer(ngens)
  object$duration %<>% magrittr::add(timer$elapsed())
  object
}

jmb_reanalyse <- function(object, rhat, nreanalyses, duration, quick, quiet, parallel, glance) {
  if (quick || duration < elapsed(object) * 2 || converged(object, rhat)) {
    if (glance) print(glance(object))
    return(object)
  }

  while (nreanalyses > 0L && duration >= elapsed(object) * 2 && !converged(object, rhat)) {
    object %<>% jmb_reanalyse_internal(parallel = parallel, quiet = quiet)
    nreanalyses %<>% magrittr::subtract(1L)
    if (glance) print(glance(object))
  }
  object

}

#' Reanalyse
#'
#' @param object The object to reanalyse.
#' @param rhat A number specifying the rhat threshold.
#' @param nreanalyses A count between 1 and 6 specifying the maximum number of reanalyses.
#' @param duration The maximum total time to spend on analysis/reanalysis.
#' @param quick A flag indicating whether to quickly get unreliable values.
#' @param quiet A flag indicating whether to disable tracing information.
#' @param glance A flag indicating whether to print summary of model.
#' @param beep A flag indicating whether to beep on completion of the analysis.
#' @param parallel A flag indicating whether to perform the analysis in parallel if possible.
#' @param ... Unused arguments.
#' @export
reanalyse.jmb_analysis <- function(object,
                                   rhat = getOption("mb.rhat", 1.1),
                                   nreanalyses = getOption("mb.nreanalyses", 1L),
                                   duration = getOption("mb.duration", dhours(1)),
                                   parallel = getOption("mb.parallel", FALSE),
                                   quick = getOption("mb.quick", FALSE),
                                   quiet = getOption("mb.quiet", TRUE),
                                   glance = getOption("mb.glance", TRUE),
                                   beep = getOption("mb.beep", TRUE),
                                   ...) {

  if (beep) on.exit(beepr::beep())

  check_scalar(nreanalyses, c(1L, 6L))
  if (!is.duration(duration)) error("duration must be an object of class Duration")
  check_flag(quick)
  check_flag(quiet)
  check_flag(parallel)
  check_flag(glance)
  check_flag(beep)

  rjags::load.module("basemod", quiet = quiet)
  rjags::load.module("bugs", quiet = quiet)

  jmb_reanalyse(object, rhat = rhat, nreanalyses = nreanalyses,
                duration = duration, quick = quick, quiet = quiet,
                parallel = parallel, glance = glance)
}
