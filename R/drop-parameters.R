#' @export
drop_parameters.jmb_code <- function(x, parameters = character(0), ...) {
  check_vector(parameters, "", min_length = 0)
  check_unique(parameters)


  if (!length(parameters))
    return(x)

  stop("drop is currently not implemented")

  template <- template(x)

  # template needs to be altered ...

  x$template <- template
  x
}
