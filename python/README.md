# Python code

## Installation
This code was developed using Anaconda 3 and Python 3.6.3. To satisfy these requirements, please download Anaconda from https://www.anaconda.com/ for your OS and some extra libraries by running
``` bash
conda install pystan cython
```
If you opt to install python yourself some additional libraries are required. These can be installed using:
``` bash
pip install -r requirements.txt
```
see the file for the exact versions used for running the experiments in the paper.


## Reproducing the results in the paper
The results in the paper can be reproduced by running the scripts found in the folder `python/`. Here, we discuss each of the three examples in details and provide some additional supplementary details, which are not covered in the paper. The results from each script is saved in the folder `results/` under sub-folders corresponding to the three different examples.

To execute a single experiment call

``` bash
python run_script.py experiment_number
```
with `experiment_number` as 0 (GMM illustration) or 1, 2 and 3 for the illustrations in the paper.

### Example 1: Synthetic data with Gaussian noise
The script `example1_arx.py` reproduces the first illustration in the paper. The script reads some data produced by the MATLAB script in `matlab/example1_arx.m`. Some settings relevant for the user to change are:

* `order_guess`: a tuple with `n_a` and `n_b`, i.e., the maximum orders for the filter polynomials.
* `grid_points`: an array with the grid points to evaluate the mixture model for the noise over.
* `no_comp`: the number of components `n_e` in the mixture model for the noise.
* `mix_weight_hyperprior`: the value of the hyper-prior for the mixture weights `\alpha_w`.
* `no_iterations`: number of MCMC iterations, half of this number is taken as the burn-in.
* `no_chains`: number of parallel chains to run. (Set to 1 in paper simulations).

Most of the remaining settings are standard. The initialisation of the Markov chain is done by the function `init_random_data` in the file `python/helpers.py`. This function needs to be changed if some of the settings above are changed or if you change the data set. The variables `order`, `no_comp` and `data_range` corresponds to `n_a + n_b`, `n_e` and the range of y (given as a tuple with minimum and maximum values).

The output is saved as a JSON-file and as a pickle-object for future investigations and for making plots. These files are written to the directory `results/example1`. The plots can be reproduced using the scripts in `r/`, see README.md in that directory for more information.

### Example 2: Synthetic data with Gaussian mixture noise
The script `example2_arxgmm.py` reproduces the second illustration in the paper. The script reads some data produced by the MATLAB script in `matlab/example2_arxgmm.m`. The settings are basically the same as for example 1.

### Example 3: Real-world EEG data
The script `example3_eegdata.py` reproduces the third illustration in the paper. The settings are the same as for the first and second examples. This script makes use of the function `init_eegdata` in the file `python/helpers.py` to initialise the Markov chain. It works in the same manner and just have different variables for the range of the output etc.

### Example 0: Gaussian mixture models
The script `illustrations_gmms.py` reproduces the example of the different distributions that the GMM can capture in Section 2. The setup is the same as for the other scripts but here data is also generated in the script from some different distributions.

## File structure
An overview of the file structure of the code base is found below.

* `barx_gmm.stan`: this file contains the model description of BARX used in STAN.
* `gmm.stan`: this file contains the model description of a GMM used in STAN. It is basically a simplified version of BARX that runs faster.
* `helpers.py` contains helpers for initialisation, for building regression matrices and for saving the output to file.

## Modifying the code for other data sets
The code is quite simple to change to use other data sets. First the data must be imported as the the scripts corresponding to each of the illustration. Then the initalisation needs to be changed as discussed about and perhaps the choices of `n_a`, `b_b` and `n_e`. Also the grid might need adjustments so that nice plots of the noise distributions can be made later.