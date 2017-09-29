data {
  int<lower = 1> maxLag;
  int<lower = 1> noComponents;
  int<lower = 1> noObservations;
  real observations[noObservations];
  real alpha;
  int<lower = 0> noGridPoints;
  vector[noGridPoints] gridPoints;
}

parameters {
  simplex[noComponents] weights;
  vector<lower=-1, upper=1>[maxLag] g;
  positive_ordered[noComponents] sigma;
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
  g ~ normal(0, sigma0^2);
  
  sigma ~ cauchy(0, 5.0);
    
  for (n in (maxLag+1):noObservations) {
    real ar_part;
    ar_part = 0.0;

    for (k in 1:maxLag)
        ar_part = ar_part + g[k] * observations[n-k];
         
    for (k in 1:noComponents)
        ps[k] = log(weights[k]) + normal_lpdf(observations[n] | ar_part, sigma[k]);
    target += log_sum_exp(ps);    
  }
}

generated quantities {
    vector[noGridPoints] log_p_y_tilde;
    real ps[noComponents];
    for (n in 1:noGridPoints) {
        for (k in 1:noComponents)
            ps[k] = log(weights[k]) + normal_lpdf(gridPoints[n] | 0, sigma[k]);
        log_p_y_tilde[n] = log_sum_exp(ps);
    }
}


