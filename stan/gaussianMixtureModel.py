import numpy as np
import pystan
import matplotlib.pylab as plt
from scipy.stats import norm

model = {}
model.update({'compProb': (0.4, 0.2, 0.4)})
model.update({'compMean': (-5 , 0, 5)})
model.update({'compStd': (1, 3, 1)})

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
        'noComponents': 5, 
        'observations': observations, 
        'alpha': 10.0, 
        'noGridPoints': noGridPoints, 
        'gridPoints': gridPoints}

sm = pystan.StanModel(file='gmmodel2.stan')
fit = sm.sampling(data=data, iter=10000, chains=1)

trueMixtureDensity = np.zeros((1, len(gridPoints)))
for i in range(len(model['compMean'])):
    trueMixtureDensity += model['compProb'][i] * norm.pdf(gridPoints, model['compMean'][i], model['compStd'][i]**2)

estMixtureDensity = np.mean(np.exp(fit.extract("log_p_y_tilde")['log_p_y_tilde']), axis=0)
plt.plot(gridPoints, trueMixtureDensity[0, :], 'b', gridPoints, estMixtureDensity ,'g')
plt.show()


#print(fit)
#fit.plot()
#plt.show()