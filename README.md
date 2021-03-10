
<!-- README.md is generated from README.Rmd. Please edit that file -->

[![Lifecycle:
stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
[![R build
status](https://github.com/poissonconsulting/jmbr/workflows/R-CMD-check/badge.svg)](https://github.com/poissonconsulting/jmbr/actions)
[![Codecov test
coverage](https://codecov.io/gh/poissonconsulting/jmbr/branch/master/graph/badge.svg)](https://codecov.io/gh/poissonconsulting/jmbr?branch=master)
[![License:
MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.1162355.svg)](https://doi.org/10.5281/zenodo.1162355)

# jmbr

## Introduction

`jmbr` (pronounced jimber) is an R package to facilitate analyses using
Just Another Gibbs Sampler ([`JAGS`](http://mcmc-jags.sourceforge.net)).

It is part of the [mbr](https://github.com/poissonconsulting/mbr) family
of packages.

## Demonstration

``` r
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
#> # A tibble: 1 x 8
#>       n     K nchains niters nthin   ess  rhat converged
#>   <int> <int>   <int>  <int> <int> <int> <dbl> <lgl>    
#> 1    40     5       3    500     1    10  5.70 FALSE
analysis <- reanalyse(analysis)
#> # A tibble: 1 x 8
#>       n     K nchains niters nthin   ess  rhat converged
#>   <int> <int>   <int>  <int> <int> <int> <dbl> <lgl>    
#> 1    40     5       3    500     2    24  1.25 FALSE

coef(analysis)
#> Warning: The `simplify` argument of `coef()` must be TRUE as of mcmcr 0.4.1.
#> # A tibble: 5 x 7
#>   term        estimate     sd  zscore   lower  upper   pvalue
#>   <term>         <dbl>  <dbl>   <dbl>   <dbl>  <dbl>    <dbl>
#> 1 alpha         4.25   0.235  17.8     3.28   4.33   0.000666
#> 2 beta1         1.20   0.294   3.78    0.122  1.35   0.000666
#> 3 beta2        -0.0124 0.0854  0.0842 -0.0737 0.316  0.707   
#> 4 beta3        -0.274  0.0926 -2.71   -0.355  0.0213 0.0819  
#> 5 log_sAnnual  -2.14   0.641  -3.12   -2.80   0.0571 0.0606

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

-   [jaggernaut](https://github.com/poissonconsulting/jaggernaut)
