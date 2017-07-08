#' @export
update_normal_priors.jmb_code <- function(object, multiplier = 2, ...) {
  check_number(multiplier)
  if (multiplier <= 0) error("multiplier must be greater than 0")

  template <- template(object)

  pattern <- "(~\\s*dnorm\\s*\\(\\d+\\s*,\\s*)(\\d+)(\\^-2){0,1}(\\)\\s*)"

  if (stringr::str_detect(template, pattern)) {

    numbers <- stringr::str_extract_all(template, pattern) %>%
      unlist() %>%
      stringr::str_replace_all(pattern, " \\2") %>%
      stringr::str_split(pattern = " ") %>%
      unlist() %>%
      purrr::keep(function(x) nchar(x) > 0) %>%
      as.numeric() %>%
      magrittr::multiply_by(multiplier)

    stopifnot(!stringr::str_detect(template, "[.]{2,2}number[.]{2,2}"))
    template %<>% stringr::str_replace_all(pattern, "\\1..number..\\3\\4")

    for (i in seq_along(numbers)) {
      match <- stringr::str_locate(template, "[.]{2,2}number[.]{2,2}")
      stringr::str_sub(template, match[1,1], match[1,2]) <- numbers[i]
    }
  }
  mb_code(template)
}
