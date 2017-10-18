import pystan
import numpy as np
import matplotlib.pylab as plt
from initialisation import initialiseARXlocationMixture
from helpers import buildPhiMatrix
from scipy.io import loadmat

# Get data
data = loadmat("../data/example1-arxgmm.mat")
coefficientsA = data['a'].flatten()
coefficientsB = data['b'].flatten()
observations = data['dataOutNoisy'].flatten()
inputs = data['dataIn'].flatten()
order = (len(coefficientsA) - 1, len(coefficientsB))

noObservations = observations.shape[0]
noEstimationData = int(np.floor(noObservations * 0.67))
noValidationData = int(noObservations - noEstimationData)

estimationObservations = observations[:noEstimationData]
estimationInputs = inputs[:noEstimationData]

validationObservations = observations[noEstimationData:]
validationInputs = inputs[noEstimationData:]

# Build regressor matrices
guessedOrder = (4, 5)
regressorMatrixEstimation = buildPhiMatrix(estimationObservations, guessedOrder, estimationInputs)
yEstimation = estimationObservations[int(np.max(guessedOrder)):]
regressorMatrixValidation = buildPhiMatrix(validationObservations, guessedOrder, validationInputs)
yValidation = validationObservations[int(np.max(guessedOrder)):]

# Run Stan
gridPoints = np.arange(-10, 30, 0.1)
noGridPoints = len(gridPoints)

data = {'noEstimationData': len(yEstimation), 
        'noValidationData': len(yValidation), 
        'systemOrder': int(np.sum(guessedOrder)),

        'regressorMatrixEstimation': regressorMatrixEstimation, 
        'regressorMatrixValidation': regressorMatrixValidation, 
        'yEstimation': yEstimation,
        'yValidation': yValidation,

        'noComponents': 5,
        'mixtureWeightsHyperPrior': 10.0, 
        'noGridPoints': noGridPoints, 
        'gridPoints': gridPoints,  

        'trueOrder': order,
        'guessedOrder': guessedOrder,
        'coefficientsA': coefficientsA,
        'coefficientsB': coefficientsB,
        'observations': observations,
        'inputs': inputs,

        'noIterations': 10000,
        'noChains': 1        
}

sm = pystan.StanModel(file='example1_arx_locationmixture.stan')
fit = sm.sampling(data=data, iter=data['noIterations'], chains=data['noChains'], init=initialiseARXlocationMixture)

model=fit
name='example1_arx_locationmixture'

import json
results = {}
results.update({'name': name})
results.update({'noIterations': data['noIterations']})
results.update({'noChains': data['noChains']})

results.update({'modelCoefficients': model.extract("modelCoefficients")['modelCoefficients'].tolist()})
results.update({'modelCoefficientsPrior': model.extract("modelCoefficientsPrior")['modelCoefficientsPrior'].tolist()})
results.update({'observationNoiseVariance': model.extract("observationNoiseVariance")['observationNoiseVariance'].tolist()})

results.update({'mixtureWeights': model.extract("mixtureWeights")['mixtureWeights'].tolist()})
results.update({'mixtureWeightsPrior': model.extract("mixtureWeightsPrior")['mixtureWeightsPrior'].tolist()})
results.update({'mixtureMeans': model.extract("mixtureMeans")['mixtureMeans'].tolist()})
results.update({'mixtureMeansPrior': model.extract("mixtureMeansPrior")['mixtureMeansPrior'].tolist()})

results.update({'predictiveMean': model.extract("predictiveMean")['predictiveMean'].tolist()})
results.update({'predictiveVariance': model.extract("predictiveVariance")['predictiveVariance'].tolist()})

results.update({'yValidation': data['yValidation'].tolist()})
results.update({'yEstimation': data['yEstimation'].tolist()})
results.update({'regressorMatrixEstimation': data['regressorMatrixEstimation'].tolist()})
results.update({'regressorMatrixValidation': data['regressorMatrixValidation'].tolist()})    
results.update({'inputSignal': data['inputs'].tolist()})
results.update({'outputSignal': data['observations'].tolist()})
results.update({'trueOrder': np.array(data['trueOrder']).tolist()})    
results.update({'guessedOrder': np.array(data['guessedOrder']).tolist()})        
results.update({'coefficientsA': data['coefficientsA'].tolist()})
results.update({'coefficientsB': data['coefficientsB'].tolist()})
results.update({'gridPoints': data['gridPoints'].tolist()})

with open(name + '.json', 'w') as f:
        json.dump(results, f, ensure_ascii=False)        



