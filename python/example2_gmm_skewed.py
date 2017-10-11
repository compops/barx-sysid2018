import numpy as np
import pystan
import matplotlib.pylab as plt
from scipy.stats import norm
from helpers import randn_skew_fast
from helpers import plotResultsMixtures, saveResultsMixtures

# Generate data
noObservations = 1000
observations = randn_skew_fast(noObservations, -5, -1, 2)

# Run Stan
gridPoints = np.arange(-10, 10, 0.01)
noGridPoints = len(gridPoints)
data = {'noObservations': noObservations, 
        'noComponents': 5, 
        'observations': observations, 
        'alpha': 10.0, 
        'noGridPoints': noGridPoints, 
        'gridPoints': gridPoints}

sm = pystan.StanModel(file='example2.stan')
fit = sm.sampling(data=data, iter=10000, chains=1)

# Plot and save to file
plotResultsMixtures(fit, observations, gridPoints, 'skewed')
saveResultsMixtures(gridPoints, observations, fit, 'skewed')