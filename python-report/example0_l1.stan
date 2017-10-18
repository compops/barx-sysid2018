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
    real<lower=0> scaleModelCoefficients;
}
model {
    // L1 prior
    scaleModelCoefficients ~ normal(0, 1.0);
    modelCoefficients ~ double_exponential(0, scaleModelCoefficients^2);

    observationNoiseVariance ~ cauchy(0, 1.0);
        
    yEstimation ~ normal(regressorMatrixEstimation * modelCoefficients, observationNoiseVariance);
}
generated quantities {
    vector[noValidationData] predictiveMean;
    predictiveMean = regressorMatrixValidation * modelCoefficients;
}