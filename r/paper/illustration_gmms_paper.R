setwd("~/src/barx-sysid2018")
library("jsonlite")
library("RColorBrewer")

# Set up plot colors
plotColors = brewer.pal(8, "Dark2")
plotColors = c(plotColors, rep(plotColors[8], 8))

# Settings for plotting
savePlotsToFile <- TRUE
name <- c("uniform", "mixture", "skewed", "heavytailed")
xLimits <- c(-3, 3, -10, 10, -8, 2, -6, 14)
yLimits <- c(0, 0.35, 0, 0.2, 0, 0.5, 0, 0.25)

# Setting up plotting
if (savePlotsToFile) {
  cairo_pdf("results/illustration-gmms.pdf",
            height = 8,
            width = 8)
}
layout(matrix(1:4, 2, 2, byrow = TRUE))
par(mar = c(1, 1, 0, 0))
xLimits <- matrix(xLimits,
                  nrow = 4,
                  ncol = 2,
                  byrow = TRUE)
yLimits <- matrix(yLimits,
                  nrow = 4,
                  ncol = 2,
                  byrow = TRUE)

# For each data set
for (k in 1:4) {
  result <-
    read_json(paste(
      paste("results/illustration/illustration_gmm_", name[k], sep = ""),
      ".json.gz",
      sep = ""
    ), simplifyVector = TRUE)
  
  # Set up true density and compute number of bins
  if (k==1){ trueDensity <- function(x) {dunif(x, -2, 2)} }
  if (k==2){ trueDensity <- function(x) {0.4 * dnorm(x, -5, 1) + 0.2 * dnorm(x, 0, 3) + 0.4 * dnorm(x, 4, 1)} }
  if (k==3){ trueDensity <- function(x) {dnorm((x + 1) / 2) * pnorm(-5 * (x + 1) / 2)} }
  if (k==4){ trueDensity <- function(x) {dt((x - 5) / 2, 5) / 2} }
  noBins <- floor(sqrt(result$noIterations * result$noChains))
  
  # Compute the estimate of each mixture component
  noComp <- dim(result$mixtureMeans)[2]
  estMixComp <- matrix(0, nrow = length(result$gridPoints), ncol = noComp)
  for (i in 1:length(result$gridPoints)) {
    for (j in 1:noComp) {
      compOnGrid <- dnorm(
        result$gridPoints[i],
        mean = result$mixtureMeans[, j],
        sd = sqrt(result$mixtureVariances[, j])
      )
      estMixComp[i, j] <- mean(result$mixtureWeights[, j] * compOnGrid)
    }
  }
  
  # Create a histogram of the data
  hist(
    result$outputSignal,
    breaks = noBins,
    main = "",
    freq = F,
    col = rgb(t(col2rgb(plotColors[1])) / 256, alpha = 0.25),
    border = NA,
    xlab = "",
    ylab = "",
    ylim = yLimits[k, ],
    xlim = xLimits[k, ],
    xaxt = "n",
    yaxt = "n"
  )
  rug(result$outputSignal)
  
  # Add kernel density estimate and rug
  lines(
    density(result$outputSignal, from = xLimits[k, 1], to = xLimits[k, 2]),
    col = plotColors[1],
    bty = "n",
    lwd = 2
  )
  
  # Add true underlying density and estimate from the model
  lines(result$gridPoints, colMeans(exp(result$mixtureOnGrid)), col = plotColors[8], lwd = 2)
  lines(result$gridPoints, trueDensity(result$gridPoints), col = plotColors[2], lwd = 2)
  
  # Add the different components of the mixture model
  for (i in 1:noComp) {
    lines(result$gridPoints,
          estMixComp[, i],
          col = plotColors[8],
          lwd = 1.3,
          lty="dashed")
    polygon(
      c(result$gridPoints, rev(result$gridPoints)),
      c(rep(0, length(result$gridPoints
      )), rev(estMixComp[, i])),
      border = NA,
      col = rgb(t(col2rgb(plotColors[8])) / 256, alpha = 0.15)
    )
  }
}

# Close plotting device
if (savePlotsToFile) {
  dev.off()
}
