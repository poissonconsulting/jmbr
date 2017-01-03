zeros <- function(dims) {
  stopifnot(is_dims(dims))
  if (length(dims) == 1)
    return(numeric(dims))
  if (length(dims) == 2)
    return(matrix(0, nrow = dims[1], ncol = dims[2]))
  array(0, dims)
}

dims_zeros <- function(x) zeros(dims(x))

zero_random_effects <- function(estimates, data, random_effects) {
  stopifnot(all(names(random_effects) %in% names(estimates)))
  stopifnot(all(unlist(random_effects) %in% names(data)))

  data %<>% lapply(as.numeric)
  data <- data[unique(unlist(random_effects))]
  data <- data[vapply(data, all1, TRUE)]
  data <- names(data)
  random_effects %<>% vapply(allin, TRUE, data)
  random_effects <- random_effects[random_effects]
  random_effects %<>% names()

  if (!length(random_effects))
    return(estimates)
  estimates %<>% purrr::map_at(random_effects, dims_zeros)
  estimates
}
