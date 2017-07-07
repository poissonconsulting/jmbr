
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
#> Warning: package 'dplyr' was built under R version 3.4.1
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
#> 1    40     5     2000       4  4000           1.1s  4.32     FALSE
analysis %<>% reanalyse(rhat = 1.05)
#> # A tibble: 1 x 8
#>       n     K nsamples nchains nsims       duration  rhat converged
#>   <int> <int>    <int>   <int> <int> <S4: Duration> <dbl>     <lgl>
#> 1    40     5     2000       4  8000           1.8s  1.59     FALSE
#> # A tibble: 1 x 8
#>       n     K nsamples nchains nsims       duration  rhat converged
#>   <int> <int>    <int>   <int> <int> <S4: Duration> <dbl>     <lgl>
#> 1    40     5     2000       4 16000           2.9s  1.02      TRUE

coef(analysis)
#> # A tibble: 5 x 7
#>          term    estimate         sd      zscore       lower       upper
#> *  <S3: term>       <dbl>      <dbl>       <dbl>       <dbl>       <dbl>
#> 1       alpha  4.21138251 0.04041260 104.1785750  4.12990741  4.28843009
#> 2       beta1  1.18892366 0.07304180  16.3232834  1.06414398  1.34951822
#> 3       beta2  0.01723847 0.03078737   0.5597436 -0.04266213  0.07804809
#> 4       beta3 -0.27075301 0.03735017  -7.2814823 -0.35214221 -0.20217399
#> 5 log_sAnnual -2.25132597 0.29455283  -7.7091312 -2.93327534 -1.77770088
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
