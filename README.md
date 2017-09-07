
<!-- README.md is generated from README.Rmd. Please edit that file -->
[![stability-unstable](https://img.shields.io/badge/stability-unstable-yellow.svg)](https://github.com/joethorley/stability-badges#unstable) [![Travis-CI Build Status](https://travis-ci.org/poissonconsulting/jmbr.svg?branch=master)](https://travis-ci.org/poissonconsulting/jmbr) [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/poissonconsulting/jmbr?branch=master&svg=true)](https://ci.appveyor.com/project/poissonconsulting/jmbr) [![codecov](https://codecov.io/gh/poissonconsulting/jmbr/branch/master/graph/badge.svg)](https://codecov.io/gh/poissonconsulting/jmbr) [![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT) [![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/mbr)](https://cran.r-project.org/package=mbr)

jmbr
====

Introduction
------------

`jmbr` (pronounced jimber) is an R package to facilitate analyses using Just Another Gibbs Sampler (JAGS).

It is part of the [mbr](https://github.com/poissonconsulting/mbr) family of packages.

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

# add R code to calculate derived parameters
model %<>% update_model(new_expr = "
for (i in 1:length(Pairs)) {
  log(prediction[i]) <- alpha + beta1 * Year[i] + beta2 * Year[i]^2 + beta3 * Year[i]^3 + bAnnual[Annual[i]]
}")

# define data types and center year
model %<>% update_model(
  select_data = list("Pairs" = integer(), "Year*" = integer(), Annual = factor()),
  derived = "sAnnual",
  random_effects = list(bAnnual = "Annual"))

data <- bauw::peregrine
data$Annual <- factor(data$Year)

# analyse
analysis <- analyse(model, data = data)
#> # A tibble: 1 x 8
#>       n     K nsamples nchains nsims       duration  rhat converged
#>   <int> <int>    <int>   <int> <int> <S4: Duration> <dbl>     <lgl>
#> 1    40     5     2000       4  4000             1s  3.03     FALSE
analysis %<>% reanalyse(rhat = 1.05)
#> # A tibble: 1 x 8
#>       n     K nsamples nchains nsims       duration  rhat converged
#>   <int> <int>    <int>   <int> <int> <S4: Duration> <dbl>     <lgl>
#> 1    40     5     2000       4  8000           1.6s  1.71     FALSE
#> # A tibble: 1 x 8
#>       n     K nsamples nchains nsims       duration  rhat converged
#>   <int> <int>    <int>   <int> <int> <S4: Duration> <dbl>     <lgl>
#> 1    40     5     2000       4 16000           2.6s  1.02      TRUE

coef(analysis)
#> # A tibble: 5 x 7
#>          term    estimate         sd      zscore       lower       upper
#> *  <S3: term>       <dbl>      <dbl>       <dbl>       <dbl>       <dbl>
#> 1       alpha  4.21088878 0.03923204 107.3162472  4.13275511  4.28653475
#> 2       beta1  1.18949075 0.07365977  16.2151516  1.05853756  1.34272873
#> 3       beta2  0.01718038 0.02960662   0.5774489 -0.03910455  0.07455118
#> 4       beta3 -0.27069557 0.03789248  -7.1959657 -0.35133320 -0.19915844
#> 5 log_sAnnual -2.23829742 0.32853738  -6.9290403 -3.03398868 -1.74563160
#> # ... with 1 more variables: pvalue <dbl>

plot(analysis)
```

![](tools/README-unnamed-chunk-3-1.png)![](tools/README-unnamed-chunk-3-2.png)

``` r
# make predictions by varying year with other predictors including the random effect of Annual held constant
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

Creditation
-----------

-   [JAGS](http://mcmc-jags.sourceforge.net)
