<!-- README.md is generated from README.Rmd. Please edit that file -->
<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/poissonconsulting/jmbr/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/poissonconsulting/jmbr/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/poissonconsulting/jmbr/branch/master/graph/badge.svg)](https://codecov.io/gh/poissonconsulting/jmbr?branch=master)
[![License:
MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/license/mit/)
<!-- badges: end -->

# jmbr

## Introduction

`jmbr` (pronounced jimber) is an R package to facilitate analyses using
Just Another Gibbs Sampler ([`JAGS`](http://mcmc-jags.sourceforge.net)).

It is part of the [mbr](https://github.com/poissonconsulting/mbr) family
of packages.

## Demonstration

    library(jmbr)
    library(mbr)

    # define model in JAGS language
    model <- model("model {
      alpha ~ dnorm(0, 10^-2)
      beta1 ~ dnorm(0, 10^-2)
      beta2 ~ dnorm(0, 10^-2)
      beta3 ~ dnorm(0, 10^-2)

      log_sAnnual ~ dnorm(0, 10^-2)
      log(sAnnual) <- log_sAnnual

      for(i in 1:nAnnual) {
        bAnnual[i] ~ dnorm(0, sAnnual^-2)
      }

      for (i in 1:length(Pairs)) {
        log(ePairs[i]) <- alpha + beta1 * Year[i] + beta2 * Year[i]^2 + beta3 * Year[i]^3 + bAnnual[Annual[i]]
        Pairs[i] ~ dpois(ePairs[i])
      }
    }")
    #> Warning: The `x` argument of `model()` character() as of embr 0.0.1.9036.
    #> ℹ Please use the `code` argument instead.
    #> ℹ Passing a string to model() is deprecated. Use model(code = ...) or model(mb_code("..."), ...) instead.
    #> This warning is displayed once every 8 hours.
    #> Call `lifecycle::last_lifecycle_warnings()` to see where this warning was generated.

    # add R code to calculate derived parameters
    model <- update_model(model, new_expr = "
    for (i in 1:length(Pairs)) {
      log(prediction[i]) <- alpha + beta1 * Year[i] + beta2 * Year[i]^2 + beta3 * Year[i]^3 + bAnnual[Annual[i]]
    }")

    # define data types and center year
    model <- update_model(model,
      select_data = list("Pairs" = integer(), "Year*" = integer(), Annual = factor()),
      derived = "sAnnual",
      random_effects = list(bAnnual = "Annual")
    )

    data <- bauw::peregrine
    data$Annual <- factor(data$Year)

    set_analysis_mode("report")

    # analyse
    analysis <- analyse(model, data = data)
    #> Warning in seq.default(along = varnames): partial argument match of 'along' to 'along.with'
    #> Warning in seq.default(along = ans): partial argument match of 'along' to 'along.with'
    #> Warning in seq.default(along = varnames): partial argument match of 'along' to 'along.with'
    #> Warning in seq.default(along = variable.names[type == t]): partial argument match of 'along' to 'along.with'
    #> Warning in seq.default(along = varnames): partial argument match of 'along' to 'along.with'
    #> Warning in seq.default(along = ans): partial argument match of 'along' to 'along.with'
    #> Warning in seq.default(along = varnames): partial argument match of 'along' to 'along.with'
    #> Warning in seq.default(along = variable.names[type == t]): partial argument match of 'along' to 'along.with'
    #> Warning in seq.default(along = varnames): partial argument match of 'along' to 'along.with'
    #> Warning in seq.default(along = ans): partial argument match of 'along' to 'along.with'
    #> Warning in seq.default(along = varnames): partial argument match of 'along' to 'along.with'
    #> Warning in seq.default(along = variable.names[type == t]): partial argument match of 'along' to 'along.with'
    #> # A tibble: 1 × 8
    #>       n     K nchains niters nthin   ess  rhat converged
    #>   <int> <int>   <int>  <int> <int> <int> <dbl> <lgl>    
    #> 1    40     5       3    500     1     9  7.54 FALSE
    analysis <- reanalyse(analysis)
    #> Warning in seq.default(along = varnames): partial argument match of 'along' to 'along.with'
    #> Warning in seq.default(along = ans): partial argument match of 'along' to 'along.with'
    #> Warning in seq.default(along = varnames): partial argument match of 'along' to 'along.with'
    #> Warning in seq.default(along = variable.names[type == t]): partial argument match of 'along' to 'along.with'
    #> Warning in seq.default(along = varnames): partial argument match of 'along' to 'along.with'
    #> Warning in seq.default(along = ans): partial argument match of 'along' to 'along.with'
    #> Warning in seq.default(along = varnames): partial argument match of 'along' to 'along.with'
    #> Warning in seq.default(along = variable.names[type == t]): partial argument match of 'along' to 'along.with'
    #> Warning in seq.default(along = varnames): partial argument match of 'along' to 'along.with'
    #> Warning in seq.default(along = ans): partial argument match of 'along' to 'along.with'
    #> Warning in seq.default(along = varnames): partial argument match of 'along' to 'along.with'
    #> Warning in seq.default(along = variable.names[type == t]): partial argument match of 'along' to 'along.with'
    #> # A tibble: 1 × 8
    #>       n     K nchains niters nthin   ess  rhat converged
    #>   <int> <int>   <int>  <int> <int> <int> <dbl> <lgl>    
    #> 1    40     5       3    500     2    24  3.58 FALSE

    coef(analysis, simplify = TRUE)
    #> # A tibble: 5 × 5
    #>   term        estimate   lower upper  svalue
    #>   <term>         <dbl>   <dbl> <dbl>   <dbl>
    #> 1 alpha        4.23     2.37   4.34  10.6   
    #> 2 beta1        1.15    -0.790  1.35   0.775 
    #> 3 beta2       -0.00247 -0.0971 0.594  0.0529
    #> 4 beta3       -0.246   -0.355  0.551  0.500 
    #> 5 log_sAnnual -1.88    -2.73   0.657  1.01

    plot(analysis)
    #> Warning in rep(col, length = nchain(x)): partial argument match of 'length' to 'length.out'
    #> Warning in rep(col, length = nchain(x)): partial argument match of 'length' to 'length.out'
    #> Warning in rep(col, length = nchain(x)): partial argument match of 'length' to 'length.out'

![](tools/README-unnamed-chunk-3-1.png)

    #> Warning in rep(col, length = nchain(x)): partial argument match of 'length' to 'length.out'
    #> Warning in rep(col, length = nchain(x)): partial argument match of 'length' to 'length.out'

![](tools/README-unnamed-chunk-3-2.png)

    # make predictions by varying year with other predictors including the random effect of Annual held constant
    year <- predict(analysis, new_data = "Year")

    # plot those predictions
    library(ggplot2)

    ggplot(data = year, aes(x = Year, y = estimate)) +
      geom_point(data = bauw::peregrine, aes(y = Pairs)) +
      geom_line() +
      geom_line(aes(y = lower), linetype = "dotted") +
      geom_line(aes(y = upper), linetype = "dotted") +
      expand_limits(y = 0)

![](tools/README-unnamed-chunk-4-1.png)

## Installation

To install from GitHub

    install.packages("devtools")
    devtools::install_github("poissonconsulting/jmbr")

## Citation

    To cite jmbr in publications use:

      Joe Thorley (2018) jmbr: Analyses Using JAGS. doi: https://doi.org/10.5281/zenodo.1162355.

    A BibTeX entry for LaTeX users is

      @Misc{,
        author = {Joe Thorley},
        year = {2018},
        title = {jmbr: Analyses Using JAGS},
        doi = {https://doi.org/10.5281/zenodo.1162355},
      }

    Please also cite JAGS.

## Contribution

Please report any
[issues](https://github.com/poissonconsulting/jmbr/issues).

[Pull requests](https://github.com/poissonconsulting/jmbr/pulls) are
always welcome.

## Code of Conduct

Please note that the jmbr project is released with a [Contributor Code
of
Conduct](https://contributor-covenant.org/version/2/0/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.

## Inspiration

-   [jaggernaut](https://github.com/poissonconsulting/jaggernaut)
