context("drop")

test_that("model", {
  code <- mb_code(model_code_example1)
  expect_match(template(drop_parameters(code, "b")), "Type b [=] 0[.]0[;]")
  expect_match(template(drop_parameters(code, c("b", "a"))), "Type a [=] 0[.]0[;].*Type b [=] 0[.]0[;]")
  expect_error(drop_parameters(code, "ab"), "fixed scalar parameter 'ab' not found in model code")

  model <- model(code, gen_inits = gen_inits_example2,
                 select_data = list(y = 1, x = 1), scale = "x")
  expect_match(template(code(drop_parameters(model, "b"))), "Type b [=] 0[.]0[;]")
})
