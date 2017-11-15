# Use an official Python runtime as a parent image
FROM python:3.6.3

# Set the working directory to /app
WORKDIR /app/python

# Copy the current directory contents into the container at /app
ADD ./python /app/python
ADD ./data /app/data
ADD ./requirements.txt /app/python

# Install any needed packages specified in requirements.txt
RUN pip install -r /app/python/requirements.txt

# Run Python files when the container launches
CMD python run_script.py

# Compress the results into one file
CMD tar -zcvf /app/barx-sysid2018-results.tgz /app/results