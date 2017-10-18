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
    real<lower=0> observationNoiseVariance;
}
model {
    // Normal
    modelCoefficients ~ normal(0, 1);
    observationNoiseVariance ~ cauchy(0, 1.0);
    yEstimation ~ normal(regressorMatrixEstimation * modelCoefficients, observationNoiseVariance);
}
generated quantities {
    vector[noValidationData] predictiveMean;
    predictiveMean = regressorMatrixValidation * modelCoefficients;
}