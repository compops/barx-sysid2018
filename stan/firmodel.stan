data {
    int<lower=0> noObservations;
    int<lower=0> systemOrder;
    matrix[noObservations, systemOrder + 1] x;
    vector[noObservations] y;
}
parameters {
    real alpha;
    vector[systemOrder] beta;
    real<lower=0> sigma;
    real<lower=0> sigma0;
}
model {
    alpha ~ normal(0, 1);
    sigma0 ~ gamma(1, 1);
    beta ~ double_exponential(0, sigma0);
    sigma ~ cauchy(0, 5);
    y ~ normal(x[:, 1] + x[:, 2:] * beta + alpha, sigma);
}
generated quantities {}