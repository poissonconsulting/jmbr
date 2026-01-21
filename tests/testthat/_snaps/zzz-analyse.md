# analyse character vector

    model{
    
      bIntercept ~ dnorm(0, (5 * 10)^-2)
      bYear ~ dnorm(0, (.5 * 10)^-2)
    
      bHabitatQuality[1] <- 0
      for(i in 2:nHabitatQuality) {
        bHabitatQuality[i] ~ dnorm(0, (5. * 10)^-2) T(0,)
      }
    
      log_sSiteYear ~ dlnorm(0, (5 * 10)^-2)
      log_sDensity ~ dt(0, (5 * 10)^-2, 4.5)
    
      log(sSiteYear) <- log_sSiteYear
      log(sDensity) <- log_sDensity
    
      for(i in 1:nSite) {
        for(j in 1:nYearFactor) {
          bSiteYear[i,j] ~ dnorm(0, sSiteYear^-2)
        }
      }
    
      for(i in 1:length(Density)) {
        eDensity[i] <- bIntercept + bYear * Year[i] + bHabitatQuality[HabitatQuality[i]] + bSiteYear[Site[i], YearFactor[i]]
        Density[i] ~ dlnorm(eDensity[i], sDensity^-2)
      }
    }

# analyse vectorized embedded expression

    model{
    
      bIntercept ~ dnorm(0, (5 * 10)^-2)
      bYear ~ dnorm(0, (.5 * 10)^-2)
    
      bHabitatQuality[1] <- 0
      for(i in 2:nHabitatQuality) {
        bHabitatQuality[i] ~ dnorm(0, (5. * 10)^-2) T(0,)
      }
    
      log_sSiteYear ~ dlnorm(0, (5 * 10)^-2)
      log_sDensity ~ dt(0, (5 * 10)^-2, 4.5)
    
      log(sSiteYear) <- log_sSiteYear
      log(sDensity) <- log_sDensity
    
      for(i in 1:nSite) {
        for(j in 1:nYearFactor) {
          bSiteYear[i,j] ~ dnorm(0, sSiteYear^-2)
        }
      }
    
      for(i in 1:length(Density)) {
        eDensity[i] <- bIntercept + bYear * Year[i] + bHabitatQuality[HabitatQuality[i]] + bSiteYear[Site[i], YearFactor[i]]
        Density[i] ~ dlnorm(eDensity[i], sDensity^-2)
      }
    }

# analyse vectorized embedded nested expression

    model{
    
      bIntercept ~ dnorm(0, (5 * 10)^-2)
      bYear ~ dnorm(0, (.5 * 10)^-2)
    
      bHabitatQuality[1] <- 0
      for(i in 2:nHabitatQuality) {
        bHabitatQuality[i] ~ dnorm(0, (5. * 10)^-2) T(0,)
      }
    
      log_sSiteYear ~ dlnorm(0, (5 * 10)^-2)
      log_sDensity ~ dt(0, (5 * 10)^-2, 4.5)
    
      log(sSiteYear) <- log_sSiteYear
      log(sDensity) <- log_sDensity
    
      for(i in 1:nSite) {
        for(j in 1:nYearFactor) {
          bSiteYear[i,j] ~ dnorm(0, sSiteYear^-2)
        }
      }
    
      for(i in 1:length(Density)) {
        eDensity[i] <- bIntercept + bYear * Year[i] + bHabitatQuality[HabitatQuality[i]] + bSiteYear[Site[i], YearFactor[i]]
        Density[i] ~ dlnorm(eDensity[i], sDensity^-2)
      }
    }

# analyse full nimble notation vectorized embedded nested expression

    model {
      bIntercept ~ dnorm(0, (5) ^ -2)
      bYear ~ dnorm(0, (0.5) ^ -2)
      bHabitatQuality[1] <- 0
      for (i in 2 : nHabitatQuality) {
        bHabitatQuality[i] ~ dnorm(0, (5) ^ -2) T(0, )
      }
      log_sSiteYear ~ dlnorm(0, (5) ^ -2)
      log_sDensity ~ dt(0, (5) ^ -2, 4.5)
      log(sSiteYear) <- log_sSiteYear
      log(sDensity) <- log_sDensity
      for (i in 1 : nSite) {
        for (j in 1 : nYearFactor) {
          bSiteYear[i, j] ~ dnorm(0, (sSiteYear) ^ -2)
        }
      }
      for (i in 1 : length(Density)) {
        eDensity[i] <- bIntercept + bYear * Year[i] + bHabitatQuality[HabitatQuality[i]] + bSiteYear[Site[i], YearFactor[i]]
        Density[i] ~ dlnorm(eDensity[i], (sDensity) ^ -2)
      }
    }

