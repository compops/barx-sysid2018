"""Estimates a model using data from an ARX model with EEG data."""
import pickle
import pystan
import numpy as np
from python.helpers import build_phi_matrix
from python.helpers import init_eegdata
from python.helpers import write_results_to_json
from python.helpers import ensure_dir
from scipy.io import loadmat

def run():
    """Executes the experiment."""
    # Get data
    data = loadmat("data/example3_eegdata.mat")
    obs = data['y'].flatten()[0::4]
    obs = (obs - np.mean(obs)) / np.sqrt(np.var(obs))

    no_obs = obs.shape[0]
    no_est_data = 2000
    no_val_data = int(no_obs - no_est_data)

    est_obs = obs[:no_est_data]
    val_obs = obs[no_est_data:]

    # Build regressor matrices
    order_guess = 10
    est_data_matrix = build_phi_matrix(est_obs, order_guess)
    est_data_matrix = est_data_matrix[:, 1:]
    y_est = est_obs[int(np.max(order_guess)):]
    val_data_matrix = build_phi_matrix(val_obs, order_guess)
    val_data_matrix = val_data_matrix[:, 1:]
    y_val = val_obs[int(np.max(order_guess)):]

    # Run Stan
    grid_points = np.arange(-2, 2, 0.01)
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

            'order_guess': order_guess,
            'sys_order': np.sum(order_guess),
            'obs': obs,

            'no_iterations': 10000,
            'no_chains': 1
    }

    model = pystan.StanModel(file='python/barx_gmm.stan')
    fit = model.sampling(data=data,
                        iter=data['no_iterations'],
                        chains=data['no_chains'],
                        init=init_eegdata,
                        seed=10)

    # Save results to file
    file_name = "results/example3_eegdata.pickle"
    ensure_dir(file_name)
    with open(file_name, "wb") as f:
        pickle.dump({'model' : model, 'fit' : fit}, f, protocol=-1)
    write_results_to_json('example3_eegdata', data, fit)
