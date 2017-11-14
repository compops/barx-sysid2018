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
name <- ""
trueDensity <- function(x) {
  dnorm(x, 0, 0.5)
}

gridLimits <- c(-6, 6)
dataLimits <- c(-2, 2)
savePlotsToFile <- TRUE
result <- read_json("../results/example1/example1_arx.json.gz", simplifyVector = TRUE)
result_matlab <- readMat("../matlab/example1_arx_workspace.mat")

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
  oneStepPredHPD[i, ] <- c(res[1], res[2])
}

##################################################################################################
# Code for plotting

if (savePlotsToFile) {cairo_pdf("../results/example1_arx_paper.pdf", height = 8, width = 8)
}
layout(matrix(c(1, 1, 1, 2, 2, 2, 3, 4, 5), 3, 3, byrow = TRUE))
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

lines(grid, oneStepPredHPD[, 1], col=plotColors[2])
lines(grid, oneStepPredHPD[, 2], col=plotColors[2])

lines(grid,
      result_matlab$pre[-c(1:6)],
      col = plotColors[3],
      lwd = 1
)

# Plot of the the posterior estimate of the filter/model coefficients
hist(
  result$modelCoefficients[, 1],
  breaks = noBins,
  main = "",
  freq = F,
  col = rgb(t(col2rgb(plotColors[3])) / 256, alpha = 0.25),
  border = NA,
  xlab = expression(g),
  ylab = "posterior probability",
  xlim = c(-0.6, 0.6),
  ylim = c(0, 20)
)

lines(density(result$modelCoefficients[, 1], kernel = "e"),
      lwd = 2,
      col = plotColors[3])

for (i in 2:systemOrder) {
  hist(
    result$modelCoefficients[, i],
    breaks = noBins,
    freq = F,
    col = rgb(t(col2rgb(plotColors[2 + i])) / 256, alpha = 0.25),
    border = NA,
    add = TRUE
  )

  lines(density(result$modelCoefficients[, i],
                kernel = "e"),
        lwd = 2,
        col = plotColors[2 + i])
}

# Plot of the posterior estimate of priors
hist(
  result$modelCoefficientsPrior,
  breaks = noBins,
  main = "",
  freq = F,
  col = rgb(t(col2rgb(plotColors[8])) / 256, alpha = 0.25),
  border = NA,
  xlab = "modelCoefficientsPrior",
  ylab = "posterior estimate",
  xlim = c(0.2, 1)
)

lines(
  density(
    result$modelCoefficientsPrior,
    kernel = "e",
    from = 0.2,
    to = 1
  ),
  lwd = 2,
  col = plotColors[8]
)

# Plot of the posterior estimate of priors
hist(
  result$mixtureMeansPrior,
  breaks = noBins,
  main = "",
  freq = F,
  col = rgb(t(col2rgb(plotColors[8])) / 256, alpha = 0.25),
  border = NA,
  xlab = "mixtureMeansPrior",
  ylab = "posterior estimate",
  xlim = c(-1, 2)
)

lines(
  density(
    result$mixtureMeansPrior,
    kernel = "e",
    from = -1,
    to = 2
  ),
  lwd = 2,
  col = plotColors[8]
)

# Plot of the posterior estimate of priors
hist(
  result$mixtureWeightsPrior,
  breaks = noBins,
  main = "",
  freq = F,
  col = rgb(t(col2rgb(plotColors[8])) / 256, alpha = 0.25),
  border = NA,
  xlab = "mixtureWeightsPrior",
  ylab = "posterior estimate",
  xlim = c(0, 0.4)
)

lines(
  density(
    result$mixtureWeightsPrior,
    kernel = "e",
    from = 0,
    to = 0.4
  ),
  lwd = 2,
  col = plotColors[8]
)

if (savePlotsToFile) {
  dev.off()
}

predError <- sum((rowMeans(oneStepPredHPD) - result$yValidation) ^ 2)
evalObsVar <- sum((result$yValidation - mean(result$yValidation)) ^ 2)
(modelFitBARX <- 100 * (1 - predError / evalObsVar))

predError <- sum((result_matlab$pre[-c(1:6)]- result$yValidation) ^ 2)
evalObsVar <- sum((result$yValidation - mean(result$yValidation)) ^ 2)
(modelFitARX <- 100 * (1 - predError / evalObsVar))