setwd("~/src/hmc-sysid2018/results-report/example3-eeg")
library("jsonlite")
library("RColorBrewer")

plotColors = brewer.pal(8, "Dark2");
plotColors = c(plotColors, plotColors)

name <- "arxGaussianMixtureEEGData1"
gridLimits <- c(-10, 10)
savePlotsToFile <- FALSE

result <- read_json(paste(paste("output_", name, sep=""), ".json", sep=""), simplifyVector = TRUE)
nbins <- floor(sqrt(length(result$mixtureWeightsPrior)))
noTrainingData <- length(result$trainingData)
noEvaluationData <- length(result$evaluationData)
maxLag <- dim(result$filterCoefficient)[2]

noComponents <- dim(result$mixtureVariance)[2]
estMixtureComponents <- matrix(0, nrow = length(result$gridPoints), ncol = noComponents)

for (i in 1:length(result$gridPoints)) {
  for (j in 1:noComponents) {
    estMixtureComponents[i, j] <- mean(result$mixtureWeights[, j] * dnorm(result$gridPoints[i], mean = result$mixtureMean[, j], sd = sqrt(result$mixtureVariance[, j])))
  }
}

if (savePlotsToFile) {cairo_pdf(paste(paste("example3-", name, sep=""), ".pdf", sep=""),  height = 10, width = 8)}
layout(matrix(c(1, 1, 1, 2, 3, 3, 4, 4, 4, 5, 6, 7), 4, 3, byrow = TRUE))
par(mar = c(4, 5, 1, 1))

##################################################################################################

grid <- seq(1 , length(result$trainingData))
plot(result$trainingData, 
     col = plotColors[1], 
     type = "l",
     bty = "n",
     lwd = 1,
     xlab = "time",
     ylab = "observation",
     xlim = c(0, noTrainingData + noEvaluationData),
     ylim = c(4400, 5400)
)
polygon(c(grid, rev(grid)),
        c(rep(-6, length(grid)), rev(result$trainingData)),
        border = NA,
        col = rgb(t(col2rgb(plotColors[1])) / 256, alpha = 0.15)
)
grid <- seq(length(result$trainingData) + 1, length(result$trainingData) + length(result$evaluationData))
lines(grid,
     result$evaluationData,
     col =rgb(t(col2rgb(plotColors[1])) / 256, alpha = 0.5),
     lwd = 1
)
grid <- seq(noTrainingData + maxLag, noTrainingData + noEvaluationData - 1)
lines(grid,
      result$predictiveMean,
      col = plotColors[2],
      lwd = 1
)
confidenceIntervalUpper <- result$predictiveMean + 1.96 * sqrt(result$predictiveMeanVariance)
confidenceIntervalLower <- result$predictiveMean - 1.96 * sqrt(result$predictiveMeanVariance)
polygon(c(grid, rev(grid)),
        c(confidenceIntervalLower, rev(confidenceIntervalUpper)),
        border = NA,
        col = rgb(t(col2rgb(plotColors[2])) / 256, alpha = 0.15)
)


##################################################################################################

plot(result$gridPoints, 
     result$MCMCDensityEstimate, 
     col = plotColors[2],      
     type = "l",
     bty = "n",
     lwd = 2,
     xlab = "x",
     ylab = "mixture density",
     xlim = gridLimits
)
polygon(c(result$gridPoints, rev(result$gridPoints)),
        c(rep(0, length(result$gridPoints)), rev(result$MCMCDensityEstimate)),
        border = NA,
        col = rgb(t(col2rgb(plotColors[2])) / 256, alpha = 0.15)
)

##################################################################################################

plot(result$gridPoints, 
     estMixtureComponents[, 1], 
     type = "l", 
     col = plotColors[3], 
     bty = "n",
     lwd = 2,
     xlab = "x",
     ylab = "mixture components",
     ylim = 1.2 * range(estMixtureComponents),
     xlim = gridLimits
)
polygon(c(result$gridPoints, rev(result$gridPoints)),
        c(rep(0, length(result$gridPoints)), rev(estMixtureComponents[, 1])),
        border = NA,
        col = rgb(t(col2rgb(plotColors[3])) / 256, alpha = 0.15)
)

for (i in 2:noComponents) {
  lines(result$gridPoints, 
       estMixtureComponents[, i], 
       col = plotColors[2 + i], 
       lwd = 2
  )
  polygon(c(result$gridPoints, rev(result$gridPoints)),
          c(rep(0, length(result$gridPoints)), rev(estMixtureComponents[, i])),
          border = NA,
          col = rgb(t(col2rgb(plotColors[2 + i])) / 256, alpha = 0.15)
  )
}

##################################################################################################
hist(
  result$filterCoefficient[, 1],
  breaks = nbins,
  main = "",
  freq = F,
  col = rgb(t(col2rgb(plotColors[3])) / 256, alpha = 0.25),
  border = NA,
  xlab = expression(g),
  ylab = "posterior probability",
  xlim = c(-1 , 1),
  ylim = c(0, 20)
)

lines(density(
  result$filterCoefficient[, 1],
  kernel = "e"
),
lwd = 2,
col = plotColors[3])

for (i in 2:10) {
  hist(
    result$filterCoefficient[, i],
    breaks = nbins,
    freq = F,
    col = rgb(t(col2rgb(plotColors[2 + i])) / 256, alpha = 0.25),
    border = NA,
    add = TRUE
  )
  
  lines(density(
    result$filterCoefficient[, i],
    kernel = "e"
  ),
  lwd = 2,
  col = plotColors[2 + i])  
}


##################################################################################################
hist(
  result$mixtureWeightsPrior,
  breaks = nbins,
  main = "",
  freq = F,
  col = rgb(t(col2rgb(plotColors[8])) / 256, alpha = 0.25),
  border = NA,
  xlab = expression(e[0]),
  ylab = "posterior estimate",
  xlim = c(0, 0.5)
)

lines(density(
  result$mixtureWeightsPrior,
  kernel = "e",
  from = 0,
  to = 0.5
),
lwd = 2,
col = plotColors[8])

##################################################################################################
hist(
  result$mixtureMeanPrior,
  breaks = nbins,
  main = "",
  freq = F,
  col = rgb(t(col2rgb(plotColors[8])) / 256, alpha = 0.25),
  border = NA,
  xlab = expression(sigma[mu]),
  ylab = "posterior estimate",
  xlim = c(0, 5)
)

lines(density(
  result$mixtureMeanPrior,
  kernel = "e",
  from = 0,
  to = 5
),
lwd = 2,
col = plotColors[8])

##################################################################################################
hist(
  result$filterCoefficientPrior,
  breaks = nbins,
  main = "",
  freq = F,
  col = rgb(t(col2rgb(plotColors[8])) / 256, alpha = 0.25),
  border = NA,
  xlab = expression(sigma[0]),
  ylab = "posterior estimate",
  xlim = c(0, 1.2)
)

lines(density(
  result$filterCoefficientPrior,
  kernel = "e",
  from = 0,
  to = 1.2
),
lwd = 2,
col = plotColors[8])



if (savePlotsToFile) {dev.off()}

squaredPredictionError = sum((result$predictiveMean - result$evaluationData[-(1:maxLag)])^2)
squaredData = sum((result$evaluationData[-(1:maxLag)] - mean(result$evaluationData[-(1:maxLag)]))^2)
modelFit = 100 * (1.0 - squaredPredictionError / squaredData)
rmse = sqrt(mean((result$predictiveMean - result$evaluationData[-(1:maxLag)])^2))
