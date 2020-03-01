#' @export
sd_priors_by.jmb_code <- function(
  x, by = 10, distributions = c("normal", "lognormal", "t"), ...) {
  chk_number(by)
  chk_range(by, c(0.001, 1000))
  chk_unused(...)

  chk_s3_class(distributions, "character")
  chk_unique(distributions)
  chk_subset(distributions,  c("laplace", "logistic", "lognormal",
                                "normal", "t", "nt"))

  if(!length(distributions)) {
    wrn("No prior distributions included.")
    return(x)
  }

  x <- rm_comments(x)

  pattern2 <- "\\s*[(][^,)]+,\\s*)((\\d+[.]{0,1}\\d*)|(\\d*[.]{0,1}\\d+))(\\s*\\^\\s*-\\s*2\\s*)([)])"
  pattern3 <- "\\s*[(][^,)]+,\\s*)((\\d+[.]{0,1}\\d*)|(\\d*[.]{0,1}\\d+))(\\s*\\^\\s*-\\s*2\\s*)(,[^,)]+[)])"
  replacement <- paste0("\\1(\\2 * ", by, ")^-2\\6")
  if("laplace" %in% distributions)
      x <- gsub(paste0("(~\\s*ddexp", pattern2), replacement, x)
  if("logistic" %in% distributions)
      x <- gsub(paste0("(~\\s*dlogis", pattern2), replacement, x)
  if("lognormal" %in% distributions)
      x <- gsub(paste0("(~\\s*dlnorm", pattern2), replacement, x)
  if("normal" %in% distributions)
      x <- gsub(paste0("(~\\s*dnorm", pattern2), replacement, x)
  if("t" %in% distributions)
      x <- gsub(paste0("(~\\s*dt", pattern3), replacement, x)
  if("nt" %in% distributions)
      x <- gsub(paste0("(~\\s*dnt", pattern3), replacement, x)

  mb_code(x)
}
