data {
    int<lower=0> noEstimationData;
    int<lower=0> noValidationData;
    int<lower=0> systemOrder;

    matrix[noEstimationData, systemOrder] regressorMatrixEstimation;
    matrix[noValidationData, systemOrder] regressorMatrixValidation;
    vector[noEstimationData] yEstimation;
}

parameters {
  vector[systemOrder] modelCoefficients;
  real<lower=0> modelCoefficientsPrior;
  real<lower=0> observationNoiseVariance;
}


model {
  observationNoiseVariance ~ cauchy(0, 5.0);
  modelCoefficientsPrior ~ cauchy(0, 5.0);
  modelCoefficients ~ normal(0, modelCoefficientsPrior^2);

  yEstimation ~ normal(regressorMatrixEstimation * modelCoefficients, observationNoiseVariance);
}

generated quantities {
    vector[noValidationData] predictiveMean;
    real predictiveVariance;

    predictiveMean = regressorMatrixValidation * modelCoefficients;
    predictiveVariance = observationNoiseVariance;
}