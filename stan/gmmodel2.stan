data {
  int<lower = 1> noComponents;
  int<lower = 1> noObservations;
  real observations[noObservations];
  real alpha;
  int<lower = 0> noGridPoints;
  vector[noGridPoints] gridPoints;
}

parameters {
  simplex[noComponents] weights;
  ordered[noComponents] mu;
  vector<lower=0>[noComponents] sigma;
  real<lower=0> e0;
  real<lower=0> sigma0;
}

model {
  real ps[noComponents];
  vector[noComponents] e0Vector;

  e0 ~ gamma(alpha, alpha * noComponents);
  for (k in 1:noComponents)
        e0Vector[k] = e0;
  weights ~ dirichlet(e0Vector);
  
  sigma0 ~ cauchy(0, 1.0);
  mu ~ normal(0, sigma0^2);
  
  sigma ~ cauchy(0, 1.0);
    
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


