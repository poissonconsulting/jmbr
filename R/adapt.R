adapt <- function(analysis, nadapt = 10L, nattempts = 3) {

  adapted <- rjags::adapt(analysis, n.iter = nadapt, progress.bar = "none", end.adaptation = FALSE)

  attempts <- 1
  while (!adapted & attempts < nattempts) {
    nadapt %<>% magrittr::multiply_by(10L)
    attempts %<>% magrittr::add(1)
    adapted <- rjags::adapt(analysis, n.iter = nadapt, progress.bar = "none", end.adaptation = FALSE)
  }

  if (!adapted) warning("incomplete adaptation")

  rjags::adapt(analysis, n.iter = 1, progress.bar = "none", end.adaptation = TRUE)
  analysis
}
