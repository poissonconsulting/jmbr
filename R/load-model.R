#' @export
load_model.jmb_model <- function(x, quiet, ...) {
  chk_flag(quiet)

  rjags::load.module("basemod", quiet = quiet)
  rjags::load.module("bugs", quiet = quiet)

  tempfile <- tempfile(fileext = ".bug")
  write(template(x), file = tempfile)

  tempfile
}
