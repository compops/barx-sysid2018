import pystan
import numpy as np
import matplotlib.pylab as plt
from helpers import buildPhiMatrix
from initialisation import initialiseARXModelEEGData
from scipy.io import loadmat

# Get data
data = loadmat("../data/eeg.mat")
observations = data['y'].flatten()[0::4]
observations = (observations - np.mean(observations)) / np.sqrt(np.var(observations))

noObservations = observations.shape[0]
noEstimationData = 2000
noValidationData = int(noObservations - noEstimationData)

estimationObservations = observations[:noEstimationData]
validationObservations = observations[noEstimationData:]

# Build regressor matrices
guessedOrder = 10
regressorMatrixEstimation = buildPhiMatrix(estimationObservations, guessedOrder)
regressorMatrixEstimation = regressorMatrixEstimation[:, 1:]
yEstimation = estimationObservations[int(np.max(guessedOrder)):]
regressorMatrixValidation = buildPhiMatrix(validationObservations, guessedOrder)
regressorMatrixValidation = regressorMatrixValidation[:, 1:]
yValidation = validationObservations[int(np.max(guessedOrder)):]

# Run Stan
gridPoints = np.arange(-2, 2, 0.01)
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

        'guessedOrder': guessedOrder,
        'observations': observations,

        'noIterations': 10000,
        'noChains': 1        
}

sm = pystan.StanModel(file='example2_eegdata.stan')
fit = sm.sampling(data=data, iter=data['noIterations'], chains=data['noChains'], init=initialiseARXModelEEGData)

model = fit
name = 'example2_eegdata'

import json
results = {}
results.update({'name': name})
results.update({'noIterations': data['noIterations']})
results.update({'noChains': data['noChains']})

results.update({'modelCoefficients': model.extract("modelCoefficients")['modelCoefficients'].tolist()})
results.update({'modelCoefficientsPrior': model.extract("modelCoefficientsPrior")['modelCoefficientsPrior'].tolist()})

results.update({'mixtureWeights': model.extract("mixtureWeights")['mixtureWeights'].tolist()})
results.update({'mixtureWeightsPrior': model.extract("mixtureWeightsPrior")['mixtureWeightsPrior'].tolist()})
results.update({'mixtureMeans': model.extract("mixtureMeans")['mixtureMeans'].tolist()})
results.update({'mixtureMeansPrior': model.extract("mixtureMeansPrior")['mixtureMeansPrior'].tolist()})
results.update({'mixtureVariances': model.extract("mixtureVariances")['mixtureVariances'].tolist()})

results.update({'predictiveMean': model.extract("predictiveMean")['predictiveMean'].tolist()})
results.update({'predictiveVariance': model.extract("predictiveVariance")['predictiveVariance'].tolist()})

results.update({'yValidation': data['yValidation'].tolist()})
results.update({'yEstimation': data['yEstimation'].tolist()})
results.update({'regressorMatrixEstimation': data['regressorMatrixEstimation'].tolist()})
results.update({'regressorMatrixValidation': data['regressorMatrixValidation'].tolist()})    
results.update({'outputSignal': data['observations'].tolist()})
results.update({'guessedOrder': np.array(data['guessedOrder']).tolist()})        
results.update({'gridPoints': data['gridPoints'].tolist()})

with open(name + '.json', 'w') as f:
        json.dump(results, f, ensure_ascii=False)        



