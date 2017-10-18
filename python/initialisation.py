import numpy as np

def initialiseARXlocationMixture():
    order = 9
    noComp = 5
    datarange = (-2.5955031454050141, 12.214990401183739)
    mixtureMeans = np.sort(np.random.uniform(low=datarange[0], high=datarange[1], size=noComp))
    modelCoefficients = np.random.uniform(low=-1.0, high=1.0, size=order)

    output = dict(modelCoefficients=modelCoefficients,
                    modelCoefficientsPrior=1.0,
                    observationNoiseVariance=1.0,
                    mixtureWeights=np.ones(noComp) / noComp,
                    mixtureMeans=mixtureMeans,
                    mixtureMeansPrior = 1.0,
                    mixtureWeightsPrior = 1.0
                )
        
    return output

def initialiseARXlocationScaleMixture():
    order = 9
    noComp = 5
    datarange = (-2.5955031454050141, 12.214990401183739)
    mixtureMeans = np.sort(np.random.uniform(low=datarange[0], high=datarange[1], size=noComp))
    mixtureVariances = np.ones(noComp)    
    modelCoefficients = np.random.uniform(low=-1.0, high=1.0, size=order)

    output = dict(modelCoefficients=modelCoefficients,
                  modelCoefficientsPrior=1.0,
                  mixtureWeights=np.ones(noComp) / noComp,
                  mixtureMeans=mixtureMeans,
                  mixtureMeansPrior = 1.0,
                  mixtureVariances = mixtureVariances,
                  mixtureWeightsPrior = 1.0
                )
    
    return output

def initialiseARXModelEEGData():
    order = 10
    noComp = 5
    datarange = (-5.0, 2.0)
    mixtureMeans = np.sort(np.random.uniform(low=datarange[0], high=datarange[1], size=noComp))
    mixtureVariances = np.ones(noComp)    
    modelCoefficients = np.random.uniform(low=-1.0, high=1.0, size=order)

    output = dict(modelCoefficients=modelCoefficients,
                  modelCoefficientsPrior=1.0,
                  mixtureWeights=np.ones(noComp) / noComp,
                  mixtureMeans=mixtureMeans,
                  mixtureMeansPrior = 1.0,
                  mixtureVariances = mixtureVariances,
                  mixtureWeightsPrior = 1.0
                )
    
    return output