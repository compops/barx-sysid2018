import numpy as np
import pystan
import matplotlib.pylab as plt
from scipy.stats import norm
from helpers import randn_skew_fast
from helpers import plotting_helper

noObservations = 1000
observations = randn_skew_fast(noObservations, -3, 0, 1)
#sns.distplot(observations)
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