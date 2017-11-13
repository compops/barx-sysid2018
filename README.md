# Sparse Bayesian ARX models with flexible noise distributions
This code was downloaded from https://github.com/compops/barx-sysid2018 and contains the code and data used to produce the results in the paper:

J. Dahlin, A. Wills and B. Ninness, Sparse Bayesian ARX models with flexible noise distributions. Pre-print, arXiv:1712:****, 2017.

The paper is available as a preprint from http://arxiv.org/pdf/1712****.

## Python code
This code is used to set-up and run all the experiments in the paper. The code can possibly also be modified for other models. See the `README.md` file for more information.

### Docker
A simple method to reproduce the results is to make use of the Docker container build from the code in this repository when the paper was published. Docker enables you to recreate the computational environment used to create the results in the paper. Hence, it automatically downloads the correct version of Python and all dependencies.

First, you need to download and installer Docker on your OS. Please see https://docs.docker.com/engine/installation/ for instructions on how to do this. Then you can run the Docker container by running the command
``` bash
docker run --name barx-sysid2018-run compops/barx-sysid2018:draft1
```
This will download the code and execute it on your computer. The progress will be printed to the screen. Note that the runs will take a few hours to complete. The results can then be access by
``` bash
docker cp barx-sysid2018-run:/app/results/<file-name> <insert-directory-name>
```
where you replace `<file-name>` with the file to be copied and `<insert-directory-name>` with the search path to the directory where you want the results to be copied. This action is carried out by the script `extract_results_from_docker_container.sh` which in Ubuntu can be run by executing
``` bash
chmod +x extract_results_from_docker_container.sh
./extract_results_from_docker_container.sh
```
which will extract the results and put them into the current folder.

## R code
This code is used to generate diagnostic plot as well as plots and table for the paper. See the `README.md` file for more information.

## Binaries and results from simulations
The data generated from each run of the proposed method takes up a lot of space. Therefore the generated data cannot be easily distributed via GitHub. Please contact the authors if you would like to receive a copy of the out from the simulations. Otherwise, you should be able to reproduce all runs yourself within a few hours by running the Docker container.

## License
This source code is distributed under the MIT license. See the file `LICENSE` for more information.

