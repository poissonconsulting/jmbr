context("model")

test_that("model data", {
  code <- mb_code(model_code_example2)
  model <- model(code, gen_inits = gen_inits_example2,
                     scale = "z")
  expect_error(analyse_data(data_set_example2, model, beep = FALSE), "column names in data must include 'z'")
})

test_that("model modify data", {
  code <- mb_code(model_code_example2)
  model <- model(code, gen_inits = gen_inits_example2, modify_data = function(x) stop("Houston..."))
  expect_error(analyse_data(data_set_example2, model, beep = FALSE), "Houston...")
})

test_that("make_all_models", {
  code <- mb_code(model_code_example2)
  model <- model(code, gen_inits = gen_inits_example2)
  models <- make_all_models(model, drop = list("a"))
  expect_is(models, "list")
  expect_length(models, 2L)
  expect_identical(names(models), c("full", "base"))
  expect_identical(models[[1]], model)
  expect_identical(names(models), c("full", "base"))
  expect_identical(names(make_all_models(model, drop = list(c("a", "b")))), c("full", "base+a", "base"))
  expect_identical(names(make_all_models(model, drop = list("b", "a"))), c("full", "base+b", "base+a", "base"))
})

test_that("tmb_analysis error", {
  code <- mb_code(model_code_example2)
  model <- model(code, gen_inits = gen_inits_example2,
                     select_data = list(x = 1, y = 1, z = 1))

  expect_error(analyse_data(data_set_example2, model, beep = FALSE), "data must have column 'z'")

  model <- model(code, gen_inits = gen_inits_example2,
                     select_data = list(x = 1, y = TRUE))

  expect_error(analyse_data(data_set_example2, model, beep = FALSE), "column y in data must be of class 'logical'")

  model <- model(code, gen_inits =
                       function(data) list(a = 0, b = 0, log_sigma = 0, bYear = rep(0, 10), log_sYear = 0, bYear = c(0,0,0)), random_effects = list(bYear = "Year"),
                     select_data = list(x = 1, y = 1, Year = factor(1)))

  expect_error(analyse_data(data_set_example2, model, beep = FALSE), "dimensions of user-provided random inits must match those of random effects")

  expect_error(analyse_data(data_set_example2, model, not_an_arg = FALSE), "dots are not unused")
})

