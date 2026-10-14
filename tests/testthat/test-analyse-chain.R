test_that("loading modules in a chain does not warn about partial matching", {
  rjags::load.module("glm", quiet = TRUE)
  on.exit(rjags::unload.module("glm", quiet = TRUE), add = TRUE)

  model <- model(
    code = "model {
      bMu ~ dnorm(0, 100^-2)
      sY ~ dexp(1)
      for (i in 1:nObs) {
        y[i] ~ dnorm(bMu, sY^-2)
      }
    }",
    select_data = list(y = 1)
  )
  loaded <- embr::load_model(model, quiet = TRUE)
  data <- embr::modify_data(data.frame(y = c(9, 10, 11, 12, 8)), model = model)
  modules <- rjags::list.modules()
  rjags::unload.module("glm", quiet = TRUE)

  old_options <- options(warnPartialMatchArgs = TRUE)
  on.exit(options(old_options), add = TRUE)
  expect_no_warning(
    jmb_analyse_chain(
      list(.RNG.name = "base::Wichmann-Hill", .RNG.seed = 1L),
      loaded = loaded,
      data = data,
      monitor = c("bMu", "sY"),
      niters = 1000L,
      nthin = 1L,
      modules = modules,
      quiet = TRUE
    ),
    class = "partialMatchWarning"
  )
  expect_true("glm" %in% rjags::list.modules())
})
