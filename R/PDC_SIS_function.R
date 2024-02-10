
library(energy)

# PDC_SIS function

PDC_SIS <- function(X, Y, lags = 3, top_n = 10) {
  n <- nrow(X)
  d <- ncol(X)
  
  # Dynamically generate lagged versions of Y based on the specified 'lags'
  laggedYs <- list(Y) # Start with Y itself
  for (lag in 1:lags) {
    laggedYs[[lag + 1]] <- c(rep(NA, lag), Y[1:(length(Y) - lag)])
  }
  
  # Combine all lagged versions of Y for conditioning
  Y_conditioning <- do.call(cbind, laggedYs)
  Y_conditioning_df <- as.data.frame(Y_conditioning)
  names(Y_conditioning_df) <- c("Y", paste0("Lag", 1:lags))
  
  # Initialize a vector for storing PDC values
  pdc <- numeric(d)
  for (j in 1:d) {
    # Adjust for the fact that there's no need to loop over lags for X here
    pdc[j] <- pdcor(Y, X[,j], Y_conditioning)
  }
  
  # Determine top predictors based on PDC values
  indices <- order(abs(pdc), decreasing = TRUE)[1:min(top_n, length(pdc))]
  
  # Return Y_conditioning_df as part of the results for inspection
  return(list(indices = indices, screened_set = X[, indices], Y_conditioning_df = Y_conditioning_df))
}
