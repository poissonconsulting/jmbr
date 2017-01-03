context("analyse")

test_that("analyse", {
  code <- mb_code(model_code_example2)

  model <- model(code, gen_inits = gen_inits_example2, random_effects = list(bYear = "Year"),
                     new_expr = "
  for(i in 1:length(x)) {
    fit2[i] <- a + b * x[i]
  }
                    fit <- a + b * x + bYear[Year]
                     residual <- y - fit
                    rsquared0 <- var(fit)  / var(y)
                    rsquared3 <- 1 - var(y - fit)  / var(y)
                    rsquared <- var(fit2)  / (var(fit2) + exp(log_sigma)^2)
                    rsquared2 <- (var(fit2) + exp(log_sYear)^2)  / (var(fit2) + exp(log_sigma)^2 + exp(log_sYear)^2)
                     prediction <- fit")

  model <- drop_parameters(model, parameters = c("a"))

  analysis <- analyse(model, data_set_example2, beep = FALSE)

  expect_true(is.tmb_analysis(analysis))

  expect_equal(data_set(analysis), data_set_example2)
  expect_equal(logLik(analysis), -3591.286, tolerance = 1e-7)
  expect_equal(sample_size(analysis), nrow(data_set_example2))
  expect_equal(nterms(analysis), 3L)
  expect_equal(AIC(analysis), 7188.596, tolerance = 1e-7)

  analyses <- analyse(model, list(x = data_set_example2, x2 = data_set_example2), beep = FALSE)
  expect_is(analyses, "list")
  expect_identical(names(analyses), c("x", "x2"))
  expect_equal(logLik(analyses[[1]]), -3591.286, tolerance = 1e-7)

  coef <- coef(analysis)
  expect_is(coef, "tbl")
  expect_identical(colnames(coef), c("term", "estimate", "std.error", "statistic", "p.value", "lower", "upper"))
  expect_identical(coef$lower, coef$estimate - coef$std.error * qnorm(0.975))
  expect_equal(coef$upper, coef$estimate + coef$std.error * qnorm(0.975))
  expect_identical(nrow(coef), 3L)

  adreport <- coef(analysis, terms = "adreport")
  expect_identical(nrow(adreport), 1000L)

  random <- coef(analysis, terms = "random")
  expect_identical(nrow(random), 10L)
  expect_identical(random$term, paste0("bYear[", 1:10, "]"))
  expect_identical(nrow(coef(analysis, terms = "random", scalar_only = TRUE)), 0L)
  expect_identical(nrow(coef(analysis, terms = "random", constant_included = FALSE)), 9L)

  expect_error(coef(analysis, terms = "report"), "terms must only include values which match the regular expressions")

  fit <- fitted(analysis)
  residuals <- residuals(analysis)
  expect_identical(names(fit), c("x", "y", "Year", "estimate"))

  expect_equal(predict(analysis, term = "rsquared3")$estimate[1], 0.5707243, tolerance = 1e-6)

  prediction <- predict(analysis)
  expect_is(prediction, "tbl")
  expect_identical(colnames(prediction), c("x", "y", "Year", "estimate"))
  expect_identical(data_set_example2, as.data.frame(prediction[c("x", "y", "Year")]))
  expect_identical(nrow(prediction), 1000L)
  expect_identical(predict(analysis, new_data = data_set(analysis)[10,])$estimate, predict(analysis, term = "fit2")$estimate[10])

  expect_identical(prediction$estimate, fit$estimate)
  expect_equal(residuals$estimate, adreport$estimate)
  expect_equal(data_set_example2$y, fit$estimate + residuals$estimate)

  prediction2 <- predict(analysis, new_data = data_set(analysis), term = "other", new_expr =
                           "prediction <- b * x + bYear[Year]
                            other <- prediction")
  expect_identical(colnames(prediction2), c("x", "y", "Year", "estimate"))
  expect_identical(prediction$estimate, prediction2$estimate)

  prediction2b <- predict(analysis, new_data = data_set(analysis), new_expr =
                           "prediction <- b * x", new_values = list(b = -1))

  expect_identical(prediction2b$x * -1, prediction2b$estimate)

  prediction3 <- predict(analysis, new_data = data_set_example2[3,], term = "other", new_expr =
                           "other <- b * x + bYear[Year]")
  expect_equal(prediction2[3,], prediction3)

  estimates <- estimates(analysis)
  expect_identical(lapply(estimates, dims), lapply(analysis$inits[names(estimates)], dims))
  expect_identical(estimates(analysis, "random", scalar_only = TRUE), list(x = 1)[-1])
  estimates <- estimates(analysis, "random")
  expect_identical(estimates$bYear, random$estimate)
  estimates <- estimates(analysis, "report")
  expect_equal(estimates$fit, fit$estimate, tolerance = 1e-5)
  estimates <- estimates(analysis, "adreport")
  expect_equal(estimates$residual, residuals$estimate)
  expect_identical(names(estimates(analysis, "primary")), sort(names(c(estimates(analysis, "fixed"), estimates(analysis, "random")))))

  expect_identical(lincomb_names(analysis),
                   c("log_sigma", "b", "log_sYear"))

  expect_identical(names(named_estimates(estimates(analysis, "random"))), paste0("bYear[", 1:10, "]"))
  expect_equal(named_estimates(estimates(analysis, "random")), estimates(analysis, "random")$bYear,
               check.attributes = FALSE)

  profile <- predict(analysis, data_set_example2[1:2,], "prediction <- exp(2 * 3 + - 7)", conf_int = TRUE)
  expect_identical(colnames(profile), c("x", "y", "Year", "estimate", "lower", "upper"))
  expect_identical(profile$lower, rep(exp(2 * 3 + - 7), 2))
  expect_identical(profile$lower, profile$upper)
  profile <- predict(analysis, data_set_example2[1:2,], "prediction <- exp(2 * 3 + - 7  + 2 * bYear[Year])", conf_int = TRUE)
  expect_identical(profile$lower, profile$estimate)
  expect_equal(profile$lower, exp(2 * 3 + -7 + 2 * estimates(analysis, "random")$bYear[as.integer(data_set_example2$Year[1:2])]))

  expect_error(predict(analysis, data_set_example2[1:2,], "prediction <- a + b * x + bYear2[Year]", conf_int = TRUE), "unrecognised parameter name")
  expect_equal(predict(analysis, data_set_example2[3,], "prediction <- fit[Year] + bYear[Year]")$estimate,
                   predict(analysis, data_set_example2[3,], "prediction <- fit[Year] + bYear[Year]", conf_int = TRUE)$estimate)
  profile <- predict(analysis, data_set_example2[1:2,], "prediction <- b * x + bYear[Year] + 1 + -1", conf_int = TRUE)
  expect_equal(profile$estimate, prediction$estimate[1:2])
  expect_equal(profile$lower[2], 55.3838, tolerance = 1e-6)
  expect_equal(profile$estimate[2], 56.75728, tolerance = 1e-6)
  expect_equal(profile$upper[2], 58.13152, tolerance = 1e-6)
})

context("random matrix")

test_that("example3", {
  model <- model(mb_code(model_code_example3), gen_inits = gen_inits_example3,
                     random_effects = random_effects_example3, center = "Slope",
                     new_expr = new_expr_example3, select_data = select_data_example3)

  analyses <- backwards(model, data_set_example3, drops = list(c("bIntercept", "bSlope")), beep = FALSE)
  expect_identical(names(analyses), c("full", "base+bIntercept"))

  analysis <- analyses[[2]]

  expect_identical(colnames(coef(analysis)), c("term", "estimate", "std.error", "statistic", "p.value", "lower", "upper"))

  expect_identical(names(estimates(analysis)), c("bIntercept", "log_sSite", "log_sSiteYear", "log_sYear"))
  expect_identical(dims(estimates(analysis, "random")$bSiteYear), c(6L,7L))

  prediction <- predict(analysis, new_data = data_set_example3[11,], conf_int = TRUE)
  expect_equal(prediction$upper, 8.395107, tolerance = 1e-7)
  expect_identical(predict(analysis, data_set_example3[2,]), predict_data(data_set_example3[2,], analysis))
  prediction2 <- predict(analysis, new_data = data_set_example3[11,], conf_int = TRUE, quick = TRUE)
  expect_identical(colnames(prediction), colnames(prediction2))
  expect_equal(prediction$estimate, prediction2$estimate)

  prediction3 <- predict(analysis, new_expr = "
for(i in 1:length(Year)) {
prediction[i] <- exp(bIntercept + bYear[Year[i]] + bSite[Site[i]] + bSiteYear[Site[i],Year[i]])
}")
  expect_identical(nrow(prediction3), 1344L)
  expect_equal(prediction3$estimate[11], prediction2$estimate)

  prediction4 <- predict(analysis, new_data = data_set_example3[11,] ,new_expr = "prediction <- bIntercept * Year * Year", conf_int = TRUE)
  expect_equal(prediction4$upper, 39.30119, tolerance = 1e-6)
  prediction5 <- predict(analysis, new_data = data_set_example3[10:11,] ,new_expr = "prediction <- exp(bIntercept * Year * Year)", conf_int = TRUE)
  prediction5b <- predict(analysis, new_data = data_set_example3[10:11,], new_expr = "
prediction <- exp(bIntercept * Year + bYear[Year]) ", conf_int = TRUE)
  prediction6 <- predict(analysis, new_data = data_set_example3[10:11,] ,new_expr = "prediction <-  exp(bIntercept + bYear[Year])", conf_int = TRUE)
})
