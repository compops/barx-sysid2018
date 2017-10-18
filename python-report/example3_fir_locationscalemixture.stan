data {
    int<lower=0> noEstimationData;
    int<lower=0> noValidationData;
    int<lower=0> systemOrder;

    matrix[noEstimationData, systemOrder] regressorMatrixEstimation;
    matrix[noValidationData, systemOrder] regressorMatrixValidation;
    vector[noEstimationData] yEstimation;

    int<lower = 1> noComponents;
    real mixtureWeightsHyperPrior;
    int<lower = 0> noGridPoints;
    vector[noGridPoints] gridPoints;
}

parameters {
  vector[systemOrder] modelCoefficients;
  real<lower=0> modelCoefficientsPrior;
  
  simplex[noComponents] mixtureWeights;
  ordered[noComponents] mixtureMeans;
  vector<lower=0, upper=10>[noComponents] mixtureVariances;
  real<lower=0> mixtureWeightsPrior;
  real<lower=0> mixtureMeansPrior;
}


model {
  real tmp[noComponents];
  vector[noComponents] mixtureWeightsPriorVector;

  mixtureWeightsPrior ~ gamma(mixtureWeightsHyperPrior, mixtureWeightsHyperPrior * noComponents);
  for (k in 1:noComponents)
        mixtureWeightsPriorVector[k] = mixtureWeightsPrior;
  mixtureWeights ~ dirichlet(mixtureWeightsPriorVector);

  mixtureMeansPrior ~ cauchy(0, 1.0);
  mixtureMeans ~ normal(0, mixtureMeansPrior^2);
  mixtureVariances ~ cauchy(0, 5.0);
  
  modelCoefficientsPrior ~ cauchy(0, 5.0);
  modelCoefficients ~ normal(0, modelCoefficientsPrior^2);

  for (n in 1:noEstimationData) {
    for (k in 1:noComponents)
        tmp[k] = log(mixtureWeights[k]) + normal_lpdf(yEstimation[n] | mixtureMeans[k] + regressorMatrixEstimation[n, :] * modelCoefficients, mixtureVariances[k]);
    target += log_sum_exp(tmp);    
  }
}

generated quantities {
    vector[noValidationData] predictiveMean;
    vector[noValidationData] predictiveVariance;
    vector[noGridPoints] mixtureOnGrid;
    int classIndex;
    
    classIndex = categorical_rng(mixtureWeights);
    for (n in 1:noGridPoints) 
        mixtureOnGrid[n] = exp(normal_lpdf(gridPoints[n] | mixtureMeans[classIndex], mixtureVariances[classIndex]));

    for (n in 1:noValidationData) {
        predictiveMean[n] = mixtureMeans[classIndex] + regressorMatrixValidation[n, :] * modelCoefficients;
        predictiveVariance[n] = mixtureVariances[classIndex];
    }
}
