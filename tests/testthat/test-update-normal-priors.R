context("update_normal_priors")

test_that("update_normal_priors", {

  code <- mb_code("model{

    bIntercept ~ dnorm(2, 5^-2)
    bYear ~ dnorm(0, 1^-2)

    bHabitatQuality[1] <- 0
    for(i in 2:nHabitatQuality) {
      bHabitatQuality[i] ~ dnorm(0, 10)
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
  }")

  code2 <- mb_code("model{

    bIntercept ~ dnorm(2, 10^-2)
    bYear ~ dnorm(0, 2^-2)

    bHabitatQuality[1] <- 0
    for(i in 2:nHabitatQuality) {
      bHabitatQuality[i] ~ dnorm(0, 20)
    }

    log_sSiteYear ~ dnorm(0, 10^-2)
    log_sDensity ~ dnorm(0, 10^-2)

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
  }")

  expect_identical(update_normal_priors(code), code2)
})
