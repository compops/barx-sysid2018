setwd("~/src/barx-sysid2018")
library("jsonlite")
library("RColorBrewer")
library("HDInterval")
library("R.matlab")

#############################################################################
#############################################################################
# Load data and set up the model
plotColors = brewer.pal(8, "Dark2")
plotColors = c(plotColors, plotColors)

trueDensity <- function(x) {
  0.8 * dnorm(x, 0, 0.5) + 0.2 * dnorm(x, 5, 0.5)
}

gridLimits <- c(-4, 8)
dataLimits <- c(-4, 10)
savePlotsToFile <- TRUE
result <- read_json("results/example2/example2_arx_gmm.json.gz", simplifyVector = TRUE)
result_matlab <- readMat("matlab/example2_arxgmm_workspace.mat")


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

oneStepPredHPD <- matrix(0, nrow = dim(result$predictiveMean)[2], ncol = 4)
for (i in 1:dim(result$predictiveMean)[2]) {
  res <- hdi(density(result$predictiveMean[, i]), credMass = 0.95, allowSplit = TRUE)
  oneStepPredHPD[i, ] <- c(res[1], res[3], res[2], res[4])
}

#############################################################################
#############################################################################
# Code for plotting

if (savePlotsToFile) {cairo_pdf("results/example2_arxgmm_paper.pdf", height = 8, width = 8)}
layout(matrix(c(1, 1, 1, 2, 2, 4, 3, 3, 4), 3, 3, byrow = TRUE))
par(mar = c(4, 5, 1, 1))

#############################################################################
## Plot of validation data together with one-step ahead predictor
grid <- seq(1, 300)
plot(grid,
  result$yValidation[1:300],
  col = plotColors[8],
  type = "p",
  pch = 19,
  cex = 0.5,
  bty = "n",
  xlab = "time",
  ylab = "observation",
  xlim = c(0, 300),
  ylim = dataLimits
)

polygon(
  c(grid, rev(grid)),
  c(oneStepPredHPD[1:300, 1], rev(oneStepPredHPD[1:300, 2])),
  border = NA,
  col = rgb(t(col2rgb(plotColors[2])) / 256, alpha = 0.5)
)

polygon(
  c(grid, rev(grid)),
  c(oneStepPredHPD[1:300, 3], rev(oneStepPredHPD[1:300, 4])),
  border = NA,
  col = rgb(t(col2rgb(plotColors[2])) / 256, alpha = 0.5)
)

lines(grid, oneStepPredHPD[1:300, 1], col = plotColors[2], lwd = 0.5)
lines(grid, oneStepPredHPD[1:300, 2], col = plotColors[2], lwd = 0.5)
lines(grid, oneStepPredHPD[1:300, 3], col = plotColors[2], lwd = 0.5)
lines(grid, oneStepPredHPD[1:300, 4], col = plotColors[2], lwd = 0.5)

lines(grid,
      result_matlab$yhat[-c(1:6)][1:300],
      col = plotColors[3],
      lwd = 1.5
)

abline(v = 244, lty = "dotted")
abline(v = 241, lty = "dotted")

#############################################################################
## Plot the density of the one-step-ahead predictor at two time steps
t <- 244
noBins <- floor(sqrt(dim(result$predictiveMean)[1]))

hist(result$predictiveMean[, t], 
     noBins,
     main = "",
     freq = F,
     col = rgb(t(col2rgb(plotColors[2])) / 256, alpha = 0.25),
     border = NA,
     xlab = expression(hat(y)),
     ylab = "posterior probability",
     ylim = c(0, 2),
     xlim = c(-4, 8)
)

lines(density(result$predictiveMean[, t], from = -4, to = 8), col = plotColors[2], lwd = 2)

points(result_matlab$yhat[-c(1:6)][t], 0.0, pch = 19, col = plotColors[3])
abline(v = result_matlab$yhat[-c(1:6)][t], col = plotColors[3], lwd = 2)

points(result$yValidation[t], 0.0, pch = 19, col = plotColors[1])
abline(v = result$yValidation[t], col = plotColors[1], lwd = 2)

t <- 241
noBins <- floor(sqrt(dim(result$predictiveMean)[1]))

hist(result$predictiveMean[, t], 
     noBins,
     main = "",
     freq = F,
     col = rgb(t(col2rgb(plotColors[2])) / 256, alpha = 0.25),
     border = NA,
     xlab = expression(hat(y)),
     ylab = "posterior probability",
     ylim = c(0, 4),
     xlim = c(-4, 8)
)

lines(density(result$predictiveMean[, t], from = -4, to = 8), col = plotColors[2], lwd = 2)

points(result_matlab$yhat[-c(1:6)][t], 0.0, pch = 19, col = plotColors[3])
abline(v = result_matlab$yhat[-c(1:6)][t], col = plotColors[3], lwd = 2)

points(result$yValidation[t], 0.0, pch = 19, col = plotColors[1])
abline(v = result$yValidation[t], col = plotColors[1], lwd = 2)

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
  ylim = c(0, 0.8)
)

lines(result$gridPoints,
      trueDensity(result$gridPoints),
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
# Close the plot device
if (savePlotsToFile) {
  dev.off()
}
