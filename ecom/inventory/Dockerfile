# Use the official Python image as a base image
FROM python:alpine

# Create and change to the app directory
WORKDIR /app

# Copy requirements.txt
COPY requirements.txt .

# Install dependencies
RUN pip install -r requirements.txt

# Copy the rest of the application
COPY . .

# Expose port 5000
EXPOSE 5000

# Start the server
CMD ["python", "app.py"]
