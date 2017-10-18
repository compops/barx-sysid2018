data {
    int<lower=0> noEstimationData;
    int<lower=0> noValidationData;
    int<lower=0> systemOrder;
    matrix[noEstimationData, systemOrder] regressorMatrixEstimation;
    matrix[noValidationData, systemOrder] regressorMatrixValidation;
    vector[noEstimationData] yEstimation;

    int<lower=1> noComponents;
    int<lower=1> noGridPoints;
    real mixtureWeightsHyperPrior;

    real gridPoints[noGridPoints];
}

parameters {
  vector[systemOrder] filterCoefficient;
  
  simplex[noComponents] mixtureWeights;
  ordered[noComponents] mixtureMean;
  vector<lower=0>[noComponents] mixtureVariance;
  
  //real<lower=0> filterCoefficientPrior;
  real<lower=0> mixtureWeightsPrior;
  real<lower=0> mixtureMeanPrior;
}

model {
  vector[noComponents] mixtureWeightsPriorVector;
  real logPosteriorPerComponent[noComponents];

  //filterCoefficientPrior ~ cauchy(0, 1.0);
  //filterCoefficient ~ normal(0, filterCoefficientPrior^2);
  
  mixtureWeightsPrior ~ gamma(mixtureWeightsHyperPrior, mixtureWeightsHyperPrior * noComponents);
  for (k in 1:noComponents)
        mixtureWeightsPriorVector[k] = mixtureWeightsPrior;
  mixtureWeights ~ dirichlet(mixtureWeightsPriorVector);

  //mixtureMeanPrior ~ cauchy(0, 5.0);
  mixtureMeanPrior ~ normal(0, 30);
  //mixtureMean ~ normal(0, mixtureMeanPrior^2);    
  //mixtureVariance ~ cauchy(0, 1.0);

    for (n in 1:noEstimationData) {
        for (k in 1:noComponents){
            logPosteriorPerComponent = log(mixtureWeights[k]) + normal_lpdf(yEstimation[n] | mixtureMean[k] + regressorMatrixEstimation[n, :] * filterCoefficient, mixtureVariance[k]);
        }
        target += log_sum_exp(logPosteriorPerComponent);
    }
}

generated quantities {
    int classIndex;
    vector[noGridPoints] mixtureOnGrid;
    matrix[noValidationData, noComponents] predictiveMean;
    vector[noComponents] predictiveVariance;
    vector[noComponents] predictiveWeight;

    for (n in 1:noGridPoints) {
        classIndex = categorical_rng(mixtureWeights);
        mixtureOnGrid[n] = mixtureWeights[classIndex] * exp(normal_lpdf(gridPoints[n] | mixtureMean[classIndex, mixtureVariance[classIndex]));
    }
    
    for (k in 1:noComponents) {
        predictiveMean[:, k] = mixtureMean[k] + regressorMatrixValidation * filterCoefficient;
        //predictiveVariance[k] = mixtureVariance[k];
        predictiveVariance[k] = 0.5^2;
        predictiveWeight[k] = mixtureWeights[k];
    }
}