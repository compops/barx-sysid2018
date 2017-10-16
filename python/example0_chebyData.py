import pystan
import numpy as np
import matplotlib.pylab as plt
from helpers import buildPhiMatrix, saveResultsChebyData
from scipy.io import loadmat

# Get data
data = loadmat("../matlab/chebyData.mat")
coefficientsA = data['a'].flatten()
coefficientsB = data['b'].flatten()
observations = data['dataOut'].flatten()
inputs = data['dataIn'].flatten()
order = (len(coefficientsA)-1, len(coefficientsB))

observations += np.random.normal(scale=0.1, size=len(observations))

noObservations = observations.shape[0]
noEstimationData = int(np.floor(noObservations * 0.25))
noValidationData = int(noObservations - noEstimationData)

estimationObservations = observations[:noEstimationData]
estimationInputs = inputs[:noEstimationData]

validationObservations = observations[noEstimationData:]
validationInputs = inputs[noEstimationData:]

# Build regressor matrices
guessedOrder = (9, 10)
regressorMatrixEstimation = buildPhiMatrix(estimationObservations, guessedOrder, estimationInputs)
yEstimation = estimationObservations[int(np.max(guessedOrder)):]
regressorMatrixValidation = buildPhiMatrix(validationObservations, guessedOrder, validationInputs)
yValidation = validationObservations[int(np.max(guessedOrder)):]

# Run Stan
data = { 'noEstimationData': len(yEstimation), 
         'noValidationData': len(yValidation), 
         'systemOrder': int(np.sum(guessedOrder)),
         'regressorMatrixEstimation': regressorMatrixEstimation, 
         'regressorMatrixValidation': regressorMatrixValidation, 
         'yEstimation': yEstimation,
         'yValidation': yValidation,
         'trueOrder': order,
         'guessedOrder': guessedOrder,
         'coefficientsA': coefficientsA,
         'coefficientsB': coefficientsB    
       }

sm = pystan.StanModel(file='example0_normal.stan')
fit = sm.sampling(data=data, iter=10000, chains=1)
saveResultsChebyData(data, model=fit, name='normal', scaleModelCoefficients = False)

# sm = pystan.StanModel(file='example0_l1.stan')
# fit = sm.sampling(data=data, iter=10000, chains=1)
# saveResultsChebyData(data, model=fit, name='l1')

# sm = pystan.StanModel(file='example0_l2.stan')
# fit = sm.sampling(data=data, iter=10000, chains=1)
# saveResultsChebyData(data, model=fit, name='l2')

# sm = pystan.StanModel(file='example0_horseshoe.stan')
# fit = sm.sampling(data=data, iter=10000, chains=1)
# saveResultsChebyData(data, model=fit, name='horseshoe')
