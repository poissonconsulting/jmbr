jmb_analyse_chain <- function(inits, tempfile, data,
                              monitor, nadapt, ngens, nthin, quiet) {
  if (quiet) {
    suppressWarnings(jags_model <- rjags::jags.model(tempfile, data, inits = inits, n.adapt = nadapt, quiet = quiet))
  } else {
    jags_model <- rjags::jags.model(tempfile, data, inits = inits,
                                    n.adapt = 0, quiet = quiet)
    jags_model %<>% adapt(nadapt = nadapt)
  }

  update(jags_model, n.iter = ngens / 2L, progress.bar = "none")

  jags_samples <- rjags::jags.samples(
    model = jags_model, variable.names = monitor, n.iter = ngens / 2L,
    thin = nthin, progress.bar = "none")

  list(jags_model = jags_model, jags_samples = jags_samples)
}

jmb_analyse <- function(data, model, tempfile, quick, quiet, glance, parallel) {

  timer <- timer::Timer$new()
  timer$start()

  nchains <- 4L
  ngens <- model$ngens
  nadapt <- ngens / 10L
  nthin <- ngens * nchains / (2000 * 2)

  if (quick) {
    nchains <- 2L
    ngens <- 10
    nadapt <- 0
    nthin <- 1L
  }

  obj <- list(model = model, data = data)

  data %<>% mbr::modify_data(model = model)

  inits <- inits(data, model$gen_inits, nchains = nchains)

  monitor <- mbr::monitor(model)
  monitor <- monitor[!monitor %in% names(data)]

  jags_chains <- llply(inits, .fun = jmb_analyse_chain,
                       .parallel = parallel,
                       tempfile = tempfile, data = data,
                       monitor = monitor,
                       nadapt = nadapt, ngens = ngens, nthin = nthin,
                       quiet = quiet)

  mcmcr <- llply(jags_chains, function(x) x$jags_samples)
  mcmcr %<>% llply(mcmcr::as.mcmcr)
  mcmcr %<>% purrr::reduce(mcmcr::bind_chains)

  obj %<>% c(inits = list(inits),
             jags_chains = list(jags_chains),
             mcmcr = list(mcmcr),
             nadapt = nadapt,
             ngens = ngens)
  obj$duration <- timer$elapsed()
  class(obj) <- c("jmb_analysis", "mb_analysis")

  if (glance) print(glance(obj))

  obj
}

#' @export
analyse.jmb_model <- function(x, data,
                              parallel = getOption("mb.parallel", FALSE),
                              quick = getOption("mb.quick", FALSE),
                              quiet = getOption("mb.quiet", TRUE),
                              glance = getOption("mb.glance", TRUE),
                              beep = getOption("mb.beep", TRUE),
                              ...) {
  if (is.data.frame(data)) {
    check_data2(data)
  } else if (is.list(data)) {
    llply(data, check_data2)
  } else error("data must be a data.frame or a list of data.frames")

  check_flag(quick)
  check_flag(quiet)
  check_flag(parallel)
  check_flag(glance)
  check_flag(beep)

  if (beep) on.exit(beepr::beep())

  tempfile <- tempfile(fileext = ".bug")
  write(template(x), file = tempfile)

  rjags::load.module("basemod", quiet = quiet)
  rjags::load.module("bugs", quiet = quiet)

  if (is.data.frame(data)) {
    return(jmb_analyse(data = data, model = x, tempfile = tempfile,
                       quick = quick, quiet = quiet, glance = glance,
                       parallel = parallel))
  }

  llply(data, jmb_analyse, model = x, tempfile = tempfile,
        quick = quick, quiet = quiet, glance = glance, parallel = parallel)
}
