# Python code

## Installation
This code was developed using Anaconda 3 and Python 3.6.3. To satisfy these requirements, please download Anaconda from https://www.anaconda.com/ for your OS and some extra libraries by running
``` bash
conda install pystan cython
```
If you opt to install python yourself some additional libraries are required. These can be installed using:
``` bash
pip install pystan cython
```
The exact versions used when running the experiments in the paper are available in the `requirements.txt` file in the root folder of the repository.


## Reproducing the results in the paper

## File structure
An overview of the file structure of the code base is found below.

* `example1_arx.py`
* `example2_arxgmm.py`
* `example3_eegdata.py`
* `*.stan`
* `helpers.py`
* `illustration_gmms.py`

## Modifying the code for other models