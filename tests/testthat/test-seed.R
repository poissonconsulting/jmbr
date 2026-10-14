seed_model <- function(...) {
  model(
    code = "model {
      bMu ~ dnorm(0, 100^-2)
      sY ~ dexp(1)
      for (i in 1:nObs) {
        y[i] ~ dnorm(bMu, sY^-2)
      }
    }",
    select_data = list(y = 1),
    ...
  )
}

seed_analyse <- function(model, seed) {
  suppressWarnings(analyse(
    model,
    data = data.frame(y = c(9, 10, 11, 12, 8)),
    nchains = 2L,
    niters = 10L,
    glance = FALSE,
    beep = FALSE,
    seed = seed
  ))
}

test_that("analyse is reproducible with seed", {
  model <- seed_model()

  analysis1 <- seed_analyse(model, seed = 1L)
  analysis2 <- seed_analyse(model, seed = 1L)
  analysis3 <- seed_analyse(model, seed = 2L)

  expect_identical(as.mcmcr(analysis1), as.mcmcr(analysis2))
  expect_false(identical(as.mcmcr(analysis1), as.mcmcr(analysis3)))
})

test_that("analyse seed gives chains different rngs", {
  analysis <- seed_analyse(seed_model(), seed = 1L)

  inits <- analysis$inits
  expect_identical(
    vapply(inits, function(x) x$.RNG.name, ""),
    c("base::Wichmann-Hill", "base::Marsaglia-Multicarry")
  )
})

test_that("analyse seed makes gen_inits reproducible", {
  model <- seed_model(gen_inits = function(data) list(bMu = stats::rnorm(1)))

  analysis1 <- seed_analyse(model, seed = 1L)
  analysis2 <- seed_analyse(model, seed = 1L)

  expect_identical(analysis1$inits, analysis2$inits)
  expect_false(identical(analysis1$inits[[1]]$bMu, analysis1$inits[[2]]$bMu))
})

test_that("analyse seed does not change global rng state", {
  set.seed(42)
  expected <- stats::runif(1)

  set.seed(42)
  seed_analyse(seed_model(), seed = 1L)
  actual <- stats::runif(1)

  expect_identical(actual, expected)
})
