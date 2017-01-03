check_unused <- function(...) {
  dots <- pryr::named_dots(...)
  if (length(dots)) error("dots are not unused")
  invisible(NULL)
}

check_x_in_y <- function(x, y, x_name = substitute(x), y_name = substitute(y), type_x = "values", type_y = "values") {
  if (is.name(x_name)) x_name %<>% deparse()
  if (is.name(y_name)) y_name %<>% deparse()

  if (is.null(y)) return(x)
  if (!length(x)) return(x)

  if (!all(x %in% y))
    error(type_x, " in ", x_name, " must also be in ", type_y, " of ", y_name)
  x
}

check_x_not_in_y <- function(x, y, x_name = substitute(x), y_name = substitute(y), type_x = "values", type_y = "values") {
  if (is.name(x_name)) x_name %<>% deparse()
  if (is.name(y_name)) y_name %<>% deparse()

  if (is.null(y)) return(x)
  if (!length(x)) return(x)

  if (any(x %in% y))
    error(type_x, " in ", x_name, " must not be in ", type_y, " of ", y_name)
  x
}

check_single_arg_fun <- function(fun) {
  fun_name <- deparse(substitute(fun))

  if (!is.function(fun)) error(fun_name, " must be a function")
  if (length(formals(args(fun))) != 1)  error(fun_name, " must take a single argument")
  fun
}

check_unique_character_vector <- function(x, x_name = substitute(x)) {
  check_vector(x, "", min_length = 0, vector_name = x_name)
  check_unique(x, x_name = x_name)
  x
}

check_uniquely_named_character_vector <- function(x, x_name = substitute(x)) {
  if (is.name(x)) x_name %<>% deparse()

  if (!is.character(x)) error(x_name, " must be a character vector")

  if (!length(x))
    return(x)

  if (is.null(names(x))) error(x_name, "must be named")
  check_unique(names(x), x_name = x_name)
  x
}

check_uniquely_named_list <- function(x, x_name = substitute(x)) {
  if (is.name(x)) x_name %<>% deparse()

  if (!is_nlist(x))
    error(x_name, " must be a named list")
  check_unique(names(x), x_name = x_name)
  x
}

check_all_elements_class_character <- function(x, x_name = substitute(x)) {
  if (is.name(x)) x_name %<>% deparse()

  if (!length(x)) return(x)

  if (!all(unlist(lapply(x, class)) == "character"))
    error("elements of ", x_name, "must be character vectors")
  x
}
