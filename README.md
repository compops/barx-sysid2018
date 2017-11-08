## Using Docker
All the results in this paper were generated using the code in a Docker container. This means that it is possible for the reader to recreate exactly the some software environment that was used by the authors. This is done by using Docker, which will download all the dependencies (with the version used by the authors) onto your computer and run the files there.

First you need to download and installer Docker on your OS. Please see https://docs.docker.com/engine/installation/ for instructions on how to do this. Then you can run the Docker container by running the command
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
which will extract the results and put them into `results/`.

The plots in the paper can then be replicated using the JSON files from the run of the Docker file. Please place these in the results folder from a cloned version of this repository and then run the code in `r/` to create the pdf files.