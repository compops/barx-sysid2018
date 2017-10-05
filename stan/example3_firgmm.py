import pystan
import numpy as np
import matplotlib.pylab as plt
from helpers import saveResultsFIRMixture
from helpers import buildPhiMatrix
from helpers import randn_skew_fast

noTrainingData = 1200
noEvaluationData = 600
noObservations = noTrainingData + noEvaluationData
modelOrder = 5

inputSignal = np.random.normal(loc=0.0, scale=1.0, size=noObservations)
#inputSignal[inputSignal > -1] = 1.0
#inputSignal[inputSignal < -1] = -1.0
filterCoefficients = (1.0, -0.71, -0.38, 0.17, -0.005, -0.001)

# Generate data
phi = buildPhiMatrix(inputSignal, modelOrder)
outputSignal = np.dot(phi, filterCoefficients)
outputSignal += randn_skew_fast(noObservations - modelOrder, -5, -1, 2)

# Build Phi matrix
modelOrderGuess = 10
dataX = buildPhiMatrix(inputSignal, modelOrderGuess)
dataY = outputSignal[(modelOrderGuess - modelOrder):]

trainingDataX = dataX[0:noTrainingData, :]
trainingDataY = dataY[0:noTrainingData]
evaluationDataX = dataX[noTrainingData:noObservations, :]
evaluationDataY = dataY[noTrainingData:noObservations]
print(filterCoefficients)
print(np.linalg.lstsq(trainingDataX, trainingDataY)[0])
rmseFilterCofficientsLS = np.sqrt(np.mean((filterCoefficients-np.linalg.lstsq(trainingDataX, trainingDataY)[0][0:6])**2))

# Run Stan
gridPoints = np.arange(-10, 10, 0.05)
noGridPoints = len(gridPoints)
data = {'noTrainingData': noTrainingData,
        'noEvaluationData': noEvaluationData - 10,
        'trainingDataX': trainingDataX,
        'trainingDataY': trainingDataY,
        'evaluationDataX': evaluationDataX,
        'evaluationDataY': evaluationDataY,
        'noComponents': 5,
        'mixtureWeightsHyperPrior': 5.0, 
        'noGridPoints': noGridPoints, 
        'gridPoints': gridPoints,
        'systemOrder': 10
}

sm = pystan.StanModel(file='example3.stan')
fit = sm.sampling(data=data, iter=10000, chains=1)

saveResultsFIRMixture(data, model=fit, name='syntheticData')
