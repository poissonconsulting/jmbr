model_code_example1 <- "
#include <TMB.hpp>

template<class Type>
Type objective_function<Type>::operator() () {
DATA_VECTOR(x);
DATA_VECTOR(y);

PARAMETER(a); // intercept
PARAMETER(b); // slope
PARAMETER(log_sigma);

Type sigma = exp(log_sigma);

int n = y.size();

Type nll = 0.0;
for(int i = 0; i < n; i++){
  nll -= dnorm(y(i), a + b * x(i), sigma, true);
}

return nll;
}"

gen_inits_example1 <- function(data) list(a = 0, b = 0, log_sigma = 0)

model_code_example2 <- "
#include <TMB.hpp>

template<class Type>
Type objective_function<Type>::operator() () {
DATA_VECTOR(x);
DATA_VECTOR(y);
DATA_FACTOR(Year);

PARAMETER(log_sigma);
PARAMETER_VECTOR(bYear);
PARAMETER(a); // intercept
PARAMETER(b); // slope
PARAMETER(log_sYear);

vector<Type> fit = x;
vector<Type> residual = x;

Type sigma = exp(log_sigma);
Type sYear = exp(log_sYear);

int nYear = bYear.size();
int n = y.size();

Type zero = 0.0;

Type nll = 0.0;

for(int i = 0; i < nYear; i++){
  nll -= dnorm(bYear(i), zero, sYear, true);
}

for(int i = 0; i < n; i++){
  fit(i) = a + b * x(i) + bYear(Year(i));
  residual(i) = y(i) - fit(i);
  nll -= dnorm(y(i), fit(i), sigma, true);
}
REPORT(fit);
ADREPORT(residual);
return nll;
}"

gen_inits_example2 <- function(data) list(a = 0, b = 0, log_sigma = 0, bYear = c(NA, rep(0, 9)), log_sYear = 0)

model_code_example3 <- "
#include <TMB.hpp>

template<class Type>
Type objective_function<Type>::operator() () {
DATA_VECTOR(Count);
DATA_FACTOR(Year);
DATA_FACTOR(Site);
DATA_VECTOR(Slope);

PARAMETER(bIntercept);
PARAMETER(bSlope);
PARAMETER_VECTOR(bYear);
PARAMETER_VECTOR(bSite);
PARAMETER_MATRIX(bSiteYear);

PARAMETER(log_sYear);
PARAMETER(log_sSite);
PARAMETER(log_sSiteYear);

Type sYear = exp(log_sYear);
Type sSite = exp(log_sSite);
Type sSiteYear = exp(log_sSiteYear);

int nYear = bYear.size();
int nSite = bSite.size();
int n = Count.size();

vector<Type> eCount = Count;

Type zero = 0.0;

Type nll = 0.0;

for(int i = 0; i < nYear; i++){
  nll -= dnorm(bYear(i), zero, sYear, true);
}

for(int i = 0; i < nSite; i++){
  nll -= dnorm(bSite(i), zero, sSite, true);
  for(int j = 0; j < nYear; j++){
    nll -= dnorm(bSiteYear(i,j), zero, sSiteYear, true);
  }
}

for(int i = 0; i < n; i++){
  eCount(i) = exp(bIntercept + bSlope * Slope(i) + bYear(Year(i)) + bSite(Site(i)) + bSiteYear(Site(i),Year(i)));
  nll -= dpois(Count(i), eCount(i), true);
}
return nll;
}"

gen_inits_example3 <- function(data) list(bIntercept = 3, bSlope = 0, log_sYear = 0, log_sSite = 0, log_sSiteYear = 0)

random_effects_example3 <- list(bYear = "Year", bSite = "Site", bSiteYear = c("Site", "Year"))
new_expr_example3 <- "prediction <- exp(bIntercept + bSlope * Slope + bYear[Year] + bSite[Site] + bSiteYear[Site,Year])"
select_data_example3 = list(Count = 1L, Year = factor(1), Site = factor(1), Slope = 1)

. <- NULL
.nchains <- 4L

