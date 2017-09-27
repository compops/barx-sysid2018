import numpy as np
import pystan
import matplotlib.pylab as plt
from scipy.stats import norm
from helpers import plotting_helper

noObservations = 1000
observations = 5.0 + 2.0 * np.random.standard_t(df = 5.0, size=noObservations)
#plt.hist(observations, bins=int(np.sqrt(noObservations)))
#plt.show()

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
fit = sm.sampling(data=data, iter=2000, chains=1)
plotting_helper(fit)
