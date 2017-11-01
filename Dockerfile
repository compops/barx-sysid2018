# Use an official Python runtime as a parent image
FROM python:3.6

# Set the working directory to /app
WORKDIR /app

# Copy the current directory contents into the container at /app
ADD python/*.py
ADD python/*.stan
ADD run_script.py

# Install any needed packages specified in requirements.txt
RUN pip install -r requirements.txt

# Run Python files when the container launches
CMD ["python", "run_script.py"]