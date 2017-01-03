# load required packages

library(datasets)
library(stats)

# cleanup workspace
rm(list = ls())

# input data
data <- ToothGrowth

mod <- lm(len ~ supp - 1, data = data)
summary(mod)

template <- "
model{
  for(i in 1:nsupp) {
    bsupp[i] ~ dnorm(15, 10^-2)
  }
  slen ~ dunif(0, 10)

  for(i in 1:length(len)) {
    len ~ dnorm(elen[i], slen^-2)
  }
}"

# perform last analysis using jmbr
code <- mb_code(template)

model <- model(code)

analysis <- analyse(model, data = data)

coef(analysis)
logLik(analysis)
nterms(analysis)

IC(analysis, n = Inf)
stopifnot(all.equal(IC(analysis, n = Inf), AIC(mod)))
