context("utils")

test_that("by_dims", {
  expect_identical(by_dims(1, 1L), 1)
  expect_error(by_dims(1:2, 1L))
  expect_identical(by_dims(1:2, 2L), 1:2)
  expect_error(by_dims(1:2, c(1L,1L)))
  expect_identical(by_dims(1:2, c(2L,1L)), matrix(1:2,nrow = 2))
  expect_identical(by_dims(1:2, c(1L,2L)), matrix(1:2,nrow = 1))
})

test_that("dims_to_names", {
  expect_identical(dims_to_dimensions_vector(c(1L)), "")
  expect_identical(dims_to_dimensions_vector(c(3L)), c("[1]", "[2]", "[3]"))
  expect_identical(dims_to_dimensions_vector(c(2L, 1L)), c("[1,1]", "[2,1]"))
  expect_identical(dims_to_dimensions_vector(c(1L, 1L, 3L)), c("[1,1,1]", "[1,1,2]", "[1,1,3]"))
})

test_that("get_name_weight", {
  expect_identical(get_name_weight(c("b", "2.05")), c(b = 2.05))
  expect_identical(get_name_weight("b"), c(b = 1))
  expect_identical(get_name_weight("2"), c(all = 2))
  expect_identical(get_name_weight(c("2", "3")), c(all = 6))
  expect_identical(get_name_weight(c("2", "3", "bee")), c(bee = 6))
  expect_error(get_name_weight(c("b", "3", "bee")), "new_expr must be linear")
})

test_that("replace_names_with_values", {
  expect_identical(replace_names_with_values("Year", list(Year = 1)), "1")
  expect_identical(replace_names_with_values("Year2", list(Year = 1)), "Year2")
  expect_identical(replace_names_with_values("Year[Year]", list(Year = 1)), "1[1]")
  expect_identical(replace_names_with_values("Year[Year,Year2]", list(Year = 1,Year2 = 2)), "1[1,2]")
  expect_identical(replace_names_with_values("bYear[1]", list(`bYear[1]` = 3)), "3")
})

test_that("parse_string", {
  expect_identical(parse_string("bYear * Year"), list(c("bYear", "Year")))
  expect_identical(parse_string("1 + - 7"), list("1", "-7"))
  expect_identical(parse_string(" bYear*Year "), list(c("bYear", "Year")))
  expect_identical(parse_string(" bYear*Year+Year "), list(c("bYear", "Year"), "Year"))
  expect_identical(parse_string(" bYear*Year+ "), list(c("bYear", "Year"), ""))
  expect_identical(parse_string(" bYear[1,2]*2+3*bThing[x,x]*        zz+*"), list(c("bYear[1,2]", "2"), c("3","bThing[x,x]", "zz"), c("", "")))
})

test_that("select_expr", {
  expect_error(select_expr("prediction <- bYear * Year", term = "prediction2"),
               "term 'prediction2' is not defined in new_expr")
  expect_error(select_expr("prediction <- bYear * Year
                      prediction <- bYear", term = "prediction"),
               "term 'prediction' is defined more than once in new_expr")
  expect_error(select_expr("exp(a <- b * b)", term = "a"),
               "term 'a' is not defined in new_expr")
  expect_identical(select_expr("b <- a * a", term = "b"), c(identity = "a*a"))
  expect_identical(select_expr("b <- a * a
                                       c <- a * d", term = "b"), c(identity = "a*a"))
  expect_identical(select_expr("b <- exp(a * a)", term = "b"), c(exp = "a*a"))
  expect_identical(select_expr("b <- log(a[1] * a)
                                       c <- eee(a * d)", term = "b"), c(log = "a[1]*a"))
  expect_identical(select_expr("b <- log(a[1] * a)
                                       c <- eee(a * d)", term = "c"), c(eee = "a*d"))
  expect_error(select_expr("a <- bYear[1] * Year + 2 +", "a"), "new_expr is incomplete")
})

test_that("list_by_name", {
  expect_identical(list_by_name(c(bYear = 1, bYear = 2)), list(bYear = c(1,2)))
})

test_that("is_named", {
  expect_true(is_named(c(x = 1)))
  expect_false(is_named(c(1)))
  expect_true(is_named(list(x = 1)))
  expect_false(is_named(list(1)))
})
