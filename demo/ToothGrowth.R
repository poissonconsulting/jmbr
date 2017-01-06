# load required packages

library(datasets)
library(stats)
library(mcmcr)

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
    elen[i] <- bsupp[supp[i]]
    len[i] ~ dnorm(elen[i], slen^-2)
  }
}"

# perform last analysis using jmbr
code <- mb_code(template)

model <- model(code, monitor = "^b")

analysis <- analyse(model, data = data)

analysis <- reanalyse(analysis)

coef(analysis)
estimates(analysis)
nchains(analysis)
