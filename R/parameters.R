#' @export
parameters.tmb_code <- function(x, terms = "primary", scalar_only = FALSE, ...) {
  possible <- c("primary", "report", "adreport")
  if (identical(terms, "all")) terms <- possible
  terms %<>% unique()

  if (length(terms) > 1) {
    terms %<>% lapply(function(term) {parameters(x, term, scalar_only)})
    terms %<>% unlist() %>% sort()
    return(terms)
  }

  check_scalar(terms, possible)
  check_flag(scalar_only)
  check_unused(...)

  if (terms %in% c("report", "adreport") && scalar_only)
    error("the dimensionality of ", terms, " parameters is not identifiable")

  x %<>% template() %>% str_replace_all(" ", "")

  if (terms %in% c("report", "adreport")) {
    terms %<>% toupper()
      x %<>% str_extract_all(str_c("\\s", terms, "[(]\\w+[)]"), simplify = TRUE)
  } else if (scalar_only) {
    x %<>% str_extract_all("\\sPARAMETER[(]\\w+[)]", simplify = TRUE)
  } else {
    x %<>% str_extract_all("\\sPARAMETER(|_VECTOR|_MATRIX|_ARRAY)[(]\\w+[)]", simplify = TRUE)
  }
  x %<>% as.vector() %>% str_replace_all("\\s\\w+[(](\\w+)[)]", "\\1") %>%
    sort()
  x
}
