"""Helpers for BARX model."""
import json
import os
import numpy as np

def build_phi_matrix(obs, order, inputs=False):
    """Builds the regressor matrix for least squares."""
    no_ons = len(obs)
    if isinstance(inputs, bool):
        phi = np.zeros((no_ons, order + 1))
        for i in range(order, no_ons):
            phi[i, :] = obs[range(i, i - order - 1, -1)]
        return phi[order:, :]
    else:
        phi = np.zeros((no_ons, order[0] + order[1]))
        for i in range(int(np.max(order)), no_ons):
            phi[i, :] = np.hstack((-obs[range(i-1, i - order[0] - 1, -1)],
                                   inputs[range(i, i - order[1], -1)]))
        return phi[int(np.max(order)):, :]

def randn_skew_fast(N, alpha=0.0, loc=0.0, scale=1.0):
    """Generated skewed Gaussian random numbers.
    taken from https://stackoverflow.com/questions/36200913/generate-n-random-numbers-from-a-skew-normal-distribution-using-numpy
    """
    sigma = alpha / np.sqrt(1.0 + alpha**2)
    u0 = np.random.randn(N)
    v = np.random.randn(N)
    u1 = (sigma*u0 + np.sqrt(1.0 - sigma**2)*v) * scale
    u1[u0 < 0] *= -1
    u1 = u1 + loc
    return u1

def init_random_data():
    """Initial the Stan algorithm for random data set used in examples 1 and 2.
    The only difference is the data range and model orders."""
    order = 9
    no_comp = 5
    data_range = (-2.6, 12.2)
    mixture_means = np.sort(np.random.uniform(low=data_range[0],
                                              high=data_range[1],
                                              size=no_comp))
    mixture_variances = np.ones(no_comp)
    model_coef = np.random.uniform(low=-1.0, high=1.0, size=order)

    output = dict(model_coefs=model_coef,
                  model_coefs_prior=1.0,
                  mix_weights=np.ones(no_comp) / no_comp,
                  mix_means=mixture_means,
                  mix_means_prior = 1.0,
                  mix_var = mixture_variances,
                  mix_weights_prior = 1.0
                )
    return output

def init_eegdata():
    """Initial the Stan algorithm for random data set used in example 3.
    The only difference is the data range."""
    order = 10
    no_comp = 5
    data_range = (-5.0, 2.0)
    mixture_means = np.sort(np.random.uniform(low=data_range[0],
                                              high=data_range[1],
                                              size=no_comp))
    mixture_variances = np.ones(no_comp)
    model_coef = np.random.uniform(low=-1.0, high=1.0, size=order)

    output = dict(model_coefs=model_coef,
                  model_coefs_prior=1.0,
                  mix_weights=np.ones(no_comp) / no_comp,
                  mix_means=mixture_means,
                  mix_means_prior = 1.0,
                  mix_var = mixture_variances,
                  mix_weights_prior = 1.0
                )
    return output

def write_results_to_json(name, data, fit):
    """Compiles the results from a Stan run and writes it to a JSON file
    for plotting in e.g., R."""
    results = {}
    results.update({'name': name})
    results.update({'no_iterations': data['no_iterations']})
    results.update({'no_chains': data['no_chains']})

    if 'model_coefs' in fit.extract().keys():
        results.update({'modelCoefficients': fit.extract("model_coefs")['model_coefs']})
    if 'model_coefs_prior' in fit.extract().keys():
        results.update({'modelCoefficientsPrior': fit.extract("model_coefs_prior")['model_coefs_prior']})

    if 'mix_weights' in fit.extract().keys():
        results.update({'mixtureWeights': fit.extract("mix_weights")['mix_weights']})
    if 'mix_weights_prior' in fit.extract().keys():
        results.update({'mixtureWeightsPrior': fit.extract("mix_weights_prior")['mix_weights_prior']})
    if 'mix_means' in fit.extract().keys():
        results.update({'mixtureMeans': fit.extract("mix_means")['mix_means']})
    if 'mix_means_prior' in fit.extract().keys():
        results.update({'mixtureMeansPrior': fit.extract("mix_means_prior")['mix_means_prior']})
    if 'mix_var' in fit.extract().keys():
        results.update({'mixtureVariances': fit.extract("mix_var")['mix_var']})

    if 'pred_mean' in fit.extract().keys():
        results.update({'predictiveMean': fit.extract("pred_mean")['pred_mean']})
    if 'pred_var' in fit.extract().keys():
        results.update({'predictiveVariance': fit.extract("pred_var")['pred_var']})
    if 'mix_on_grid' in fit.extract().keys():
        results.update({'mixtureOnGrid': fit.extract("mix_on_grid")['mix_on_grid']})

    if 'y_val' in data:
        results.update({'yValidation': data['y_val']})
    if 'y_est' in data:
        results.update({'yEstimation': data['y_est']})
    if 'data_matrix_est' in data:
        results.update({'regressorMatrixEstimation': data['data_matrix_est']})
    if 'data_matrix_val' in data:
        results.update({'regressorMatrixValidation': data['data_matrix_val']})

    if 'inputs' in data:
        results.update({'inputSignal': data['inputs']})
    if 'obs' in data:
        results.update({'outputSignal': data['obs']})
    if 'true_order' in data:
        results.update({'trueOrder': np.array(data['true_order'])})
    if 'order_guess' in data:
        results.update({'guessedOrder': np.array(data['order_guess'])})
    if 'coefs_a' in data:
        results.update({'coefficientsA': data['coefs_a']})
    if 'coefs_b' in data:
        results.update({'coefficientsB': data['coefs_b']})
    if 'grid_points' in data:
        results.update({'gridPoints': data['grid_points']})

    # Convert NumPy arrays to lists
    for key in results:
        if isinstance(results[key], np.ndarray):
            results[key] = results[key].tolist()

    file_name = 'results/' + name + '.json'
    ensure_dir(file_name)
    with open(file_name, 'w') as f:
            json.dump(results, f, ensure_ascii=False)

def ensure_dir(file_name):
    """ Check if dirs for outputs exists, otherwise create them"""
    directory = os.path.dirname(file_name)
    if not os.path.exists(directory):
        os.makedirs(directory)