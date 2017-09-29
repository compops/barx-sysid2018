data {
    int<lower=0> noObservations;
    int<lower=0> systemOrder;
    matrix[noObservations, systemOrder + 1] x;
    vector[noObservations] y;
}
parameters {
    real mu;
    vector[systemOrder] b;
    real<lower=0> sigma;
    real<lower=0> sigma0;
}
model {
    mu ~ normal(0, 1.0);

    sigma0 ~ cauchy(0, 1.0);
    b ~ normal(0, sigma0^2);

    sigma ~ cauchy(0, 5.0);
    y ~ normal(x[:, 1] + x[:, 2:] * b + mu, sigma);
}
generated quantities {}