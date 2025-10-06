# Use the official lightweight Python image
FROM python:3.9-slim

# Install dependencies
COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt

# Copy the application code
COPY app.py app.py

# Expose the port
EXPOSE 8080

# Run the application
CMD ["gunicorn", "-w", "4", "-k", "gevent", "-b", "0.0.0.0:8080", "app:app"]

