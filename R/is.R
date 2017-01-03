#' Is JAGS Code
#'
#' Tests whether x is an object of class 'jmb_code'
#'
#' @param x The object to test.
#'
#' @return A flag indicating whether the test was positive.
#' @export
is.jmb_code <- function(x) {
  inherits(x, "jmb_code")
}

#' Is a JAGS Model
#'
#' Tests whether x is an object of class 'jmb_model'
#'
#' @param x The object to test.
#'
#' @return A flag indicating whether the test was positive.
#' @export
is.jmb_model <- function(x) {
  inherits(x, "jmb_model")
}

#' Is a JAGS Analysis
#'
#' Tests whether x is an object of class 'jmb_analysis'
#'
#' @param x The object to test.
#'
#' @return A flag indicating whether the test was positive.
#' @export
is.jmb_analysis <- function(x) {
  inherits(x, "jmb_analysis")
}
