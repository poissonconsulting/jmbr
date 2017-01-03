context("parameters")

test_that("parameters", {
  expect_identical(parameters(mb_code(model_code_example1)), sort(c("a", "b", "log_sigma")))
  expect_identical(parameters(mb_code(model_code_example2)), sort(c("a", "b", "bYear", "log_sigma", "log_sYear")))
  expect_identical(parameters(mb_code(model_code_example2), "report"), "fit")
  expect_identical(parameters(mb_code(model_code_example2), "adreport"), "residual")
  expect_identical(parameters(mb_code(model_code_example2), c("adreport", "report")), sort(c("fit", "residual")))
  expect_identical(parameters(mb_code(model_code_example2), "all"), sort(c("a", "b", "bYear", "fit", "log_sigma", "log_sYear", "residual")))
  expect_identical(parameters(mb_code(model_code_example3)), sort(c("bIntercept", "bSite", "bSiteYear",     "bSlope", "bYear", "log_sSite", "log_sSiteYear", "log_sYear")))
  expect_identical(parameters(mb_code(model_code_example3), scalar_only = TRUE), sort(c("bIntercept", "bSlope", "log_sSite", "log_sSiteYear", "log_sYear")))
  expect_error(parameters(mb_code(model_code_example3), "REPORT", scalar_only = TRUE), "terms must only include values which match the regular expressions 'adreport', 'primary' or 'report'")
  expect_error(parameters(mb_code(model_code_example3), "report", scalar_only = TRUE), "the dimensionality of report parameters is not identifiable")
})
