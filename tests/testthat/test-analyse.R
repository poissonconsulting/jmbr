context("analyse")

test_that("analyse", {

  require(newdata)

  data <- density99
  data$YearFactor <- factor(data$Year)

  jags_template <- "model{

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

  new_expr <- "
  for(i in 1:length(Density)) {
    prediction[i] <- exp(bIntercept + bYear * Year[i] + bHabitatQuality[HabitatQuality[i]] + bSiteYear[Site[i], YearFactor[i]])
} "

  model <- model(jags_template, monitor = "^(b|log_s)",
                 center = "Year",
                 random_effects = list(bSiteYear = c("Site", "YearFactor")),
                 new_expr = new_expr)

  analysis <- analyse(model, data = data, niters = 10^3, beep = FALSE)

  analysis <- reanalyse(analysis, beep = FALSE)

  expect_identical(parameters(analysis), sort(c("bHabitatQuality", "bIntercept", "bYear", "log_sDensity", "log_sSiteYear")))
  expect_identical(parameters(analysis, fixed = FALSE), "bSiteYear")

  expect_identical(ngens(analysis), 2000L)
  expect_identical(nsims(analysis), 8000L)

  expect_identical(niters(analysis), 500L)
  expect_identical(nchains(analysis), 4L)
  expect_identical(nsamples(analysis), 2000L)

  expect_is(is_converged(analysis), "logical")

  expect_is(as.mcmcr(analysis), "mcmcr")

  coef <- coef(analysis)

  expect_is(coef, "tbl")
  expect_identical(colnames(coef), c("term", "estimate", "std.error", "statistic",
                                     "p.value", "lower", "upper"))

  expect_identical(coef$term, c("bHabitatQuality[1]", "bHabitatQuality[2]",
                                "bIntercept", "bYear",
                                "log_sDensity", "log_sSiteYear"))

  predict <- predict(analysis, new_data = new_data(data, "Site"))

  expect_is(predict, "tbl")
  expect_identical(colnames(predict), c("Site", "HabitatQuality", "Year", "Visit",
                                        "Density", "YearFactor",
                                     "estimate", "lower", "upper"))
  expect_identical(nrow(predict), 6L)
})
