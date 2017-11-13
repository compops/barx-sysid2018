# Use an official Python runtime as a parent image
FROM python:3.6

# Set the working directory to /app
WORKDIR /app

# Copy the current directory contents into the container at /app
ADD ./python /app
ADD ./data /data
ADD ./requirements.txt /app

# Install any needed packages specified in requirements.txt
RUN pip install -r requirements.txt

# Run Python files when the container launches
#RUN mkdir results
CMD python run_script.py