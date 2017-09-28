import pystan
import numpy as np
from scipy.signal import lfilter
import matplotlib.pylab as plt
from helpers import buildPhiMatrix, saveResultsFIR

systemModel = {'noObservations': 1000,
               'order': 5,
               'noiseMean': -2.0,
               'noiseStd': 1.0,
               'input': [],
               'output': [],
               'poles': [],
               'coefficients': []
}
systemModel['input'] = np.random.normal(loc=0.0, scale=1.0, size=systemModel['noObservations'])
#systemModel['poles'] = np.random.uniform(low=-1.0, high=1.0, size=systemModel['order'])
#systemModel['coefficients'] = np.poly(systemModel['poles'])
systemModel['coefficients'] = (1.0, -0.71, -0.38, 0.17, -0.005, -0.001)

# Generate data
phi = buildPhiMatrix(systemModel['input'], systemModel['order'])
systemModel['output'] = np.dot(phi, systemModel['coefficients'])
systemModel['output'] += np.random.normal(loc=systemModel['noiseMean'], scale=systemModel['noiseStd'], size=len(systemModel['output']))
#plt.plot(systemModel['output'])
#plt.show()

# Build Phi matrix
modelOrderGuess = 10
phiGuessedModelOrder = buildPhiMatrix(systemModel['input'], modelOrderGuess)
yGuessedModelOrder = systemModel['output'][(modelOrderGuess-systemModel['order']):]
# print(systemModel['coefficients'])
# print(phiGuessedModelOrder.shape)
# print(yGuessedModelOrder.shape)
# print(np.linalg.lstsq(phiGuessedModelOrder, yGuessedModelOrder)[0])

# Run Stan
data = {'noObservations': len(yGuessedModelOrder), 'systemOrder': modelOrderGuess, 'x': phiGuessedModelOrder, 'y': yGuessedModelOrder}
sm = pystan.StanModel(file='firmodel.stan')
fit = sm.sampling(data=data, iter=10000, chains=1)

saveResultsFIR(systemModel['output'], systemModel['input'], fit, 'firOrderFiveGuessedTen')