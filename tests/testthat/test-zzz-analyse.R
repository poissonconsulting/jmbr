context("analyse")

test_that("analyse", {
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

  model <- model(jags_template,
                 select_data = list("Year+" = numeric(), YearFactor = factor(),
                                    Site = factor(), Density = numeric(),
                                    HabitatQuality = factor()),
                 fixed = "^(b|l)", derived = "eDensity",
                 random_effects = list(bSiteYear = c("Site", "YearFactor")),
                 new_expr = new_expr)

  analysis <- analyse(model, data = data, beep = FALSE, glance = FALSE)
  analysis <- jmb_reanalyse_internal(analysis, parallel = FALSE, quiet = TRUE)

  expect_identical(parameters(analysis), sort(c("bHabitatQuality", "bIntercept", "bYear", "log_sDensity", "log_sSiteYear")))
  expect_identical(parameters(analysis, "random"), "bSiteYear")
  expect_identical(parameters(analysis, "derived"), "eDensity")
  expect_identical(parameters(analysis, "primary"),
                   c("bHabitatQuality", "bIntercept", "bSiteYear", "bYear", "log_sDensity", "log_sSiteYear"))
  expect_identical(parameters(analysis, "all"),
                   c("bHabitatQuality", "bIntercept", "bSiteYear", "bYear", "eDensity", "log_sDensity", "log_sSiteYear"))

  expect_identical(ngens(analysis), 2000L)
  expect_identical(nsims(analysis), 8000L)

  expect_identical(niters(analysis), 500L)
  expect_identical(nchains(analysis), 4L)
  expect_identical(nsamples(analysis), 2000L)

  expect_is(as.mcmcr(analysis), "mcmcr")

  glance <- glance(analysis)
  expect_is(glance, "tbl")
  expect_identical(colnames(glance), c("n", "K", "nsamples", "nchains", "nsims", "duration", "rhat", "converged"))
  expect_is(glance$duration, "Duration")
  expect_identical(glance$n, 300L)
  expect_identical(glance$K, 5L)

  derived <- coef(analysis, param_type = "derived")
  expect_identical(colnames(derived), c("term", "estimate", "sd", "zscore", "lower", "upper", "pvalue"))
  expect_identical(nrow(derived), 300L)

  coef <- coef(analysis)

  expect_is(coef, "tbl")
  expect_identical(colnames(coef), c("term", "estimate", "sd", "zscore", "lower", "upper", "pvalue"))

  expect_identical(coef$term, as.term(c("bHabitatQuality[1]", "bHabitatQuality[2]",
                                "bIntercept", "bYear",
                                "log_sDensity", "log_sSiteYear")))

  expect_identical(nrow(coef(analysis, "primary")), 66L)
  expect_identical(nrow(coef(analysis, "all")), 366L)

  tidy <- tidy(analysis)
  expect_identical(colnames(tidy), c("term", "estimate", "std.error", "statistic", "p.value"))
  expect_identical(tidy$estimate, coef$estimate)

  year <- predict(analysis, new_data = "Year", quick = TRUE)

  expect_is(year, "tbl")
  expect_identical(colnames(year), c("Site", "HabitatQuality", "Year", "Visit",
                                        "Density", "YearFactor",
                                     "estimate", "sd", "zscore", "lower", "upper", "pvalue"))
  expect_true(all(year$lower < year$estimate))
  expect_false(is.unsorted(year$estimate))
})
