---
output: github_document
---

<!-- README.md is generated from README.Rmd. Please edit that file -->



 [![lifecycle](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://www.tidyverse.org/lifecycle/#maturing)
[![Travis-CI Build Status](https://travis-ci.org/poissonconsulting/jmbr.svg?branch=master)](https://travis-ci.org/poissonconsulting/jmbr)
[![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/poissonconsulting/jmbr?branch=master&svg=true)](https://ci.appveyor.com/project/poissonconsulting/jmbr)
[![codecov](https://codecov.io/gh/poissonconsulting/jmbr/branch/master/graph/badge.svg)](https://codecov.io/gh/poissonconsulting/jmbr)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.1162355.svg)](https://doi.org/10.5281/zenodo.1162355)

# jmbr

## Introduction

`jmbr` (pronounced jimber) is an R package to facilitate analyses using Just Another Gibbs Sampler ([`JAGS`](http://mcmc-jags.sourceforge.net)).

It is part of the [mbr](https://github.com/poissonconsulting/mbr) family of packages.

## Demonstration


```r
library(jmbr)
```


```r
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
model <- update_model(model, new_expr = "
for (i in 1:length(Pairs)) {
  log(prediction[i]) <- alpha + beta1 * Year[i] + beta2 * Year[i]^2 + beta3 * Year[i]^3 + bAnnual[Annual[i]]
}")

# define data types and center year
model <- update_model(model, 
  select_data = list("Pairs" = integer(), "Year*" = integer(), Annual = factor()),
  derived = "sAnnual",
  random_effects = list(bAnnual = "Annual"))

data <- bauw::peregrine
data$Annual <- factor(data$Year)

set_analysis_mode("report")

# analyse
analysis <- analyse(model, data = data)
#> # A tibble: 1 x 8
#>       n     K nchains niters nthin   ess  rhat converged
#>   <int> <int>   <int>  <int> <int> <int> <dbl> <lgl>    
#> 1    40     5       3    500     1     9  2.67 FALSE
analysis <- reanalyse(analysis)
#> # A tibble: 1 x 8
#>       n     K nchains niters nthin   ess  rhat converged
#>   <int> <int>   <int>  <int> <int> <int> <dbl> <lgl>    
#> 1    40     5       3    500     2    21  3.50 FALSE

coef(analysis)
#> # A tibble: 5 x 7
#>   term         estimate    sd zscore   lower  upper pvalue
#>   <S3: term>      <dbl> <dbl>  <dbl>   <dbl>  <dbl>  <dbl>
#> 1 alpha        4.24     0.811  4.69   1.59   4.33   0.0007
#> 2 beta1        1.13     0.322  3.15   0.133  1.39   0.012 
#> 3 beta2        0.000603 0.372  0.489 -0.0688 1.16   0.991 
#> 4 beta3       -0.245    0.107 -2.02  -0.372  0.0141 0.0653
#> 5 log_sAnnual -2.05     1.10  -1.39  -2.78   0.647  0.371

plot(analysis)
```

![plot of chunk unnamed-chunk-3](tools/README-unnamed-chunk-3-1.png)![plot of chunk unnamed-chunk-3](tools/README-unnamed-chunk-3-2.png)


```r
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
```

![plot of chunk unnamed-chunk-4](tools/README-unnamed-chunk-4-1.png)

## Installation

To install from GitHub
```
install.packages("devtools")
devtools::install_github("poissonconsulting/jmbr")
```

or the Poisson drat [Repository](https://github.com/poissonconsulting/drat)

```
install.packages("drat")
drat::addRepo("poissonconsulting")
install.packages("jmbr")
```

## Citation


```

To cite tmbr in publications use:

  Joe Thorley (2018) tmbr: Analyses Using TMB. doi:
  https://doi.org/10.5281/zenodo.1162374.

A BibTeX entry for LaTeX users is

  @Misc{,
    author = {Joe Thorley},
    year = {2018},
    title = {tmbr: Analyses Using TMB},
    doi = {https://doi.org/10.5281/zenodo.1162374},
  }

Please also cite TMB.
```

## Contribution

Please report any [issues](https://github.com/poissonconsulting/jmbr/issues).

[Pull requests](https://github.com/poissonconsulting/jmbr/pulls) are always welcome.

Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.

## Inspiration

- [jaggernaut](https://github.com/poissonconsulting/jaggernaut)
