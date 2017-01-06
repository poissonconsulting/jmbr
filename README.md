
<!-- README.md is generated from README.Rmd. Please edit that file -->
[![Travis-CI Build Status](https://travis-ci.org/poissonconsulting/jmbr.svg?branch=master)](https://travis-ci.org/poissonconsulting/jmbr) [![codecov](https://codecov.io/gh/poissonconsulting/jmbr/branch/master/graph/badge.svg)](https://codecov.io/gh/poissonconsulting/jmbr)

jmbr
====

Introduction
------------

`jmbr` (pronounced jimber) is an R package to facilitate analyses using Just Another Gibbs Sampler (JAGS).

Demonstration
-------------

``` r
library(jmbr)
#> Loading required package: mbr
#> Loading required package: mcmcr
#> Loading required package: newdata
library(ggplot2)

data <- datasets::ToothGrowth

summary(lm(len ~ supp + dose , data = data))
#> 
#> Call:
#> lm(formula = len ~ supp + dose, data = data)
#> 
#> Residuals:
#>    Min     1Q Median     3Q    Max 
#> -6.600 -3.700  0.373  2.116  8.800 
#> 
#> Coefficients:
#>             Estimate Std. Error t value Pr(>|t|)    
#> (Intercept)   9.2725     1.2824   7.231 1.31e-09 ***
#> suppVC       -3.7000     1.0936  -3.383   0.0013 ** 
#> dose          9.7636     0.8768  11.135 6.31e-16 ***
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 4.236 on 57 degrees of freedom
#> Multiple R-squared:  0.7038, Adjusted R-squared:  0.6934 
#> F-statistic: 67.72 on 2 and 57 DF,  p-value: 8.716e-16

jags_template <- "
  model{
    bdose ~ dnorm(0, 5^-2)
    for(i in 1:nsupp) {
      bsupp[i] ~ dnorm(15, 10^-2)
    }
    slen ~ dunif(0, 10)

    for(i in 1:length(supp)) {
      elen[i] <- bsupp[supp[i]] + dose[i] * bdose
      len[i] ~ dnorm(elen[i], slen^-2)
    }
  }
"

model <- model(mb_code(jags_template), monitor = "^b",
               new_expr = "for(i in 1:length(supp)) prediction[i] <- bsupp[supp[i]] + dose[i] * bdose")

analysis <- analyse(model, data = data)
analysis <- reanalyse(analysis)

convergence(analysis)
#> [1] 1.01
coef(analysis)
#> # A tibble: 3 × 7
#>       term estimate std.error statistic p.value    lower     upper
#> *    <chr>    <dbl>     <dbl>     <dbl>   <dbl>    <dbl>     <dbl>
#> 1    bdose 9.291658 0.8426789 11.021502   5e-04 7.564763 10.887035
#> 2 bsupp[1] 9.863273 1.2473683  7.890909   5e-04 7.350397 12.274572
#> 3 bsupp[2] 6.166892 1.2735565  4.876722   5e-04 3.861351  8.776092
estimates(analysis)
#> $bdose
#> [1] 9.291658
#> 
#> $bsupp
#> [1] 9.863273 6.166892

plot(analysis)
```

![](README-unnamed-chunk-2-1.png)

``` r

len <- predict(analysis, new_data = unique(data[c("supp", "dose")]))

ggplot(data = len, aes(x = dose, y = estimate)) +
  facet_wrap(~supp) +
  geom_pointrange(aes(ymin = lower, ymax = upper))
```

![](README-unnamed-chunk-2-2.png)

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
