setwd("~/src/barx-sysid2018")
library("jsonlite")
library("RColorBrewer")
library("HDInterval")
library("R.matlab")
plotColors = brewer.pal(8, "Dark2")
plotColors = c(plotColors, plotColors)

#############################################################################
#############################################################################
# Load data and set up the model

gridLimits <- c(-4, 4)
dataLimits <- c(-5, 5)
savePlotsToFile <- TRUE
result <- read_json("results/example3/example3_eegdata.json.gz", simplifyVector = TRUE)

#############################################################################
#############################################################################
# Compute quantities requried for plotting
# Posterior mean estimate of mixture components and the high posterior
# density intervals for the one-step ahead predictor

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

oneStepPredHPD <- matrix(0, nrow = dim(result$predictiveMean)[2], ncol = 2)
for (i in 1:dim(result$predictiveMean)[2]) {
  res <- hdi(density(result$predictiveMean[, i]), credMass = 0.95, allowSplit = TRUE)
  oneStepPredHPD[i, ] <- c(res[1], res[2])
}

gaussianDensity <- function(x) {dnorm(x, mean(result$outputSignal), sd(result$outputSignal))}

#############################################################################
#############################################################################
# Code for plotting

if (savePlotsToFile) {cairo_pdf("results/example3_eegdata_paper.pdf", height = 8, width = 8)
}
layout(matrix(c(1, 1, 2, 3), 2, 2, byrow = TRUE))
par(mar = c(4, 5, 1, 1))

#############################################################################
## Plot of training and validation data
grid <- seq(1 , length(result$yEstimation))
plot(
  result$yEstimation,
  col = plotColors[1],
  type = "l",
  bty = "n",
  lwd = 1,
  xlab = "time",
  ylab = "observation",
  xlim = c(0, noTrainData + noEvalData + 100),
  ylim = dataLimits
)
polygon(c(grid, rev(grid)),
        c(rep(-6, length(grid)), rev(result$yEstimation)),
        border = NA,
        col = rgb(t(col2rgb(plotColors[1])) / 256, alpha = 0.15))

grid <- seq(noTrainData + 1, noTrainData + noEvalData)
lines(grid,
      result$yValidation,
      col = rgb(t(col2rgb(plotColors[1])) / 256, alpha = 0.5),
      lwd = 1)

lines(grid,
      oneStepPredHPD[, 1],
      col = rgb(t(col2rgb(plotColors[2])) / 256, alpha = 0.5),
      lwd = 1)

lines(grid,
      oneStepPredHPD[, 2],
      col = rgb(t(col2rgb(plotColors[2])) / 256, alpha = 0.5),
      lwd = 1)


#############################################################################
## Plot of validation data together with one-step ahead predictor

grid <- seq(700, 810)
plot(grid + length(result$yEstimation),
     result$yValidation[grid],
     col = plotColors[8],
     type = "p",
     pch = 19,
     cex = 0.5,
     bty = "n",
     xlab = "time",
     ylab = "one-step-ahead predictor",
     xlim = range(grid) + length(result$yEstimation),
     ylim = c(0, 2)
)

polygon(
  c(grid + length(result$yEstimation), rev(grid) + length(result$yEstimation)),
  c(oneStepPredHPD[grid, 1], rev(oneStepPredHPD[grid, 2])),
  border = NA,
  col = rgb(t(col2rgb(plotColors[2])) / 256, alpha = 0.5)
)

lines(grid + length(result$yEstimation), oneStepPredHPD[grid, 1], col = plotColors[2], lwd = 0.5)
lines(grid + length(result$yEstimation), oneStepPredHPD[grid, 2], col = plotColors[2], lwd = 0.5)

#############################################################################
## Plot of the estimate of the noise distribution

mixtureEstimate <- rowSums(estMixComp)
plot(
  result$gridPoints,
  mixtureEstimate,
  col = plotColors[8],
  type = "l",
  bty = "n",
  lwd = 2,
  xlab = "x",
  ylab = "mixture density",
  xlim = gridLimits,
  ylim = c(0, 1.4)
)

lines(result$gridPoints,
      gaussianDensity(result$gridPoints),
      col = plotColors[2],
      lwd = 2)

for (i in 1:noComp) {
  lines(result$gridPoints,
        estMixComp[, i],
        col = plotColors[8],
        lwd = 1,
        lty = "dashed")
  polygon(
    c(result$gridPoints, rev(result$gridPoints)),
    c(rep(0, length(
      result$gridPoints
    )), rev(estMixComp[, i])),
    border = NA,
    col = rgb(t(col2rgb(plotColors[8])) / 256, alpha = 0.15)
  )
}

#############################################################################
# Close plot device

if (savePlotsToFile) {
  dev.off()
}

#############################################################################
#############################################################################
# Compute model fit

predError <- sum((rowMeans(oneStepPredHPD) - result$yValidation) ^ 2)
evalObsVar <- sum((result$yValidation - mean(result$yValidation)) ^ 2)
(modelFitBARX <- 100 * (1 - predError / evalObsVar))