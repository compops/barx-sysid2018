import pystan
import numpy as np
import matplotlib.pylab as plt
from helpers import saveResultsARXMixture
from scipy.io import loadmat

data = loadmat("../data/eeg.mat")
eegData = data['y'].flatten()
trainingData = eegData[:1000]
evaluationData = eegData[10000:]

# Run Stan
gridPoints = np.arange(-10, 10, 0.01)
noGridPoints = len(gridPoints)
data = {'noObservations': len(trainingData), 
        'noComponents': 5, 
        'observations': trainingData, 
        'alpha': 10.0, 
        'noGridPoints': noGridPoints, 
        'gridPoints': gridPoints,
        'maxLag': 10
        }

sm = pystan.StanModel(file='arx-gmmodel.stan')
fit = sm.sampling(data=data, iter=3000, chains=1)

saveResultsARXMixture(gridPoints, trainingData, fit, 'arxGaussianMixtureEEGData')