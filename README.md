
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
#> Loading required package: lubridate
#> 
#> Attaching package: 'lubridate'
#> The following object is masked from 'package:base':
#> 
#>     date
#> Loading required package: mcmcr
#> Loading required package: coda
#> Loading required package: dplyr
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:lubridate':
#> 
#>     intersect, setdiff, union
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
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
#> # A tibble: 1 × 8
#>       n     K nsims nchains nsamples           duration  rhat converged
#>   <int> <int> <int>   <int>    <int>     <S4: Duration> <dbl>     <lgl>
#> 1    40     5  4000       4     2000 0.397214889526367s  1.28     FALSE
analysis <- reanalyse(analysis, rhat = 1.05)
#> # A tibble: 1 × 8
#>       n     K nsims nchains nsamples           duration  rhat converged
#>   <int> <int> <int>   <int>    <int>     <S4: Duration> <dbl>     <lgl>
#> 1    40     5  8000       4     2000 0.701442956924438s  1.07      TRUE
#> # A tibble: 1 × 8
#>       n     K nsims nchains nsamples         duration  rhat converged
#>   <int> <int> <int>   <int>    <int>   <S4: Duration> <dbl>     <lgl>
#> 1    40     5 16000       4     2000 1.2069079875946s  1.02      TRUE

coef(analysis)
#> # A tibble: 5 × 7
#>              term    estimate         sd      zscore       lower
#> *      <S3: term>       <dbl>      <dbl>       <dbl>       <dbl>
#> 1           alpha  4.21726317 0.04028850 104.6923642  4.13972121
#> 2           beta1  1.18295482 0.06833576  17.3521776  1.05749771
#> 3           beta2  0.01786635 0.03070446   0.5585299 -0.04212982
#> 4           beta3 -0.26631017 0.03470670  -7.7272600 -0.34252029
#> 5 log_sDispersion -2.25630852 0.30719811  -7.4592862 -3.03343771
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
