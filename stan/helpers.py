import numpy as np

def buildPhiMatrix(data, order):
    noObservations = len(data)
    Phi = np.zeros((noObservations, order + 1))
    for i in range(order, noObservations):
        Phi[i, :] = data[range(i, i - order - 1, -1)]
    return(Phi[order:, :])


# order = 5
# noObservations = 1000
# beta = np.poly(np.random.uniform(low=-1.0, high=1.0, size=order))
# regressors = np.random.normal(loc=0.0, scale=0.1, size=noObservations)

# PhiFull = buildPhiMatrix(regressors, order)
# y = np.dot(PhiFull, beta)

# print(beta)
# print(np.linalg.lstsq(PhiFull, y)[0])