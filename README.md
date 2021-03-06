# Sparse Bayesian ARX models with flexible noise distributions
This code was downloaded from https://github.com/compops/barx-sysid2018 and contains the code and data used to produce the results in the paper:

J. Dahlin, A. Wills and B. Ninness, **Sparse Bayesian ARX models with flexible noise distributions**. Proceedings of the 18th IFAC Symposium on System Identification (SYSID), Stockholm, Sweden, July 2018.

The paper is available as a preprint from https://arxiv.org/abs/1801.01242.

## Python code (python/)
This code is used to set-up and run all the experiments in the paper. The code can possibly also be modified for other models. See the `README.md` file for more information.

### Docker
*Note that running STAN in a Docker container is for some reason very slow. This is a known problem, see e.g., https://github.com/jscamac/mwe_stan_docker. Please consider running the Python code locally without using Docker by cloning this repo instead.*

A simple method to reproduce the results is to make use of the Docker container build from the code in this repository when the paper was published. Docker enables you to recreate the computational environment used to create the results in the paper. Hence, it automatically downloads the correct version of Python and all dependencies.

First, you need to download and installer Docker on your OS. Please see https://docs.docker.com/engine/installation/ for instructions on how to do this. Secondly, you can run the Docker container by running the command
``` bash
docker run -v <<LOCALPATH>>:/app/results -e EXPERIMENT='<<EXPERIMENT_NUMBER>>' --name barx-sysid2018-run compops/barx-sysid2018:final
```
where `<<LOCALPATH>>` is replaced with a local path to where the results are to be stored, e.g., `/home/username/tmp` on a Linux computer. `<<EXPERIMENT_NUMBER>>` is replaced with either 0, 1, 2 or 3 corresponding to the illustration on GMMs (Figure 1) and the three experiments in the paper.

To reproduce the plots from the paper, move the contents of the results folder in `<<LOCALPATH>>` into a folder called results in a cloned version of the GitHub repository. Follow the instruction for the R code to create pdf versions of the plots.

## R code (r/)
This code is used to generate diagnostic plot as well as plots and table for the paper. See the `README.md` file for more information.

## MATLAB code (matlab/)
This code is used to generate random filters together with data from tem and to make the comparisons with the ARX command. See the `README.md` file for more information.

## Binaries and results from simulations
The data generated from each run of the proposed method takes up a lot of space. Therefore the generated data cannot be easily distributed via GitHub. Please contact the authors if you would like to receive a copy of the out from the simulations. Otherwise, you should be able to reproduce all runs yourself within a few hours by running the Docker container.

## License
See the file `LICENSE` for more information.
``` python
###############################################################################
#    Sparse Bayesian ARX models with flexible noise distributions
#    Copyright (C) 2018  Johan Dahlin < uni (at) johandahlin [dot] com >
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.
###############################################################################
```
