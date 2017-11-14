"""Estimates mixture models from data."""
import pystan
import pickle
import numpy as np
from scipy.stats import norm
from python.helpers import init_random_data
from python.helpers import write_results_to_json
from python.helpers import ensure_dir
from python.helpers import randn_skew_fast

def run(no_obs=1000):
    """Executes the experiment."""

    for noise_dist in range(4):
        # Generate data with uniform noise
        if noise_dist == 0:
            obs = 2.0 * 2.0 * (np.random.random(no_obs) - 0.5)
            name = 'uniform'

        # Generate data with heavy-tailed noise
        if noise_dist == 1:
            obs = 5.0 + 2.0 * np.random.standard_t(df=5.0, size=no_obs)
            name = 'heavytailed'

        # Generate data with skewed noise
        if noise_dist == 2:
            obs = randn_skew_fast(no_obs, -5, -1, 2)
            name = 'skewed'

        # Generate data with mixture noise
        if noise_dist == 3:
            mix_probs = (0.4, 0.2, 0.4)
            mix_means = (-5, 0, 5)
            mix_stdevs = (1, 3, 1)
            no_comps = len(mix_probs)

            for idx in range(no_obs):
                comp = int(np.random.choice(no_comps, 1, p=mix_probs))
                obs[idx] = np.random.normal(loc=mix_means[comp],
                                            scale=mix_stdevs[comp])
            name = 'mixture'

        # Run Stan
        grid_points = np.arange(-20, 20, 0.05)
        no_grid_points = len(grid_points)
        data = {'no_obs': no_obs,
                'no_comp': 5,
                'obs': obs,
                'mix_weights_hyperprior': 10.0,
                'no_grid_points': no_grid_points,
                'grid_points': grid_points,
                'no_iterations': 10000,
                'no_chains': 1
                }

        model = pystan.StanModel(file='python/gmm.stan')
        fit = model.sampling(data=data,
                            iter=data['no_iterations'],
                            chains=data['no_chains'],
                            seed=10)

        # Save results to file
        file_name = 'results/illustration/' + "illustration_gmm_" + name + ".pickle"
        ensure_dir(file_name)
        with open(file_name, "wb") as f:
            pickle.dump({'model': model, 'fit': fit}, f, protocol=-1)
        write_results_to_json("results/illustration/illustration_gmm_" + name, data, fit)
