context("analyse")

test_that("analyse", {
  set_analysis_mode("check")

  data <- density99
  data$YearFactor <- factor(data$Year)

  jags_template <- "model{

  bIntercept ~ dnorm(0, 5^-2)
  bYear ~ dnorm(0, .5^-2) # bYear2 ~ dnorm(0, .5^-2)

  bHabitatQuality[1] <- 0
  for(i in 2:nHabitatQuality) {
    bHabitatQuality[i] ~ dnorm(0, 5.^-2) T(0,)
  }

  log_sSiteYear ~ dlnorm(0, 5^-2)
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

  analysis <- analyse(model, data = data)

  expect_equal(data_set(analysis), data)
  data2 <- data_set(analysis, marginalize_random_effects = TRUE)
  expect_true(all(as.integer(data2$Site) == 1L))
  expect_true(all(as.integer(data2$YearFactor) == 1L))
  # need random seed so repeatable
  R2c <- R2(analysis, "Density")
  expect_gt(R2c, 0.6)
  expect_lt(R2c, 0.8)

  R2m <- R2(analysis, "Density", marginal = TRUE)
  expect_gt(R2m, 0.0)
  expect_lt(R2m, 0.01)

  expect_identical(class(analysis), c("jmb_analysis", "mb_analysis"))
  expect_true(is.jmb_analysis(analysis))

  expect_identical(niters(analysis), 500L)
  expect_identical(nchains(analysis), 2L)
  expect_identical(nsims(analysis), 1000L)
  expect_identical(ngens(analysis), 2000L)

  analysis <- reanalyse(analysis)

  expect_identical(niters(analysis), 500L)
  expect_identical(ngens(analysis), 4000L)


  expect_identical(parameters(analysis, "fixed"), sort(c("bHabitatQuality", "bIntercept", "bYear", "log_sDensity", "log_sSiteYear")))
  expect_identical(parameters(analysis, "random"), "bSiteYear")
  expect_identical(parameters(analysis, "derived"), "eDensity")
  expect_identical(parameters(analysis, "primary"),
                   c("bHabitatQuality", "bIntercept", "bSiteYear", "bYear", "log_sDensity", "log_sSiteYear"))
  expect_identical(parameters(analysis),
                   c("bHabitatQuality", "bIntercept", "bSiteYear", "bYear", "eDensity", "log_sDensity", "log_sSiteYear"))

  expect_is(as.mcmcr(analysis), "mcmcr")

  glance <- glance(analysis)
  expect_is(glance, "tbl")
  expect_identical(colnames(glance), c("n", "K", "nchains", "niters", "nthin", "ess", "rhat", "converged"))
  expect_identical(glance$n, 300L)
  expect_identical(glance$nthin, 2L)
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
  expect_identical(colnames(tidy), c("term", "estimate", "lower", "upper", "esr", "rhat"))

  year <- predict(analysis, new_data = "Year")

  expect_is(year, "tbl")
  expect_identical(colnames(year), c("Site", "HabitatQuality", "Year", "Visit",
                                        "Density", "YearFactor",
                                     "estimate", "sd", "zscore", "lower", "upper", "pvalue"))
  expect_true(all(year$lower < year$estimate))
  expect_false(is.unsorted(year$estimate))

  dd <- mcmc_derive_data(analysis, new_data = c("Site", "Year"), ref_data = TRUE)
  expect_true(is.mcmc_data(dd))
})
