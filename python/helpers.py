import json
import numpy as np

def buildPhiMatrix(observations, order, inputs = False):
    noObservations = len(observations)
    if isinstance(inputs, bool):
        Phi = np.zeros((noObservations, order + 1))
        for i in range(order, noObservations):
            Phi[i, :] = observations[range(i, i - order - 1, -1)]
        return Phi[order:, :]
    else:
        Phi = np.zeros((noObservations, order[0] + order[1]))
        for i in range(int(np.max(order)), noObservations):
            Phi[i, :] = np.hstack((-observations[range(i-1, i - order[0] - 1, -1)], inputs[range(i, i - order[1], -1)]))
        return Phi[int(np.max(order)):, :]

# From https://stackoverflow.com/questions/36200913/generate-n-random-numbers-from-a-skew-normal-distribution-using-numpy
def randn_skew_fast(N, alpha=0.0, loc=0.0, scale=1.0):
    sigma = alpha / np.sqrt(1.0 + alpha**2) 
    u0 = np.random.randn(N)
    v = np.random.randn(N)
    u1 = (sigma*u0 + np.sqrt(1.0 - sigma**2)*v) * scale
    u1[u0 < 0] *= -1
    u1 = u1 + loc
    return u1

def generatePRBS(N, maxHold=10):
    randomSignal = np.random.choice((-1, 1), N)
    outputSignal = []

    j = 0
    while len(outputSignal) < N:
        outputSignal.append(np.ones(1 + np.random.choice(maxHold)) * randomSignal[j])
        j += 1

    return(np.concatenate(outputSignal, axis=0)[:N])