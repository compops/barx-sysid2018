setwd("~/src/barx-sysid2018/r")
library("jsonlite")
library("RColorBrewer")
plotColors = brewer.pal(8, "Dark2")

plotColors = c(plotColors, rep(plotColors[8], 8))
savePlotsToFile <- FALSE

if (savePlotsToFile) {
  cairo_pdf("illustration-gmms.pdf",
            height = 8,
            width = 8)
}
layout(matrix(1:4, 2, 2, byrow = TRUE))
par(mar = c(1, 1, 0, 0))

name <- c("uniform", "mixture", "skewed", "heavytailed")
xLimits <- c(-4, 4,-10, 10,-4, 2,-4, 12)

yLimits <- c(0, 0.5, 0, 0.3, 0, 1, 0, 0.25)

xLimits <- matrix(xLimits,
                  nrow = 4,
                  ncol = 2,
                  byrow = TRUE)
yLimits <- matrix(yLimits,
                  nrow = 4,
                  ncol = 2,
                  byrow = TRUE)

for (k in 1:4) {
  result <-
    read_json(paste(
      paste("../results/illustration_gmm_", name[k], sep = ""),
      ".json",
      sep = ""
    ), simplifyVector = TRUE)
  noBins <- floor(sqrt(result$no_iterations * result$no_chains))
  
  noComp <- dim(result$mixtureMeans)[2]
  estMixComp <-
    matrix(0, nrow = length(result$gridPoints), ncol = noComp)
  
  for (i in 1:length(result$gridPoints)) {
    for (j in 1:noComp) {
      compOnGrid <- dnorm(
        result$gridPoints[i],
        mean = result$mixtureMeans[, j],
        sd = sqrt(result$mixtureVariances[, j])
      )
      estMixComp[i, j] <-
        mean(result$mixtureWeights[, j] * compOnGrid)
    }
  }
  
  
  ##################################################################################################
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
  
  lines(
    density(result$outputSignal, from = xLimits[k, 1], to = xLimits[k, 2]),
    col = plotColors[1],
    bty = "n",
    lwd = 2
  )
  
  rug(result$observations)
  
  lines(result$gridPoints,
        estMixComp[, 1],
        col = plotColors[8],
        lwd = 2)
  polygon(
    c(result$gridPoints, rev(result$gridPoints)),
    c(rep(0, length(
      result$gridPoints
    )), rev(estMixComp[, 1])),
    border = NA,
    col = rgb(t(col2rgb(plotColors[8])) / 256, alpha = 0.15)
  )
  
  for (i in 2:noComponents) {
    lines(result$gridPoints,
          estMixComp[, i],
          col = plotColors[8],
          lwd = 2)
    polygon(
      c(result$gridPoints, rev(result$gridPoints)),
      c(rep(0, length(
        result$gridPoints
      )), rev(estMixComp[, i])),
      border = NA,
      col = rgb(t(col2rgb(plotColors[8])) / 256, alpha = 0.15)
    )
  }
  
  rug(result$observations)
}

if (savePlotsToFile) {
  dev.off()
}
