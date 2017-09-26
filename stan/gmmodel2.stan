data {
  int<lower = 1> noComponents;
  int<lower = 1> noObservations;
  real observations[noObservations];
  real alpha0;
  int<lower = 0> noGridPoints;
  vector[noGridPoints] gridPoints;
}

parameters {
  simplex[noComponents] weights;
  ordered[noComponents] mu;
  real<lower=0, upper=10> sigma[noComponents];
  real alpha;
}

model {
  real ps[noComponents];
  vector[noComponents] alphaVector;
  
  mu ~ normal(0, 10);

  alpha ~ gamma(alpha0, alpha0 * noComponents);
  for (k in 1:noComponents)
        alphaVector[k] = alpha;
  weights ~ dirichlet(alphaVector);
    
  for (n in 1:noObservations) {
    for (k in 1:noComponents)
        ps[k] = log(weights[k]) + normal_lpdf(observations[n] | mu[k], sigma[k]);
    target += log_sum_exp(ps);    
  }
}

generated quantities {
    vector[noGridPoints] log_p_y_tilde;
    real ps[noComponents];
    for (n in 1:noGridPoints) {
        for (k in 1:noComponents)
            ps[k] = log(weights[k]) + normal_lpdf(gridPoints[n] | mu[k], sigma[k]);
        log_p_y_tilde[n] = log_sum_exp(ps);
    }
}