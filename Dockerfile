# Use official Python slim image as base
FROM python:3.12-slim

# Set working directory inside the container
WORKDIR /app

# Install system dependencies for mysqlclient in one layer
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libmariadb-dev \
    pkg-config \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements file first (optimization for caching)
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the Django project
COPY . .

# Set environment variables (optional, adjust as needed)
ENV PYTHONUNBUFFERED=1

# Expose port (default Django dev server port)
EXPOSE 8000

# Run Django development server
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]