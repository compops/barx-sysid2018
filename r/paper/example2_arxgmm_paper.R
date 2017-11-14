setwd("~/src/barx-sysid2018/r")
library("jsonlite")
library("RColorBrewer")
library("HDInterval")
library("R.matlab")
plotColors = brewer.pal(8, "Dark2")
plotColors = c(plotColors, plotColors)

################################################################################
# Load data and set up the model
################################################################################
name <- "example2_arxgmm"
trueDensity <- function(x) {
  0.8 * dnorm(x, 0, 0.5) + 0.2 * dnorm(x, 3, 0.5)
}

gridLimits <- c(-6, 6)
dataLimits <- c(-2, 4)
savePlotsToFile <- TRUE
result <- read_json(paste("../results", paste(name, ".json", sep = ""), sep=""), simplifyVector = TRUE)
result_matlab <- readMat("../results/example2_arxgmm.mat")

################################################################################
# Compute quantities requried for plotting
# Posterior mean estimate of mixture components and the high posterior
# density intervals for the one-step ahead predictor
################################################################################
noBins <- floor(sqrt(result$noIterations))
noTrainData <- dim(result$regressorMatrixEstimation)[1]
noEvalData <- dim(result$regressorMatrixValidation)[1]
systemOrder <- sum(result$guessedOrder)

noComp <- dim(result$mixtureMeans)[2]
estMixComp <- matrix(0, nrow = length(result$gridPoints), ncol = noComp)

for (i in 1:length(result$gridPoints)) {
  for (j in 1:noComp) {
    compOnGrid <- dnorm(result$gridPoints[i],
                        mean = result$mixtureMeans[, j],
                        sd = sqrt(result$mixtureVariances[, j]))
    estMixComp[i, j] <- mean(result$mixtureWeights[, j] * compOnGrid)
  }
}

oneStepPredHPD <- matrix(0, nrow = dim(result$predictiveMean)[2], ncol = 4)
for (i in 1:dim(result$predictiveMean)[2]) {
  res <- hdi(density(result$predictiveMean[, i]), credMass = 0.95, allowSplit = TRUE)
  oneStepPredHPD[i, ] <- c(res[1], res[3], res[2], res[4])
}

##################################################################################################
# Code for plotting

if (savePlotsToFile) {cairo_pdf("example2_arxgmm_paper.pdf", height = 8, width = 8)
}
layout(matrix(c(1, 1, 2, 3), 2, 2, byrow = TRUE))
par(mar = c(4, 5, 1, 1))

## Plot of validation data together with one-step ahead predictor
grid <- seq(1, length(result$yValidation))

plot(grid,
  result$yValidation,
  col = plotColors[8],
  type = "p",
  pch = 19,
  cex = 0.5,
  bty = "n",
  xlab = "time",
  ylab = "observation",
  xlim = c(0, 350),
  ylim = dataLimits
)

polygon(
  c(grid, rev(grid)),
  c(oneStepPredHPD[, 1], rev(oneStepPredHPD[, 2])),
  border = NA,
  col = rgb(t(col2rgb(plotColors[2])) / 256, alpha = 0.5)
)

polygon(
  c(grid, rev(grid)),
  c(oneStepPredHPD[, 3], rev(oneStepPredHPD[, 4])),
  border = NA,
  col = rgb(t(col2rgb(plotColors[2])) / 256, alpha = 0.5)
)

lines(grid, oneStepPredHPD[, 1], col=plotColors[2])
lines(grid, oneStepPredHPD[, 2], col=plotColors[2])

lines(grid, oneStepPredHPD[, 3], col=plotColors[2])
lines(grid, oneStepPredHPD[, 4], col=plotColors[2])

lines(grid,
      result_matlab$pre[-c(1:6)],
      col = plotColors[3],
      lwd = 1
)

# Plot of the estimate of the noise distribution
mixtureEstimate <- rowSums(estMixComp)
plot(
  result$gridPoints,
  mixtureEstimate,
  col = plotColors[2],
  type = "l",
  bty = "n",
  lwd = 2,
  xlab = "x",
  ylab = "mixture density",
  xlim = gridLimits,
  ylim = c(0, 1.2 * max(c(
    trueDensity(result$gridPoints), mixtureEstimate
  )))
)
polygon(
  c(result$gridPoints, rev(result$gridPoints)),
  c(rep(0, length(result$gridPoints)), rev(mixtureEstimate)),
  border = NA,
  col = rgb(t(col2rgb(plotColors[2])) / 256, alpha = 0.15)
)

lines(result$gridPoints,
      trueDensity(result$gridPoints),
      col = "grey40",
      lwd = 2)

# Plot of the components and makes up the noise distribution estimate
plot(
  result$gridPoints,
  estMixComp[, 1],
  type = "l",
  col = plotColors[3],
  bty = "n",
  lwd = 2,
  xlab = "x",
  ylab = "mixture components",
  ylim = 1.2 * range(estMixComp),
  xlim = gridLimits
)
polygon(
  c(result$gridPoints, rev(result$gridPoints)),
  c(rep(0, length(result$gridPoints)), rev(estMixComp[, 1])),
  border = NA,
  col = rgb(t(col2rgb(plotColors[3])) / 256, alpha = 0.15)
)

for (i in 2:noComp) {
  lines(result$gridPoints,
        estMixComp[, i],
        col = plotColors[2 + i],
        lwd = 2)
  polygon(
    c(result$gridPoints, rev(result$gridPoints)),
    c(rep(0, length(
      result$gridPoints
    )), rev(estMixComp[, i])),
    border = NA,
    col = rgb(t(col2rgb(plotColors[2 + i])) / 256, alpha = 0.15)
  )
}

if (savePlotsToFile) {
  dev.off()
}