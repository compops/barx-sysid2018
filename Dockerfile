# Use an official Python runtime as a parent image
FROM python:3.6.3

# Set the working directory to /app
WORKDIR /app

# Copy the current directory contents into the container at /app
ADD ./python /app/python
ADD ./data /app/data
ADD ./requirements.txt /app/python
ADD ./run_script.py /app
ADD ./run_script.sh /app

# Install any needed packages specified in requirements.txt
RUN pip install -r /app/python/requirements.txt

# Run Python files when the container launches
CMD bash ./run_script.sh

# Build
# docker build -t barx-sysid2018 .
# docker images
# docker tag <<TAG>> compops/barx-sysid2018:final
# docker tag <<TAG>> compops/barx-sysid2018:latest
# docker login --username=yourhubusername --email=youremail@provider.com
# docker push compops/barx-sysid2018