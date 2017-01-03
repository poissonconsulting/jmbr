jmb_chain <- function(inits, tempfile = tempfile, data, monitor, niters, nthin, quick = quick, quiet = quiet) {
  nadapt <- niters / 10
  if (quick) nadapt <- 0

  if (quiet) {
    suppressWarnings(jags <- rjags::jags.model(tempfile, data, inits = inits, n.adapt = nadapt, quiet = quiet))
  } else {
    jags <- rjags::jags.model(tempfile, data, inits = inits, n.adapt = nadapt, quiet = quiet)
  }

  update(jags, n.iter = niters/2, progress.bar = "none")

  vars <- variable_names(jags, data, monitor)

 samples <- rjags::jags.samples(model = jags, variable.names = vars, n.iter = niters/2, thin = nthin, progress.bar = "none")

  list(samples, jags)
}

jmb_analysis <- function(data, model, tempfile, quick, quiet, parallel) {
  timer <- timer::Timer$new()
  timer$start()

  niters <- model$niters
  nchains <- 4L
  nthin <- niters * nchains / 2000 * 2

  if (quick) {
    niters <- 10
    nchains <- 2L
    nthin <- 1L
  }

  obj <- list(model = model, data = data)

  data %<>% mbr::modify_data(model = model)

  inits <- inits(data, model$gen_inits, nchains = nchains)

  monitor <- model$monitor

  if (!parallel) {
    jags <- purrr::map(inits, jmb_chain, tempfile = tempfile, data = data, monitor = monitor, niters = niters, nthin = nthin, quick = quick, quiet = quiet)
  } else
    jags <- purrr::pmap(inits, jmb_chain, tempfile = tempfile, data = data, monitor = monitor, niters = niters, nthin = nthin, quick = quick, quiet = quiet)


  obj %<>% c(inits = list(inits), jags = list(jags), duration = timer$elapsed())
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

  model %<>% drop_parameters(parameters = drop)

  tempfile <- tempfile(fileext = ".bug")
  write(template(model), file = tempfile)

  rjags::load.module("basemod", quiet = quiet)
  rjags::load.module("bugs", quiet = quiet)

  if (is.data.frame(data)) {
    return(jmb_analysis(data = data, model = model, tempfile = tempfile,
                        quick = quick, quiet = quiet, parallel = parallel))
  }

  lapply(data, jmb_analysis, model = model, tempfile = tempfile,
         quick = quick, quiet = quiet, parallel = parallel)
}
