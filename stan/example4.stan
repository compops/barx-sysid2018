data {
  int<lower=1> maxLag;

  int<lower=1> noComponents;
  int<lower=1> noTrainingData;
  int<lower=1> noGridPoints;
  int<lower=1> noEvaluationData;

  real mixtureWeightsHyperPrior;

  real trainingData[noTrainingData];
  real gridPoints[noGridPoints];
  real evaluationData[noEvaluationData];
}

parameters {
  vector<lower=-1, upper=1>[maxLag] filterCoefficient;

  simplex[noComponents] mixtureWeights;
  ordered[noComponents] mixtureMean;
  vector<lower=0>[noComponents] mixtureVariance;

  real<lower=0> filterCoefficientPrior;
  real<lower=0> mixtureWeightsPrior;
  real mixtureMeanPrior;
}

model {
  vector[noComponents] mixtureWeightsPriorVector;
  real logPosteriorPerComponent[noComponents];
  real autoRegressivePart;

  filterCoefficientPrior ~ cauchy(0, 1.0);
  filterCoefficient ~ normal(0, filterCoefficientPrior^2);
  
  mixtureWeightsPrior ~ gamma(mixtureWeightsHyperPrior, mixtureWeightsHyperPrior * noComponents);
  for (k in 1:noComponents)
        mixtureWeightsPriorVector[k] = mixtureWeightsPrior;
  mixtureWeights ~ dirichlet(mixtureWeightsPriorVector);
  mixtureMeanPrior ~ cauchy(0, 1.0);
  mixtureMean ~ normal(0, mixtureMeanPrior^2);    
  mixtureVariance ~ cauchy(0, 1.0);

  for (n in (maxLag+1):noTrainingData) {
    autoRegressivePart = 0.0;

    for (k in 1:maxLag)
        autoRegressivePart = autoRegressivePart + filterCoefficient[k] * trainingData[n-k];
         
    for (k in 1:noComponents)
        logPosteriorPerComponent[k] = log(mixtureWeights[k]) + normal_lpdf(trainingData[n] | mixtureMean[k] + autoRegressivePart, mixtureVariance[k]);
    target += log_sum_exp(logPosteriorPerComponent);    
  }
}

generated quantities {
    real mixtureOnGrid[noGridPoints];
    real logPosteriorPerComponent[noComponents];
    real predictiveMean[noEvaluationData];
    real predictiveVariance[noEvaluationData];
    real autoRegressivePart;

    for (n in 1:noGridPoints) {           
        for (k in 1:noComponents)
            logPosteriorPerComponent[k] = log(mixtureWeights[k]) + normal_lpdf(gridPoints[n] | mixtureMean[k], mixtureVariance[k]);
        mixtureOnGrid[n] = log_sum_exp(logPosteriorPerComponent);
    }

    for(n in 1:(maxLag+1)) {
        predictiveMean[n] = evaluationData[n];
        predictiveVariance[n] = 0.0;
    }

    for (n in (maxLag+1):noEvaluationData) {
        autoRegressivePart = 0.0;
        for (k in 1:maxLag)
            autoRegressivePart = autoRegressivePart + filterCoefficient[k] * evaluationData[n-k];
        
        predictiveMean[n] = 0.0;
        predictiveVariance[n] = 0.0;
        for (k in 1:noComponents) {
            predictiveMean[n] = predictiveMean[n] + mixtureWeights[k] * (mixtureMean[k] + autoRegressivePart);
            predictiveVariance[n] = predictiveVariance[n] + mixtureWeights[k]^2 * mixtureVariance[k];
        }
    }
}


