data {
  int<lower=1> systemOrder;

  int<lower=1> noComponents;
  int<lower=1> noTrainingData;
  int<lower=1> noGridPoints;
  int<lower=1> noEvaluationData;

  real mixtureWeightsHyperPrior;

  real gridPoints[noGridPoints];
  vector[noTrainingData] trainingDataY;
  matrix[noTrainingData, systemOrder + 1] trainingDataX;
  matrix[noEvaluationData, systemOrder + 1] evaluationDataX;
}

parameters {
  vector[systemOrder] filterCoefficient;

  simplex[noComponents] mixtureWeights;
  ordered[noComponents] mixtureMean;
  vector<lower=0>[noComponents] mixtureVariance;

  real<lower=0> filterCoefficientPrior;
  real<lower=0> mixtureWeightsPrior;
  real<lower=0> mixtureMeanPrior;
}

model {
  vector[noComponents] mixtureWeightsPriorVector;
  real logPosteriorPerComponent[noComponents];

  filterCoefficientPrior ~ cauchy(0, 1.0);
  filterCoefficient ~ normal(0, filterCoefficientPrior^2);
  
  mixtureWeightsPrior ~ gamma(mixtureWeightsHyperPrior, mixtureWeightsHyperPrior * noComponents);
  for (k in 1:noComponents)
        mixtureWeightsPriorVector[k] = mixtureWeightsPrior;
  mixtureWeights ~ dirichlet(mixtureWeightsPriorVector);

  mixtureMeanPrior ~ cauchy(0, 1.0);
  mixtureMean ~ normal(0, mixtureMeanPrior^2);    
  mixtureVariance ~ cauchy(0, 1.0);

    for (k in 1:noComponents)
        logPosteriorPerComponent[k] = log(mixtureWeights[k]) + normal_lpdf(trainingDataY | mixtureMean[k] + trainingDataX[:, 1] + trainingDataX[:, 2:] * filterCoefficient, mixtureVariance[k]);
    target += log_sum_exp(logPosteriorPerComponent);
}

generated quantities {
    vector[noGridPoints] mixtureOnGrid;
    vector[noEvaluationData] predictiveMean;
    real predictiveVariance;

    for (n in 1:noGridPoints)   
        mixtureOnGrid[n] = 0.0;    
    
    for (k in 1:noComponents) {
        mixtureOnGrid = mixtureOnGrid + mixtureWeights[k] * exp(normal_lpdf(gridPoints | mixtureMean[k], mixtureVariance[k]));
    }
    
    for (n in 1:noEvaluationData)
        predictiveMean[n] = 0.0;
    
    for (k in 1:noComponents)
        predictiveMean = predictiveMean + mixtureWeights[k] * (mixtureMean[k] + evaluationDataX[:, 1] + evaluationDataX[:, 2:] * filterCoefficient);
    
    predictiveVariance = 0.0;
    for (k in 1:noComponents) {
        predictiveVariance = predictiveVariance + mixtureWeights[k]^2 * mixtureVariance[k];
    }    
}


