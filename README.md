
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
#> Warning in bind_rows_(x, .id): Vectorizing 'term' elements may not preserve
#> their attributes

#> Warning in bind_rows_(x, .id): Vectorizing 'term' elements may not preserve
#> their attributes

#> Warning in bind_rows_(x, .id): Vectorizing 'term' elements may not preserve
#> their attributes

#> Warning in bind_rows_(x, .id): Vectorizing 'term' elements may not preserve
#> their attributes

#> Warning in bind_rows_(x, .id): Vectorizing 'term' elements may not preserve
#> their attributes
#> # A tibble: 1 × 8
#>       n     K nsamples nchains nsims           duration  rhat converged
#>   <int> <int>    <int>   <int> <int>     <S4: Duration> <dbl>     <lgl>
#> 1    40     5     2000       4  4000 0.329591989517212s  1.07      TRUE
analysis <- reanalyse(analysis, rhat = 1.05)
#> Warning in bind_rows_(x, .id): Vectorizing 'term' elements may not preserve
#> their attributes

#> Warning in bind_rows_(x, .id): Vectorizing 'term' elements may not preserve
#> their attributes

#> Warning in bind_rows_(x, .id): Vectorizing 'term' elements may not preserve
#> their attributes

#> Warning in bind_rows_(x, .id): Vectorizing 'term' elements may not preserve
#> their attributes

#> Warning in bind_rows_(x, .id): Vectorizing 'term' elements may not preserve
#> their attributes
#> # A tibble: 1 × 8
#>       n     K nsamples nchains nsims           duration  rhat converged
#>   <int> <int>    <int>   <int> <int>     <S4: Duration> <dbl>     <lgl>
#> 1    40     5     2000       4  8000 0.584886789321899s  1.02      TRUE

coef(analysis)
#> Warning in bind_rows_(x, .id): Vectorizing 'term' elements may not preserve
#> their attributes

#> Warning in bind_rows_(x, .id): Vectorizing 'term' elements may not preserve
#> their attributes

#> Warning in bind_rows_(x, .id): Vectorizing 'term' elements may not preserve
#> their attributes

#> Warning in bind_rows_(x, .id): Vectorizing 'term' elements may not preserve
#> their attributes

#> Warning in bind_rows_(x, .id): Vectorizing 'term' elements may not preserve
#> their attributes
#> # A tibble: 5 × 7
#>              term    estimate         sd     zscore       lower
#> *      <S3: term>       <dbl>      <dbl>      <dbl>       <dbl>
#> 1           alpha  4.21683478 0.03904673 107.981507  4.14144452
#> 2           beta1  1.17798994 0.06793828  17.383115  1.05239903
#> 3           beta2  0.01830389 0.03072267   0.588996 -0.04532292
#> 4           beta3 -0.26473785 0.03463306  -7.678952 -0.33826740
#> 5 log_sDispersion -2.23250259 0.31347703  -7.208431 -2.90272296
#> # ... with 2 more variables: upper <dbl>, pvalue <dbl>

plot(analysis)
```

![](tools/README-unnamed-chunk-2-1.png)![](tools/README-unnamed-chunk-2-2.png)

``` r

year <- predict(analysis, new_data = new_data(data, "Year"))
#> Warning in bind_rows_(x, .id): Vectorizing 'term' elements may not preserve
#> their attributes

ggplot(data = year, aes(x = Year, y = estimate)) +
  geom_point(data = data, aes(y = Pairs)) +
  geom_line() +
  geom_line(aes(y = lower), linetype = "dotted") +
  geom_line(aes(y = upper), linetype = "dotted") +
  expand_limits(y = 0)
```

![](tools/README-unnamed-chunk-2-3.png)

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
