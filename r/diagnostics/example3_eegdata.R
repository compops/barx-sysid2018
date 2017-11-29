setwd("~/src/barx-sysid2018")
library("jsonlite")
library("RColorBrewer")
library("HDInterval")
library("R.matlab")
plotColors = brewer.pal(8, "Dark2")
plotColors = c(plotColors, plotColors)

################################################################################
# Load data and set up the model
################################################################################
name <- "example3_eegdata"
trueDensity <- function(x) {
  0.8 * dnorm(x, 0, 0.5) + 0.2 * dnorm(x, 3, 0.5)
}

gridLimits <- c(-2, 2)
dataLimits <- c(-4, 2)
savePlotsToFile <- FALSE
result <- read_json("results/example3/example3_eegdata.json.gz", simplifyVector = TRUE)

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

oneStepPredHPD <- matrix(0, nrow = dim(result$predictiveMean)[2], ncol = 2)
for (i in 1:dim(result$predictiveMean)[2]) {
  res <- hdi(density(result$predictiveMean[, i]), credMass = 0.95, allowSplit = TRUE)
  oneStepPredHPD[i, ] <- c(res[1], res[2])
}


##################################################################################################
# Code for plotting

if (savePlotsToFile) {
  cairo_pdf(paste(name, ".pdf", sep = ""), height = 10, width = 8)
}
layout(matrix(c(1, 1, 1, 2, 2, 2, 3, 3, 4, 5, 5, 5, 6, 7, 8), 5, 3, byrow = TRUE))
par(mar = c(4, 5, 1, 1))

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

## Plot of validation data together with one-step ahead predictor
plot(grid,
  result$yValidation,
  col = plotColors[1],
  type = "p",
  pch = 19,
  cex = 0.5,
  bty = "n",
  xlab = "time",
  ylab = "observation",
  xlim = c(0, noEvalData),
  ylim = dataLimits
)

grid <- seq(1, length(result$yValidation))
polygon(
  c(grid, rev(grid)),
  c(oneStepPredHPD[, 1], rev(oneStepPredHPD[, 2])),
  border = NA,
  col = rgb(t(col2rgb(plotColors[2])) / 256, alpha = 0.5)
)

lines(grid, oneStepPredHPD[, 1], col=plotColors[2])
lines(grid, oneStepPredHPD[, 2], col=plotColors[2])

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


matrix(c(apply(result$modelCoefficients, 2, mean) + 1.96* apply(result$modelCoefficients, 2, sd),
  apply(result$modelCoefficients, 2, mean) + 1.96* apply(result$modelCoefficients, 2, sd)), nrow=2, ncol=10)