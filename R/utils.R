all1 <- function(x) all(x == 1)

allin <- function(x, y) all(x %in% y)

any_blank <- function(x) {
  return(any(x == ""))
}

by_dims <- function(x, dims) {
  stopifnot(is.vector(x))
  stopifnot(is.integer(dims))
  stopifnot(length(x) == prod(dims))
  if (length(dims) == 1) return(x)
  if (length(dims) == 2) return(matrix(x, nrow = dims[1], ncol = dims[2]))
  return(array(x, dim = dims))
}

is_dims <- function(x) {
  is.integer(x) && length(dims) && all(x >= 1)
}

seq_to <- function(to) {
  seq(from = 1, to = to)
}

paste_rows <- function (x) {
  x %<>% unlist()
  x %<>% stringr::str_c(collapse = ",")
  data.frame(x = x)
}

dims_to_dimensions_vector <- function(dims) {
  if(identical(dims, 1L)) return("")
  dims %<>% lapply(seq_to)
  dims %<>% expand.grid()
  dims %<>% plyr::adply(1, paste_rows)
  dims <- dims$x
  dims %<>% stringr::str_c("[", ., "]")
  dims
}

is_named <- function(x) {
  !is.null(names(x))
}

list_by_name <- function(x) {
  list <- list()
  names <- unique(names(x))
  for (name in names) {
    list %<>% c(list(unname(x[names(x) == name])))
  }
  names(list) <- names
  list
}
