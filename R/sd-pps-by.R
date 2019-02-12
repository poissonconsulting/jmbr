#' @export
sd_pps_by.jmb_code <- function(x, by = 2, ...) {
  check_scalar(by, c(0.1, 10))
  check_unused(...)

  x %<>% str_replace_all(
    "(~\\s*dl{0,1}norm\\s*[(][^,]+,\\s*)(\\d+[.]{0,1}\\d*)(\\s*\\^\\s*-\\s*2\\s*)([)])",
    str_c("\\1(\\2 * ", by, ")^-2\\4"))

  mb_code(x)
}
