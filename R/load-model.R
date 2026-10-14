#' @export
load_model.jmb_model <- function(x, quiet, ...) {
  chk_flag(quiet)

  # rjags partially matches arguments such as seq(along = )
  old_options <- options(warnPartialMatchArgs = FALSE)
  on.exit(options(old_options), add = TRUE)

  rjags::load.module("basemod", quiet = quiet)
  rjags::load.module("bugs", quiet = quiet)

  tempfile <- tempfile(fileext = ".bug")
  write(template(x), file = tempfile)

  tempfile
}
