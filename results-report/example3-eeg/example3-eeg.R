setwd("~/src/hmc-sysid2018/results-report/example3-eeg")
library("jsonlite")
library("RColorBrewer")
#library("sn")
plotColors = brewer.pal(8, "Dark2");
plotColors = c(plotColors, plotColors)


name <- "arxGaussianMixtureEEGData"; gridLimits <- c(-10, 10);
savePlotsToFile <- TRUE

traceIterationsToPlot <- seq(1, 1000, 1)
result <- read_json(paste(paste("output_", name, sep=""), ".json", sep=""), simplifyVector = TRUE)
nbins <- floor(sqrt(length(result$sigma0)))

noComponents <- dim(result$sigma)[2]
estMixtureComponents <- matrix(0, nrow = length(result$gridPoints), ncol = noComponents)

for (i in 1:length(result$gridPoints)) {
  for (j in 1:noComponents) {
    estMixtureComponents[i, j] <- mean(result$weights[, j] * dnorm(result$gridPoints[i], mean = result$mu[, j], sd = sqrt(result$sigma[, j])))
  }
}

if (savePlotsToFile) {cairo_pdf(paste(paste("example3-", name, sep=""), ".pdf", sep=""),  height = 10, width = 8)}
layout(matrix(c(1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 5, 6), 4, 3, byrow = TRUE))
par(mar = c(4, 5, 1, 1))

##################################################################################################

plot(result$gridPoints, 
     col = plotColors[2], 
     result$MCMCDensityEstimate, 
     type = "l",
     bty = "n",
     lwd = 2,
     xlab = "x",
     ylab = "mixture density",
     #ylim = 1.2 *range(c(result$kernelDensityEstimate, result$MCMCDensityEstimate)),
     xlim = gridLimits     
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
  result$g[, 1],
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
  result$g[, 1],
  kernel = "e"
),
lwd = 2,
col = plotColors[3])

for (i in 2:10) {
  hist(
    result$g[, i],
    breaks = nbins,
    freq = F,
    col = rgb(t(col2rgb(plotColors[2 + i])) / 256, alpha = 0.25),
    border = NA,
    add = TRUE
  )
  
  lines(density(
    result$g[, i],
    kernel = "e"
  ),
  lwd = 2,
  col = plotColors[2 + i])  
}


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
  xlim = c(0, 0.5)
)

lines(density(
  result$e0,
  kernel = "e",
  from = 0,
  to = 0.5
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
  xlim = c(0, 1.2)
)

lines(density(
  result$sigma0,
  kernel = "e",
  from = 0,
  to = 1.2
),
lwd = 2,
col = plotColors[8])

##################################################################################################
hist(
  result$sigmamu,
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
  result$sigmamu,
  kernel = "e",
  from = 0,
  to = 5
),
lwd = 2,
col = plotColors[8])


if (savePlotsToFile) {dev.off()}
