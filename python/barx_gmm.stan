data {
    int<lower=0> no_est_data;
    int<lower=0> no_val_data;
    int<lower=0> sys_order;

    matrix[no_est_data, sys_order] est_data_matrix;
    matrix[no_val_data, sys_order] val_data_matrix;
    vector[no_est_data] y_est;

    int<lower=1> no_comp;
    real mix_weight_hyperprior;
    int<lower=0> no_grid_points;
    vector[no_grid_points] grid_points;
}

parameters {
  vector[sys_order] model_coefs;
  real<lower=0> model_coefs_prior;

  simplex[no_comp] mix_weights;
  ordered[no_comp] mix_means;
  vector<lower=0, upper=10>[no_comp] mix_var;
  real<lower=0> mix_weights_prior;
  real mix_means_prior;
}

model {
  real tmp[no_comp];
  vector[no_comp] mix_weights_prior_vec;

  mix_weights_prior ~ gamma(mix_weight_hyperprior, mix_weight_hyperprior * no_comp);
  for (k in 1:no_comp)
        mix_weights_prior_vec[k] = mix_weights_prior;
  mix_weights ~ dirichlet(mix_weights_prior_vec);

  mix_means_prior ~ cauchy(0, 1.0);
  mix_means ~ normal(0, mix_means_prior^2);
  mix_var ~ cauchy(0, 5.0);

  model_coefs_prior ~ cauchy(0, 1.0);
  model_coefs ~ normal(0, model_coefs_prior^2);

  for (n in 1:no_est_data) {
    for (k in 1:no_comp)
        tmp[k] = log(mix_weights[k]) + normal_lpdf(y_est[n] | mix_means[k] + est_data_matrix[n, :] * model_coefs, mix_var[k]);
    target += log_sum_exp(tmp);
  }
}

generated quantities {
    vector[no_val_data] pred_mean;
    vector[no_val_data] pred_var;
    vector[no_grid_points] mix_on_grid;
    int class_idx;

    class_idx = categorical_rng(mix_weights);
    for (n in 1:no_grid_points)
        mix_on_grid[n] = exp(normal_lpdf(grid_points[n] | mix_means[class_idx], mix_var[class_idx]));

    for (n in 1:no_val_data) {
        pred_mean[n] = mix_means[class_idx] + val_data_matrix[n, :] * model_coefs;
        pred_var[n] = mix_var[class_idx];
    }
}
