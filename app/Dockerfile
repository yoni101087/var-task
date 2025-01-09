# Use an official Python runtime as a parent image
FROM python:3.10-slim

# Create a working directory in the container
WORKDIR /app

# Copy requirements.txt into the container
COPY requirements.txt /app/

# Install the dependencies
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt

# Copy your Flask application code into the container
COPY . /app

# Expose the port where Flask will run (5000 by default)
EXPOSE 5000

# Set the entrypoint or command to run your Flask app
CMD ["python", "app.py"]
