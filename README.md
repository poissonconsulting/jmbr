
<!-- README.md is generated from README.Rmd. Please edit that file -->
![stability-unstable](https://img.shields.io/badge/stability-unstable-yellow.svg) [![Travis-CI Build Status](https://travis-ci.org/poissonconsulting/jmbr.svg?branch=master)](https://travis-ci.org/poissonconsulting/jmbr) [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/poissonconsulting/jmbr?branch=master&svg=true)](https://ci.appveyor.com/project/poissonconsulting/jmbr) [![codecov](https://codecov.io/gh/poissonconsulting/jmbr/branch/master/graph/badge.svg)](https://codecov.io/gh/poissonconsulting/jmbr) [![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

jmbr
====

Introduction
------------

`jmbr` (pronounced jimber) is an R package to facilitate analyses using Just Another Gibbs Sampler (JAGS). It is part of the [mbr](https://github.com/poissonconsulting/mbr) family of packages.

Demonstration
-------------

``` r
library(magrittr)
library(ggplot2)
library(jmbr)
```

``` r
# define model in JAGS language
model <- model("model {
  alpha ~ dnorm(0, 10^-2)
  beta1 ~ dnorm(0, 10^-2)
  beta2 ~ dnorm(0, 10^-2)
  beta3 ~ dnorm(0, 10^-2)

  log_sDispersion ~ dnorm(0, 10^-2)

  log(sDispersion) <- log_sDispersion

  for (i in 1:length(Pairs)) {
    log(ePairs[i]) <- alpha + beta1 * Year[i] + beta2 * Year[i]^2 + beta3 * Year[i]^3
    eDispersion[i] ~ dgamma(1 / sDispersion^2, 1 / sDispersion^2)
    Pairs[i] ~ dpois(ePairs[i] * eDispersion[i])
  }
}")

# add R code to calculate derived parameters
model %<>% update_model(new_expr = "
for (i in 1:length(Pairs)) {
  prediction[i] <- exp(alpha + beta1 * Year[i] + beta2 * Year[i]^2 + beta3 * Year[i]^3)
}")

# define data types and center year
model %<>% update_model(select_data = list("Pairs" = integer(), "Year*" = integer()))

# analyse
analysis <- analyse(model, data = bauw::peregrine)
#> # A tibble: 1 × 8
#>       n     K nsamples nchains nsims           duration  rhat converged
#>   <int> <int>    <int>   <int> <int>     <S4: Duration> <dbl>     <lgl>
#> 1    40     6     2000       4  4000 0.625787973403931s  1.06      TRUE
analysis %<>% reanalyse(rhat = 1.05)
#> # A tibble: 1 × 8
#>       n     K nsamples nchains nsims         duration  rhat converged
#>   <int> <int>    <int>   <int> <int>   <S4: Duration> <dbl>     <lgl>
#> 1    40     6     2000       4  8000 1.1707968711853s  1.04      TRUE

coef(analysis)
#> # A tibble: 6 × 7
#>              term    estimate         sd      zscore       lower
#> *      <S3: term>       <dbl>      <dbl>       <dbl>       <dbl>
#> 1           alpha  4.21753001 0.03957244 106.5991373  4.14316887
#> 2           beta1  1.18255269 0.07602162  15.6329143  1.04827654
#> 3           beta2  0.01684336 0.02917942   0.5894709 -0.03800634
#> 4           beta3 -0.26696542 0.03782166  -7.1374926 -0.34728703
#> 5 log_sDispersion -2.23926475 0.30393877  -7.4906417 -2.99742494
#> 6     sDispersion  0.10653681 0.03006866   3.5628403  0.04991550
#> # ... with 2 more variables: upper <dbl>, pvalue <dbl>

plot(analysis)
```

![](tools/README-unnamed-chunk-3-1.png)![](tools/README-unnamed-chunk-3-2.png)

``` r
# make predictions by varying year with other predictors held constant
year <- predict(analysis, new_data = "Year")

# plot those predictions
ggplot(data = year, aes(x = Year, y = estimate)) +
  geom_point(data = bauw::peregrine, aes(y = Pairs)) +
  geom_line() +
  geom_line(aes(y = lower), linetype = "dotted") +
  geom_line(aes(y = upper), linetype = "dotted") +
  expand_limits(y = 0)
```

![](tools/README-unnamed-chunk-4-1.png)

Installation
------------

To install from GitHub

    # install.packages("devtools")
    devtools::install_github("poissonconsulting/jmbr")

Contribution
------------

Please report any [issues](https://github.com/poissonconsulting/jmbr/issues).

[Pull requests](https://github.com/poissonconsulting/jmbr/pulls) are always welcome.

Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.

Inspiration
-----------

-   [jaggernaut](https://github.com/poissonconsulting/jaggernaut)
