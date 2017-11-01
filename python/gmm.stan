data {
  int<lower = 1> no_comp;
  int<lower = 1> no_obs;
  real obs[no_obs];
  real mix_weights_hyperprior;
  int<lower = 0> no_grid_points;
  vector[no_grid_points] grid_points;
}

parameters {
  simplex[no_comp] mix_weights;
  ordered[no_comp] mix_means;
  vector<lower=0>[no_comp] mix_var;
  real<lower=0> mix_weights_prior;
  real<lower=0> mix_var_prior;
}

model {
  real foo[no_comp];
  vector[no_comp] mix_weights_prior_vec;

  mix_weights_prior ~ gamma(mix_weights_hyperprior, mix_weights_hyperprior * no_comp);
  for (k in 1:no_comp)
        mix_weights_prior_vec[k] = mix_weights_prior;
  mix_weights ~ dirichlet(mix_weights_prior_vec);

  mix_var_prior ~ cauchy(0, 1.0);
  mix_means ~ normal(0, mix_var_prior^2);

  mix_var ~ cauchy(0, 1.0);

  for (n in 1:no_obs) {
    for (k in 1:no_comp)
        foo[k] = log(mix_weights[k]) + normal_lpdf(obs[n] | mix_means[k], mix_var[k]);
    target += log_sum_exp(foo);
  }
}

generated quantities {
    vector[no_grid_points] mix_on_grid;
    real foo[no_comp];
    for (n in 1:no_grid_points) {
        for (k in 1:no_comp)
            foo[k] = log(mix_weights[k]) + normal_lpdf(grid_points[n] | mix_means[k], mix_var[k]);
        mix_on_grid[n] = log_sum_exp(foo);
    }
}


