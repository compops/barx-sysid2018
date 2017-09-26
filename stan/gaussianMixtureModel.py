import numpy as np
import pystan
import matplotlib.pylab as plt

model = {}
model.update({'compProb': (0.2, 0.4, 0.4)})
model.update({'compMean': (-2 ,0, 4)})
model.update({'compStd': (1, 2, 3)})

noObservations = 200
noComponents = int(len(model['compProb']))

observations = np.zeros(noObservations)

for idx in range(noObservations):
    comp = int(np.random.choice(noComponents, 1, p = model['compProb']))
    observations[idx] = np.random.normal(loc=model['compMean'][comp], scale=model['compStd'][comp])


#plt.hist(observations, bins=int(np.floor(np.sqrt(noObservations))))
#plt.show()

# Run Stan
gridPoints = np.arange(-10, 10, 0.01)
noGridPoints = len(gridPoints)
data = {'noObservations': noObservations, 
        'noComponents': 3, 
        'observations': observations, 
        'alpha0': 10.0, 
        'noGridPoints': noGridPoints, 
        'gridPoints': gridPoints}

sm = pystan.StanModel(file='gmmodel2.stan')
fit = sm.sampling(data=data, iter=10000, chains=1)

print(fit)
fit.plot()
plt.show()