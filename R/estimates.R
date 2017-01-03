#' @export
estimates.tmb_analysis <- function(object, terms = "fixed", scalar_only = FALSE, ...) {
  possible <- c("fixed", "random", "report", "adreport")
  if (identical(terms, "all")) terms <- possible
  if (identical(terms, "primary")) terms <- c("fixed", "random")

  terms %<>% unique()

  if (length(terms) > 1) {
    terms %<>% lapply(function(term) {estimates(object, terms = term, scalar_only = scalar_only)})
    terms %<>% unlist(recursive = FALSE)
    terms %<>% sort_nlist()
    return(terms)
  }

  check_scalar(terms, possible)
  check_flag(scalar_only)

  if (terms == "report") {
    estimates <- object$report
    estimates %<>% remap_estimates(object$map)
  } else if (terms == "adreport") {
    estimates <- list_by_name(object$sd$value)
    estimates %<>% remap_estimates(object$map)
  } else {
    if (terms == "fixed") {
      estimates <- object$sd$par.fixed
    } else
      estimates <- object$sd$par.random

    estimates %<>% list_by_name()
    estimates %<>% remap_estimates(object$map)
    inits <- object$inits[names(estimates)]
    inits %<>% lapply(dims)
    estimates %<>% purrr::map2(inits, by_dims)
  }
  if (scalar_only) estimates %<>% scalar_nlist()
  estimates %<>% sort_nlist()
  estimates
}
