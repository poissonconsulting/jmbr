context("analyse")

test_that("analyse", {

  require(newdata)

  data <- density99
  data$Year <- factor(data$Year)

  jags_template <- "model{

  bIntercept ~ dnorm(0, 5^-2)
  bYear ~ dnorm(0, 5^-2)

  bSite[1] <- 0
  for(i in 2:nSite) {
    bSite[i] ~ dnorm(0, 5^-2)
  }

  log_sSiteYear ~ dnorm(0, 5^-2)
  log_sDensity ~ dnorm(0, 5^-2)

  log(sSiteYear) <- log_sSiteYear
  log(sDensity) <- log_sDensity

  for(i in 1:nSite) {
    for(j in 1:nYear) {
      bSiteYear[i,j] ~ dnorm(0, sSiteYear^-2)
    }
  }

  for(i in 1:length(Density)) {
    eDensity[i] <- bIntercept + bYear * Year[i] + bSite[Site[i]] + bSiteYear[Site[i], Year[i]]
    Density[i] ~ dlnorm(eDensity[i], sDensity^-2)
  }
}"

  new_expr <- "
  for(i in 1:length(Density)) {
    prediction[i] <- bIntercept + bYear * Year[i] + bSite[Site[i]] + bSiteYear[Site[i], Year[i]]
} "

  model <- model(jags_template, monitor = "^(b|log_s)",
                 random_effects = list(bSiteYear = c("Site", "Year")),
                 new_expr = new_expr)

  analysis <- analyse(model, data = data, beep = FALSE)

  analysis <- reanalyse(analysis, beep = FALSE)

  expect_identical(niters(analysis), 500L)
  expect_identical(nchains(analysis), 4L)
  expect_identical(nsamples(analysis), 2000L)

  expect_equal(convergence(analysis), 1.00, tolerance = 1)

  expect_is(as.mcmcr(analysis), "mcmcr")

  coef <- coef(analysis)

  expect_is(coef, "tbl")
  expect_identical(colnames(coef), c("term", "estimate", "std.error", "statistic",
                                     "p.value", "lower", "upper"))

  expect_identical(coef$term, c("bIntercept", "bSite[1]", "bSite[2]", "bSite[3]",
                                "bSite[4]", "bSite[5]", "bSite[6]", "bYear",
                                "log_sDensity", "log_sSiteYear"))

  predict <- predict(analysis, new_data = new_data(data, "Site"))


  expect_is(predict, "tbl")
  expect_identical(colnames(predict), c("Density", "Site", "Year", "Visit",
                                     "estimate", "lower", "upper"))
  expect_identical(nrow(predict), 6L)
})

