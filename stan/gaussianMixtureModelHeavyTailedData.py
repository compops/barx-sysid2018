import numpy as np
import pystan
import matplotlib.pylab as plt
from scipy.stats import norm
from helpers import plotResultsMixtures, saveResultsMixtures

# Generate data
noObservations = 1000
observations = 5.0 + 2.0 * np.random.standard_t(df = 5.0, size=noObservations)

# Run Stan
gridPoints = np.arange(-10, 10, 0.01)
noGridPoints = len(gridPoints)
data = {'noObservations': noObservations, 
        'noComponents': 5, 
        'observations': observations, 
        'alpha': 10.0, 
        'noGridPoints': noGridPoints, 
        'gridPoints': gridPoints}

sm = pystan.StanModel(file='gmmodel2.stan')
fit = sm.sampling(data=data, iter=10000, chains=1)

# Plot and save to file
plotResults(fit, observations, gridPoints, 'heavytailed')
saveResults(gridPoints, observations, fit, 'heavytailed')
