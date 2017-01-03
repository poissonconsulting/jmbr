library(testthat)
library(jmbr)

Sys.setenv("R_TESTS" = "")

test_check("jmbr")
