import pystan
import numpy as np
import matplotlib.pylab as plt
from helpers import saveResultsARXMixture
from scipy.io import loadmat

data = loadmat("../data/eeg.mat")
eegData = data['y'].flatten()[0::4]
eegData = (eegData - np.mean(eegData)) / np.sqrt(np.var(eegData))
trainingData = eegData[:2000]
evaluationData = eegData[2000:]

# Run Stan
gridPoints = np.arange(-20, 20, 0.1)
noGridPoints = len(gridPoints)
data = {'noTrainingData': len(trainingData), 
        'noEvaluationData':  len(evaluationData),
        'trainingData': trainingData,
        'evaluationData': evaluationData,
        'noComponents': 5,
        'mixtureWeightsHyperPrior': 20.0, 
        'noGridPoints': noGridPoints, 
        'gridPoints': gridPoints,
        'maxLag': 10
        }

sm = pystan.StanModel(file='example4.stan')
fit = sm.sampling(data=data, iter=10000, chains=1)

saveResultsARXMixture(data, model=fit, name='arxGaussianMixtureEEGData')