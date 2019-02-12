#' @export
multiply_sd_normal_priors.jmb_code <- function(x, multiplier = 2, ...) {
  check_scalar(multiplier, c(0.1, 10))
  check_unused(...)

  x %<>% str_replace_all(
    "(~\\s*dnorm\\s*[(][^,]*,\\s+)([^^]*)([^-]\\s*-\\s*2)(\\s*[)])",
    str_c("\\1(\\2 * ", multiplier, ")^-2\\4"))

  mb_code(x)
}
