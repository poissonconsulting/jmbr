
<!-- README.md is generated from README.Rmd. Please edit that file -->
[![Travis-CI Build Status](https://travis-ci.org/poissonconsulting/jmbr.svg?branch=master)](https://travis-ci.org/poissonconsulting/jmbr) [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/poissonconsulting/jmbr?branch=master&svg=true)](https://ci.appveyor.com/project/poissonconsulting/jmbr) [![codecov](https://codecov.io/gh/poissonconsulting/jmbr/branch/master/graph/badge.svg)](https://codecov.io/gh/poissonconsulting/jmbr)

jmbr
====

Introduction
------------

`jmbr` (pronounced jimber) is an R package to facilitate analyses using Just Another Gibbs Sampler (JAGS).

Demonstration
-------------

``` r
library(ggplot2)
library(jmbr)
#> Loading required package: broom
#> Loading required package: mbr
#> Loading required package: mcmcr
#> Loading required package: coda
#> 
#> Attaching package: 'mcmcr'
#> The following object is masked from 'package:ggplot2':
#> 
#>     derive
#> Loading required package: newdata

options("mb.parallel" = TRUE)
doParallel::registerDoParallel(4)

data <- bauw::peregrine

template <- "
model {
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
}"

new_expr <- "
for (i in 1:length(Pairs)) {
  prediction[i] <- exp(alpha + beta1 * Year[i] + beta2 * Year[i]^2 + beta3 * Year[i]^3)
}"

model <- model(template, scale = "Year", new_expr = new_expr, fixed = "^(a|b|l)")

analysis <- analyse(model, data = data)
#> # A tibble: 1 × 6
#>       n     K nsims minutes  rhat converged
#>   <int> <int> <int>   <int> <dbl>     <lgl>
#> 1    40     5  4000       0  1.14     FALSE
analysis <- reanalyse(analysis)
#> # A tibble: 1 × 6
#>       n     K nsims minutes  rhat converged
#>   <int> <int> <int>   <int> <dbl>     <lgl>
#> 1    40     5  8000       0  1.27     FALSE
#> # A tibble: 1 × 6
#>       n     K nsims minutes  rhat converged
#>   <int> <int> <int>   <int> <dbl>     <lgl>
#> 1    40     5 16000       0  1.01      TRUE

coef(analysis)
#> # A tibble: 5 × 7
#>              term    estimate         sd     zscore       lower
#> *      <S3: term>       <dbl>      <dbl>      <dbl>       <dbl>
#> 1           alpha  4.21114737 0.04269307 98.6059570  4.12242507
#> 2           beta1  1.19333489 0.07039818 17.0273326  1.07315360
#> 3           beta2  0.02030659 0.03327551  0.6505679 -0.04156247
#> 4           beta3 -0.27329630 0.03593528 -7.6705296 -0.34894141
#> 5 log_sDispersion -2.22845138 0.32722034 -6.8977375 -3.00317492
#> # ... with 2 more variables: upper <dbl>, pvalue <dbl>

plot(analysis)
```

![](README-unnamed-chunk-2-1.png)![](README-unnamed-chunk-2-2.png)

``` r

year <- predict(analysis, new_data = new_data(data, "Year"))

ggplot(data = year, aes(x = Year, y = estimate)) +
  geom_point(data = data, aes(y = Pairs)) +
  geom_line() +
  geom_line(aes(y = lower), linetype = "dotted") +
  geom_line(aes(y = upper), linetype = "dotted") +
  expand_limits(y = 0)
```

![](README-unnamed-chunk-2-3.png)

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
