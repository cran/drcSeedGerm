# Sandwich estimator
# (fully iterated jackknife - grouped version) #
# v.1 - 29/11/17
# It is only ok for models with external covariates
# Computer intensive and slow!
jackGroupSE <- function(obj, data, units) {
  # if(inherits(mod) != "drcte") stop("This function only works for time-to-event models fitted with 'drmte'")

  cluster <- factor(units)
  mod <- obj
  estim <- coef(mod)
  esN <- summary(mod)$coefficients[,2]
  #numGroups <- length(levels(cluster))
  numParms <- length(estim)
  estim2 <- data.frame()
  cont <- 0
  for(i in 1:length(levels(cluster))){
    sel <- levels(cluster)[i]
    datS <- data[cluster!=sel,] #select data
    mod2 <- try(update(mod, data=datS, start=estim), silent=T) #refit model
    if(inherits(mod2, "try-error")) next
    estim2 <- rbind(estim2, coef(mod2))
    message(paste("Deleting group", i, "and refitting", sep=" "))
    cont <- cont + 1
    # print(cont)
  }
  names(estim2) <- names(estim)
  numGroups <- cont
  b <- sqrt( (numGroups - numParms)/numGroups * apply(((as.matrix(estim2) - matrix(rep(estim,numGroups),numGroups,numParms, byrow=T))^2), 2, sum) )
  cbind("Estimate"=estim, "SE" = esN, "Robust SE" = b)
}

