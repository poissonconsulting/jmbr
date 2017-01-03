check_dims_inits <- function(x, y) {
  x %<>% lapply(dims)
  y %<>% lapply(dims)
  x <- x[names(x) %in% names(y)]
  y <- y[names(x)]
  if (!identical(x, y))
    error("dimensions of user-provided random inits must match those of random effects")
  x
}

inits <- function(data, gen_inits, random_effects) {
  inits <- gen_inits(data)
  if (length(random_effects)) {
    random_inits <- random_inits(data, random_effects)
    check_dims_inits(inits, random_inits)
    random_inits <- random_inits[!names(random_inits) %in% names(inits)]
    inits %<>% c(random_inits)
  }
  inits %<>% sort_nlist()
  inits
}

random_inits <- function(data, random_effects) {
  if (!length(random_effects)) return(NULL)

  if (!all(unlist(random_effects) %in% names(data)))
    error("elements in random_effects must in data")

  data <- data[vapply(data, is.factor, TRUE)]

  if (!all(unlist(random_effects) %in% names(data)))
    error("elements in random_effects must be factors in data")

  data %<>% vapply(nlevels, 1L) %>% unlist()

  random_effects %<>% lapply(replace_n, data)
  random_effects %<>% lapply(zeros)
  random_effects
}

replace_n <- function(random_effect, data) {
  stopifnot(is.character(random_effect))
  stopifnot(is.integer(data))
  stopifnot(all(random_effect %in% names(data)))
  return(data[random_effect])
}

