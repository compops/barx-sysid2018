setwd("~/src/hmc-sysid2018/results-report/example2-mixturemodels")
library("jsonlite")
library("RColorBrewer")
#library("sn")
plotColors = brewer.pal(8, "Dark2");
plotColors = c(plotColors, rep(plotColors[8], 8))

#name <- "uniform"; gridLimits <- c(-4, 4); trueDensity <- function(x) {dunif(x, -2, 2)};
#name <- "mixture"; gridLimits <- c(-10, 10); trueDensity <- function(x) {0.4 * dnorm(x, -5, 1) + 0.2 * dnorm(x, 0, 3) + 0.4 * dnorm(x, 4, 1)};
#name <- "skewed"; gridLimits <- c(-4, 4); trueDensity <- function(x) {dnorm(x) * pnorm(-3 * x) * 2};
name <- "heavytailed"; gridLimits <- c(-4, 10); trueDensity <- function(x) {dt((x - 5)/2, 5) / 2};
savePlotsToFile <- TRUE


traceIterationsToPlot <- seq(1, 1000, 1)
result <- read_json(paste(paste("output_", name, sep=""), ".json", sep=""), simplifyVector = TRUE)
nbins <- floor(sqrt(length(result$sigma0)))

noComponents <- dim(result$mu)[2]
estMixtureComponents <- matrix(0, nrow = length(result$gridPoints), ncol = noComponents)

for (i in 1:length(result$gridPoints)) {
  for (j in 1:noComponents) {
    estMixtureComponents[i, j] <- mean(result$weights[, j] * dnorm(result$gridPoints[i], mean = result$mu[, j], sd = sqrt(result$sigma[, j])))
  }
}

if (savePlotsToFile) {cairo_pdf(paste(paste("example2-", name, sep=""), ".pdf", sep=""),  height = 10, width = 8)}
layout(matrix(c(1, 1, 2, 2, 3, 4), 3, 2, byrow = TRUE))
par(mar = c(4, 5, 1, 1))

##################################################################################################
hist(
  result$observations,
  breaks = nbins,
  main = "",
  freq = F,
  col = rgb(t(col2rgb(plotColors[1])) / 256, alpha = 0.25),
  border = NA,
  xlab = "x",
  ylab = "mixture density",
  ylim = 1.2 *range(c(result$kernelDensityEstimate, result$MCMCDensityEstimate)),
  xlim = gridLimits
)

lines(result$gridPoints, 
     result$kernelDensityEstimate, 
     col = plotColors[1], 
     bty = "n",
     lwd = 2
)

lines(result$gridPoints, 
     result$MCMCDensityEstimate, 
     col = plotColors[2], 
     lwd = 2
)

lines(result$gridPoints, 
      trueDensity(result$gridPoints),
      col = "grey40",
      lwd = 2
      )

rug(result$observations)

##################################################################################################

plot(result$gridPoints, 
     estMixtureComponents[, 1], 
     type = "l", 
     col = plotColors[3], 
     bty = "n",
     lwd = 2,
     xlab = "x",
     ylab = "mixture components",
     ylim = 1.2 *range(estMixtureComponents),
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

rug(result$observations)

##################################################################################################
hist(
  result$e0,
  breaks = nbins,
  main = "",
  freq = F,
  col = rgb(t(col2rgb(plotColors[8])) / 256, alpha = 0.25),
  border = NA,
  xlab = expression(e[0]),
  ylab = "posterior estimate",
  xlim = c(0, 0.8)
)

lines(density(
  result$e0,
  kernel = "e",
  from = 0.0,
  to = 0.8
),
lwd = 2,
col = plotColors[8])

##################################################################################################
hist(
  result$sigma0,
  breaks = nbins,
  main = "",
  freq = F,
  col = rgb(t(col2rgb(plotColors[8])) / 256, alpha = 0.25),
  border = NA,
  xlab = expression(sigma[0]),
  ylab = "posterior estimate",
  xlim = c(0, 4.0)
)

lines(density(
  result$sigma0,
  kernel = "e",
  from = 0,
  to = 4.0
),
lwd = 2,
col = plotColors[8])

if (savePlotsToFile) {dev.off()}
