context("analyse")

test_that("analyse", {

  template <- "model{

  bIntercept ~ dnorm(0, 5^-2)
  bYear ~ dnorm(0, 5^-2)

  bHabitatQuality[1] <- 0
  for(i in 2:nHabitatQuality) {
    bHabitatQuality[i] ~ dnorm(0, 5^-2)
  }

  log_sSiteYear ~ dnorm(0, 5^-2)
  log_sDensity ~ dnorm(0, 5^-2)

  log(sSiteYear) <- log_sSiteYear
  log(sDensity) <- log_sDensity

  for(i in 1:nSite) {
    for(j in 1:nYearFactor) {
      bSiteYear[i,j] ~ dnorm(0, sSiteYear^-2)
    }
  }

  for(i in 1:length(Density)) {
    eDensity[i] <- bIntercept + bYear * Year[i] + bHabitatQuality[HabitatQuality[i]] + bSiteYear[Site[i], YearFactor[i]]
    Density[i] ~ dlnorm(eDensity[i], sDensity^-2)
  }
}"

  code <- mb_code(template)

  expect_identical(class(code), c("jmb_code", "mb_code"))
  expect_true(is.jmb_code(code))

  expect_identical(length(parameters(code)), 30L)

  expect_error(parameters(code, param_type = "primary"))
  expect_error(parameters(code, scalar_only = TRUE))
})
