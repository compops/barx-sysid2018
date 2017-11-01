import pickle
import pystan
import numpy as np
from helpers import build_phi_matrix, init_random_data, write_results_to_json
from helpers import ensure_dir
from scipy.io import loadmat

# Get data
data = loadmat("../data/example2_arxgmm.mat")
coefs_a = data['a'].flatten()
coefs_b = data['b'].flatten()
obs = data['dataOutNoisy'].flatten()
inputs = data['dataIn'].flatten()
order = (len(coefs_a) - 1, len(coefs_b))

no_obs = obs.shape[0]
no_est_data = int(np.floor(no_obs * 0.67))
no_val_data = int(no_obs - no_est_data)

est_obs = obs[:no_est_data]
est_inputs = inputs[:no_est_data]

val_obs = obs[no_est_data:]
val_inputs = inputs[no_est_data:]

# Build regressor matrices
order_guess = (4, 5)
est_data_matrix = build_phi_matrix(est_obs, order_guess, est_inputs)
y_est = est_obs[int(np.max(order_guess)):]
val_data_matrix = build_phi_matrix(val_obs, order_guess, val_inputs)
y_val = val_obs[int(np.max(order_guess)):]

# Run Stan
grid_points = np.arange(-6, 6, 0.05)
no_grid_points = len(grid_points)

data = {'no_est_data': len(y_est),
        'no_val_data': len(y_val),
        'systemOrder': int(np.sum(order_guess)),

        'est_data_matrix': est_data_matrix,
        'val_data_matrix': val_data_matrix,
        'y_est': y_est,
        'y_val': y_val,

        'no_comp': 5,
        'mix_weight_hyperprior': 10.0,
        'no_grid_points': no_grid_points,
        'grid_points': grid_points,

        'true_order': order,
        'order_guess': order_guess,
        'sys_order': np.sum(order_guess),
        'coefs_a': coefs_a,
        'coefs_b': coefs_b,
        'obs': obs,
        'inputs': inputs,

        'no_iterations': 10000,
        'no_chains': 4
}

model = pystan.StanModel(file='barx_gmm.stan')
fit = model.sampling(data=data,
                     iter=data['no_iterations'],
                     chains=data['no_chains'],
                     init=init_random_data,
                     n_jobs=4)

# Save results to file
file_name = "../results/example2_arx_gmm.pickle"
ensure_dir(file_name)
with open(file_name, "wb") as f:
    pickle.dump({'model' : model, 'fit' : fit}, f, protocol=-1)
write_results_to_json('example2_arx_gmm', data, fit)
