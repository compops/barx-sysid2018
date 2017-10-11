import pystan
import numpy as np
import matplotlib.pylab as plt
from helpers import saveResultsFIRMixture
from helpers import buildPhiMatrix
from helpers import randn_skew_fast
from helpers import generatePRBS

noTrainingData = 3000
noEvaluationData = 1500
noObservations = noTrainingData + noEvaluationData
modelOrder = 3
#inputSignal = generatePRBS(noObservations, maxHold=20)
inputSignal = np.random.normal(size=noObservations)
filterCoefficients = (1.0, -0.71, -0.38, 0.17)

# Generate data
phi = buildPhiMatrix(inputSignal, modelOrder)
outputSignal = np.dot(phi, filterCoefficients)
idx = np.where(np.random.choice(2, noObservations - modelOrder, p=(0.7, 0.3)) == 0)
noise1 = randn_skew_fast(noObservations - modelOrder, -5, 0, 0.5)
noise2 = np.random.normal(6, 0.5, size=noObservations - modelOrder)
noise = noise2
noise[idx] = noise1[idx]
outputSignal += noise

# Build Phi matrix
modelOrderGuess = modelOrder
dataX = buildPhiMatrix(inputSignal, modelOrderGuess)
dataY = outputSignal[(modelOrderGuess - modelOrder):]

trainingDataX = dataX[0:noTrainingData, :]
trainingDataY = dataY[0:noTrainingData]
evaluationDataX = dataX[noTrainingData:noObservations, :]
evaluationDataY = dataY[noTrainingData:noObservations]
print(filterCoefficients)
print(np.linalg.lstsq(trainingDataX, trainingDataY)[0])

# Run Stan
gridPoints = np.arange(-10, 10, 0.05)
noGridPoints = len(gridPoints)
data = {'noTrainingData': noTrainingData,
        'noEvaluationData': noEvaluationData - modelOrderGuess,
        'trainingDataX': trainingDataX,
        'trainingDataY': trainingDataY,
        'evaluationDataX': evaluationDataX,
        'evaluationDataY': evaluationDataY,
        'noComponents': 10,
        'mixtureWeightsHyperPrior': 10.0, 
        'noGridPoints': noGridPoints, 
        'gridPoints': gridPoints,
        'systemOrder': modelOrderGuess,
        'inputSignal': inputSignal,
        'outputSignal': outputSignal
}

sm = pystan.StanModel(file='example3.stan')
fit = sm.sampling(data=data, iter=10000, chains=1)

saveResultsFIRMixture(data, model=fit, name='syntheticData')


