context("code")

test_that("analyse", {

  template <- "model{

  bIntercept ~ dlogis(0, 5^-2)
  bYear ~ dnorm(0, .5^-2) # bYear2 ~ dnorm(0, .5^-2)

  bHabitatQuality[1] <- 0
  for(i in 2:nHabitatQuality) {
    bHabitatQuality[i] ~ dnorm(0, 5.^-2) T(0,)
  }

  log_sSiteYear ~ dlnorm(0, 5^-2)
  log_sDensity ~ dt(0, 5^-2, 4.5)

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

  expect_identical(length(parameters(code)), 27L)

  expect_error(parameters(code, param_type = "primary"))
  expect_error(parameters(code, scalar_only = TRUE))

  code10 <- sd_priors_by(code, 10, distributions = c("logistic", "normal", "lognormal", "t"))
  expect_true(is.jmb_code(code10))
  expect_identical(parameters(code10), parameters(code))
  expect_identical(as.character(code10),
                   "model{\n\n  bIntercept ~ dlogis(0, (5 * 10)^-2)\n  bYear ~ dnorm(0, (.5 * 10)^-2)\n\n  bHabitatQuality[1] <- 0\n  for(i in 2:nHabitatQuality) {\n    bHabitatQuality[i] ~ dnorm(0, (5. * 10)^-2) T(0,)\n  }\n\n  log_sSiteYear ~ dlnorm(0, (5 * 10)^-2)\n  log_sDensity ~ dt(0, (5 * 10)^-2, 4.5)\n\n  log(sSiteYear) <- log_sSiteYear\n  log(sDensity) <- log_sDensity\n\n  for(i in 1:nSite) {\n    for(j in 1:nYearFactor) {\n      bSiteYear[i,j] ~ dnorm(0, sSiteYear^-2)\n    }\n  }\n\n  for(i in 1:length(Density)) {\n    eDensity[i] <- bIntercept + bYear * Year[i] + bHabitatQuality[HabitatQuality[i]] + bSiteYear[Site[i], YearFactor[i]]\n    Density[i] ~ dlnorm(eDensity[i], sDensity^-2)\n  }\n}")

  coder <- sd_priors_by(code, 10, distributions = "normal")
  expect_true(is.jmb_code(coder))
  expect_identical(parameters(coder), parameters(code))
  expect_identical(as.character(coder),
                   "model{\n\n  bIntercept ~ dlogis(0, 5^-2)\n  bYear ~ dnorm(0, (.5 * 10)^-2)\n\n  bHabitatQuality[1] <- 0\n  for(i in 2:nHabitatQuality) {\n    bHabitatQuality[i] ~ dnorm(0, (5. * 10)^-2) T(0,)\n  }\n\n  log_sSiteYear ~ dlnorm(0, 5^-2)\n  log_sDensity ~ dt(0, 5^-2, 4.5)\n\n  log(sSiteYear) <- log_sSiteYear\n  log(sDensity) <- log_sDensity\n\n  for(i in 1:nSite) {\n    for(j in 1:nYearFactor) {\n      bSiteYear[i,j] ~ dnorm(0, sSiteYear^-2)\n    }\n  }\n\n  for(i in 1:length(Density)) {\n    eDensity[i] <- bIntercept + bYear * Year[i] + bHabitatQuality[HabitatQuality[i]] + bSiteYear[Site[i], YearFactor[i]]\n    Density[i] ~ dlnorm(eDensity[i], sDensity^-2)\n  }\n}")
})
