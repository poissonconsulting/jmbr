#' @export
drop_parameters.jmb_code <- function(x, parameters = character(0), ...) {
  check_vector(parameters, "", min_length = 0)
  check_unique(parameters)
  

  if (!length(parameters))
    return(x)

  stop("drop is currently not implemented")

  template <- template(x)

  # template is altered

  x$template <- template
  x
}

#' @export
drop_parameters.jmb_model <- function(x, parameters = character(0), ...) {
  check_vector(parameters, "", min_length = 0)
  check_unique(parameters)
  

  if (!length(parameters))
    return(x)

  x$code %<>% drop_parameters(parameters = parameters)
  x$new_expr %<>% drop_parameters(parameters = parameters)
  x
}
