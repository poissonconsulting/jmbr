variable_names <- function(jags_model, data, regexp, named) {
  vars <- stats::variable.names(jags_model)

  vars <- vars[!vars %in% names(data)]

  vars <- vars[grepl(regexp, vars, perl = TRUE)]

  vars %<>% c(named) %>% unique() %>% sort()
  vars
}

jmb_analyse_chain <- function(inits, tempfile = tempfile, data, regexp, named, nadapt, niters, nthin, quick, quiet) {
  if (quiet) {
    suppressWarnings(jags_model <- rjags::jags.model(tempfile, data, inits = inits, n.adapt = nadapt, quiet = quiet))
  } else {
    jags_model <- rjags::jags.model(tempfile, data, inits = inits, n.adapt = 0, quiet = quiet)
  }

  jags_model %<>% adapt(nadapt = nadapt)

  vars <- variable_names(jags_model, data, regexp, named)

  if (!quick) {
    niters <- niters / 2
    update(jags_model, n.iter = niters, progress.bar = "none")
  }

  jags_samples <- rjags::jags.samples(model = jags_model, variable.names = vars, n.iter = niters, thin = nthin, progress.bar = "none")

  list(jags_model = jags_model, jags_samples = jags_samples)
}

jmb_analyse <- function(data, model, tempfile, quick, quiet, parallel) {

  timer <- timer::Timer$new()
  timer$start()

  nchains <- 4L
  niters <- model$niters
  nadapt <- niters / 10
  nthin <- niters * nchains / (2000 * 2)

  if (quick) {
    nchains <- 2L
    niters <- 10
    nadapt <- 0
    nthin <- 1L
  }

  obj <- list(model = model, data = data)

  data %<>% mbr::modify_data(model = model)

  inits <- inits(data, model$gen_inits, nchains = nchains)

  regexp <- model$fixed
  named <- names(model$random_effects) %>% c(model$derived)

  jags_chains <- llply(inits, .fun = jmb_analyse_chain,
                         .parallel = parallel,
                         tempfile = tempfile, data = data,
                     regexp = regexp, named = named,
                     nadapt = nadapt, niters = niters, nthin = nthin,
                     quick = quick, quiet = quiet)

  mcmcr <- lapply(jags_chains, function(x) x$jags_samples)
  mcmcr %<>% lapply(mcmcr::as.mcmcr)
  mcmcr %<>% purrr::reduce(mcmcr::bind_chains)

  obj %<>% c(inits = list(inits), jags_chains = list(jags_chains), mcmcr = list(mcmcr),
             nadapt = nadapt, ngens = niters)
  obj$duration <- timer$elapsed()
  class(obj) <- c("jmb_analysis", "mb_analysis")

  print(glance(obj))

  obj
}

#' @export
analyse.jmb_model <- function(model, data, drop = character(0),
                              parallel = getOption("mb.parallel", FALSE),
                              quick = getOption("mb.quick", FALSE),
                              quiet = getOption("mb.quiet", TRUE),
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


  if (beep) on.exit(beepr::beep())

  model %<>% drop_parameters(parameters = drop)

  tempfile <- tempfile(fileext = ".bug")
  write(template(model), file = tempfile)

  rjags::load.module("basemod", quiet = quiet)
  rjags::load.module("bugs", quiet = quiet)

  if (is.data.frame(data)) {
    return(jmb_analyse(data = data, model = model, tempfile = tempfile,
                       quick = quick, quiet = quiet, parallel = parallel))
  }

  lapply(data, jmb_analyse, model = model, tempfile = tempfile,
         quick = quick, quiet = quiet, parallel = parallel)
}
