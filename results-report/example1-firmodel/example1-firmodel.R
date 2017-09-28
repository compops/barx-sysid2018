setwd("~/src/hmc-sysid2018/results-report/example1-firmodel")
library("jsonlite")
library("RColorBrewer")
plotColors = brewer.pal(8, "Dark2")

name <- "firOrderFiveGuessedTen"
trueParameters <- c(-0.71, -0.38, 0.17, -0.005, -0.001)
savePlotsToFile <- TRUE

timeIntervalToPlot <- seq(1, 500, 1)
result <- read_json(paste(paste("output_", name, sep=""), ".json", sep=""), simplifyVector = TRUE)
nbins <- floor(sqrt(length(result$sigma0)))

if (savePlotsToFile) {cairo_pdf(paste(paste("example1-", name, sep=""), ".pdf", sep=""),  height = 10, width = 8)}
layout(matrix(c(1, 2, 3, 3, 4, 5), 3, 2, byrow = TRUE))
par(mar = c(4, 5, 1, 1))

##################################################################################################
plot(traceIterationsToPlot[timeIntervalToPlot], 
     result$observations[timeIntervalToPlot], 
     type = "l", 
     col = plotColors[1], 
     bty = "n",
     xlab = "time",
     ylab = "output",
     ylim = c(-8, 4)
)

polygon(c(timeIntervalToPlot, rev(timeIntervalToPlot)),
        c(rep(-8, length(timeIntervalToPlot)), rev(result$observations[timeIntervalToPlot])),
        border = NA,
        col = rgb(t(col2rgb(plotColors[1])) / 256, alpha = 0.15)
)


##################################################################################################
plot(traceIterationsToPlot[timeIntervalToPlot], 
     result$inputs[timeIntervalToPlot], 
     type = "l", 
     col = plotColors[2], 
     bty = "n",
     xlab = "time",
     ylab = "input",
     ylim = c(-4, 4)
)

polygon(c(timeIntervalToPlot, rev(timeIntervalToPlot)),
        c(rep(-8, length(timeIntervalToPlot)), rev(result$inputs[timeIntervalToPlot])),
        border = NA,
        col = rgb(t(col2rgb(plotColors[2])) / 256, alpha = 0.15)
)


##################################################################################################
hist(
  result$b[, 1],
  breaks = nbins,
  main = "",
  freq = F,
  col = rgb(t(col2rgb(plotColors[3])) / 256, alpha = 0.25),
  border = NA,
  xlab = expression(b),
  ylab = "posterior probability",
  xlim = c(-1 , 1)
)

lines(density(
  result$b[, 1],
  kernel = "e"
),
lwd = 2,
col = plotColors[3])

for (i in 2:10) {
  hist(
    result$b[, i],
    breaks = nbins,
    freq = F,
    col = rgb(t(col2rgb(plotColors[2 + i])) / 256, alpha = 0.25),
    border = NA,
    add = TRUE
  )
  
  lines(density(
    result$b[, i],
    kernel = "e"
  ),
  lwd = 2,
  col = plotColors[2 + i])  
}

for (i in 1:length(trueParameters)) {abline(v = trueParameters[i], lty = 'dotted')}


##################################################################################################
hist(
  result$sigma,
  breaks = nbins,
  main = "",
  freq = F,
  col = rgb(t(col2rgb(plotColors[8])) / 256, alpha = 0.25),
  border = NA,
  xlab = expression(sigma),
  ylab = "posterior estimate",
  xlim = c(0.9, 1.1)
)

lines(density(
  result$sigma,
  kernel = "e",
  from = 0.9,
  to = 1.1
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
  xlim = c(0, 1)
)

lines(density(
  result$sigma0,
  kernel = "e",
  from = 0,
  to = 1
),
lwd = 2,
col = plotColors[8])

if (savePlotsToFile) {dev.off()}
