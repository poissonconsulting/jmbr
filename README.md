
<!-- README.md is generated from README.Rmd. Please edit that file -->
<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/poissonconsulting/jmbr/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/poissonconsulting/jmbr/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/poissonconsulting/jmbr/branch/master/graph/badge.svg)](https://codecov.io/gh/poissonconsulting/jmbr?branch=master)
[![License:
MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
<!-- badges: end -->

# jmbr

## Introduction

`jmbr` (pronounced jimber) is an R package to facilitate analyses using
Just Another Gibbs Sampler ([`JAGS`](http://mcmc-jags.sourceforge.net)).

It is part of the [mbr](https://github.com/poissonconsulting/mbr) family
of packages.

## Demonstration

``` r
library(jmbr)
library(mbr)
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
#> Registered S3 method overwritten by 'rjags':
#>   method               from 
#>   as.mcmc.list.mcarray mcmcr
#> # A tibble: 1 × 8
#>       n     K nchains niters nthin   ess  rhat converged
#>   <int> <int>   <int>  <int> <int> <int> <dbl> <lgl>    
#> 1    40     5       3    500     1    10  5.61 FALSE
analysis <- reanalyse(analysis)
#> # A tibble: 1 × 8
#>       n     K nchains niters nthin   ess  rhat converged
#>   <int> <int>   <int>  <int> <int> <int> <dbl> <lgl>    
#> 1    40     5       3    500     2    50  5.64 FALSE

coef(analysis)
#> Warning: The `simplify` argument of `coef()` must be TRUE as of mcmcr 0.4.1.
#> ℹ The deprecated feature was likely used in the base package.
#>   Please report the issue to the authors.
#> # A tibble: 5 × 7
#>   term        estimate    sd zscore  lower upper   pvalue
#>   <term>         <dbl> <dbl>  <dbl>  <dbl> <dbl>    <dbl>
#> 1 alpha         4.21   1.49   2.05   0.745 4.60  0.000666
#> 2 beta1        -0.539  1.18  -0.168 -1.90  1.29  0.820   
#> 3 beta2         0.0127 0.543  0.556 -0.375 1.34  0.920   
#> 4 beta3         0.155  0.299  0.267 -0.324 0.560 0.767   
#> 5 log_sAnnual  -0.156  1.46  -0.308 -2.75  1.29  0.929

plot(analysis)
```

![](tools/README-unnamed-chunk-3-1.png)<!-- -->![](tools/README-unnamed-chunk-3-2.png)<!-- -->

``` r
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

![](tools/README-unnamed-chunk-4-1.png)<!-- -->

## Installation

To install from GitHub

    install.packages("devtools")
    devtools::install_github("poissonconsulting/jmbr")

## Citation


    To cite jmbr in publications use:

      Joe Thorley (2018) jmbr: Analyses Using JAGS. doi:
      https://doi.org/10.5281/zenodo.1162355.

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

- [jaggernaut](https://github.com/poissonconsulting/jaggernaut)
