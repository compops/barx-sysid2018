import numpy as np

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
