jmb_analysis <- function(data, model, quick, quiet, parallel) {
  timer <- timer::Timer$new()
  timer$start()

  obj <- list(model = model, data = data)

  data %<>% mbr::modify_data(model = model)
#
#   inits <- inits(data, model$gen_inits, model$random_effects)
#
#   if (any(names(inits) %in% c("fixed", "primary", "random", "report", "adreport", "all")))
#     error("parameters cannot be named 'fixed', 'primary', 'random', 'report', 'adreport' or 'all'")
#
#   map <- map(inits)
#
#   inits %<>% lapply(function(x) {x[is.na(x)] <- 0; x})
#
#   ad_fun <- TMB::MakeADFun(data = data, inits, map = map,
#                            random = names(model$random_effects),
#                            DLL = basename(tempfile), silent = quiet)
#
#   opt <- do.call("optim", ad_fun)
#
#   sd <- TMB::sdreport(ad_fun)
#   report <- ad_fun$report()

#  obj %<>% c(inits = list(inits), map = list(map), ad_fun = list(ad_fun), opt = list(opt),
#             sd = list(sd), report = list(report), duration = timer$elapsed())
  class(obj) <- c("jmb_analysis", "mb_analysis")
  obj
}

#' @export
analyse.jmb_model <- function(model, data, drop = character(0),
                              quick = getOption("mb.quick", FALSE),
                              quiet = getOption("mb.quiet", TRUE),
                              parallel = getOption("mb.parallel", FALSE),
                              beep = getOption("mb.beep", TRUE),
                              ...) {
  if (is.data.frame(data)) {
    check_data2(data)
  } else if (is.list(data)) {
    lapply(data, check_data2)
  } else error("data must be a data.frame or a list of data.frames")

  check_vector(drop, "", min_length = 0)
  check_flag(quick)
  check_flag(quiet)
  check_flag(parallel)
  check_flag(beep)
  check_unused(...)

  if (beep) on.exit(beepr::beep())

  ops <- options(jags.pd = "none")
  on.exit(options(ops), add = TRUE)

  rjags::load.module("basemod", quiet = quiet)
  rjags::load.module("bugs", quiet = quiet)

  model %<>% drop_parameters(parameters = drop)

  if (is.data.frame(data)) {
    return(jmb_analysis(data = data, model = model, quick = quick, quiet = quiet, parallel = parallel))
  }

  lapply(data, tmb_analysis, model = model, quick = quick, quiet = quiet, parallel = parallel)
}
