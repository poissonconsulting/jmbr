jmb_chain <- function (inits, tempfile = tempfile, data, niters, quick = quick, quiet = quiet) {
  nadapt <- 100L
  if (quick) nadapt <- 0L

  jags <- jags::jags.model(tempfile, data, inits = inits, n.adapt = nadapt, quiet = quiet)

  jags %<>% update(progress.bar = "none")

  if (n.burnin > 0)
    update(jags, n.iter = n.burnin)
}

jmb_analysis <- function(data, model, tempfile, quick, quiet, parallel) {
  timer <- timer::Timer$new()
  timer$start()

  niters <- model$niters
  nchains <- 4L

  if (quick) {
    niters <- 1L
    nchains <- 2L
  }

  obj <- list(model = model, data = data)

  data %<>% mbr::modify_data(model = model)

  inits <- inits(data, model$gen_inits, nchains = nchains)

  if (!parallel) {
    jags <- purrr::map(inits, jmb_chain, tempfile = tempfile, data, inits = inits, quick = quick, quiet = quiet)
  } else
    jags <- purrr::pmap(inits, jmb_chain, tempfile = tempfile, data, inits = inits, quick = quick, quiet = quiet)

#
#   opt <- do.call("optim", ad_fun)
#
#   sd <- TMB::sdreport(ad_fun)
#   report <- ad_fun$report()

  obj %<>% c(inits = list(inits), jags = jags) #, map = list(map), ad_fun = list(ad_fun), opt = list(opt),
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

  tempfile <- tempfile(fileext = ".bug")
  write(template(model), file = tempfile)

  if (is.data.frame(data)) {
    return(jmb_analysis(data = data, model = model, tempfile = tempfile,
                        quick = quick, quiet = quiet, parallel = parallel))
  }

  lapply(data, tmb_analysis, model = model, tempfile = tempfile,
         quick = quick, quiet = quiet, parallel = parallel)
}
