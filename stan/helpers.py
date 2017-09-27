import numpy as np
import matplotlib.pylab as plt
import seaborn as sns
from palettable.colorbrewer.qualitative import Dark2_8


def buildPhiMatrix(data, order):
    noObservations = len(data)
    Phi = np.zeros((noObservations, order + 1))
    for i in range(order, noObservations):
        Phi[i, :] = data[range(i, i - order - 1, -1)]
    return(Phi[order:, :])


# From https://stackoverflow.com/questions/36200913/generate-n-random-numbers-from-a-skew-normal-distribution-using-numpy
def randn_skew_fast(N, alpha=0.0, loc=0.0, scale=1.0):
    sigma = alpha / np.sqrt(1.0 + alpha**2) 
    u0 = np.random.randn(N)
    v = np.random.randn(N)
    u1 = (sigma*u0 + np.sqrt(1.0 - sigma**2)*v) * scale
    u1[u0 < 0] *= -1
    u1 = u1 + loc
    return u1

def plotting_helper(fit):
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
    plt.show()