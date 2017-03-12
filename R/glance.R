#' @export
glance.jmb_analysis <- function(x, n = NULL, rhat = getOption("mb.rhat", 1.1), ...) {
  check_number(rhat)

  rhat_analysis <- rhat(x)
  rhat_arg <- rhat

  dplyr::data_frame(
    n = sample_size(x),
    K = nterms(x, include_constant = FALSE),
    nsims = nsims(x),
    nchains = nchains(x),
    nsamples = niters(x) * nsims(x), # import nsamples
    duration = elapsed(x),
    rhat = rhat_analysis,
    converged = rhat_analysis <= rhat_arg
  )
}
