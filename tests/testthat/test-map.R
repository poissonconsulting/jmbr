context("map")

test_that("map", {
  expect_identical(map(list()), list())
  expect_identical(map(list(x = c(1,2))), list())
  expect_identical(map(list(x = c(1,2,NA))), list(x = factor(c(1,2,NA))))
  expect_identical(map(list(y = 1:4, x = c(1,2,NA))), list(x = factor(c(1,2,NA))))
  expect_identical(map(list(y = 1:4, x = matrix(c(1,2,NA,4), nrow = 2))), list(x = factor(c(1,2,NA,4))))
})

test_that("remap_vector", {
  expect_identical(remap_vector(c(1,3), factor(c(1,NA,3))), c(1,0,3))
  expect_identical(remap_vector(c(1,3), factor(c(1,NA,3,NA))), c(1,0,3,0))
  expect_error(remap_vector(c(1,3), factor(c(1,NA))))
  expect_identical(remap_vector(c(1,3), factor(c(1,4))), c(1,3))
  expect_error(remap_vector(c(1,3), factor(c(1,4,5))))
})

test_that("remap", {
  expect_identical(remap_estimates(estimates = list(x = c(1,3)), map = list()), list(x = c(1,3)))
  expect_identical(remap_estimates(estimates = list(x = c(1,3)), map = list(x = factor(c(1,NA,3)))), list(x = c(1,0,3)))
})

