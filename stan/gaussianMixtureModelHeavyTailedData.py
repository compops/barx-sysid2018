import numpy as np
import pystan
import matplotlib.pylab as plt
from scipy.stats import norm
from scipy.stats import gaussian_kde

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
fit = sm.sampling(data=data, iter=10000, chains=1)

plt.figure(1)
plt.subplot(3, 2, (1, 2))
kernelDensityEstimator = gaussian_kde(observations)
trueMixtureDensity = kernelDensityEstimator(gridPoints)
estMixtureDensity = np.mean(np.exp(fit.extract("log_p_y_tilde")['log_p_y_tilde']), axis=0)
plt.plot(gridPoints, trueMixtureDensity, 'b', gridPoints, estMixtureDensity ,'g')
sns.despine(left=False, bottom=False, right=True)
plt.xlabel("x")
plt.ylabel("p(x)")

plt.subplot(3, 2, 3)
for i in range(5):
        sns.distplot(fit.extract("mu")['mu'][:, i], color = Dark2_8.mpl_colors[i])
sns.despine(left=False, bottom=False, right=True)
plt.ylim(0, 10)
plt.xlabel("mu")
plt.ylabel("posterior estimate")

plt.subplot(3, 2, 4)
for i in range(5):
        sns.distplot(fit.extract("sigma")['sigma'][:, i], color = Dark2_8.mpl_colors[i])
sns.despine(left=False, bottom=False, right=True)
plt.ylim(0, 10)
plt.xlabel("sigma")
plt.ylabel("posterior estimate")

plt.subplot(3, 2, 5)
sns.distplot(fit.extract("sigma0")['sigma0'], color = Dark2_8.mpl_colors[6])
sns.despine(left=False, bottom=False, right=True)
plt.xlabel("sigma0")
plt.ylabel("posterior estimate")

plt.subplot(3, 2, 6)
sns.distplot(fit.extract("e0")['e0'], color = Dark2_8.mpl_colors[7])
sns.despine(left=False, bottom=False, right=True)
plt.xlabel("e0")
plt.ylabel("posterior estimate")

plt.show()


plt.figure(2)
for i in range(5):
        plt.subplot(5, 2, 2*i + 1)
        plt.plot(fit.extract("mu")['mu'][:, i], color = Dark2_8.mpl_colors[i])
        plt.xlabel("mu")
        plt.ylabel("Trace")
        plt.subplot(5, 2, 2*i + 2)
        plt.plot(fit.extract("sigma")['sigma'][:, i], color = Dark2_8.mpl_colors[i])
        plt.xlabel("sigma")
        plt.ylabel("Trace")
fit.plot()

#plt.show()