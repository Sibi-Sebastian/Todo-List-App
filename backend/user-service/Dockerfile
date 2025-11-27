# Use Python 3.11 Alpine for smaller image
FROM python:3.11-alpine

# Set working directory
WORKDIR /app

# Install system dependencies for mysql-connector-python
RUN apk add --no-cache \
    gcc \
    musl-dev \
    mariadb-dev \
    && rm -rf /var/cache/apk/*

# Copy requirements first for better caching
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy source code
COPY . .

# Create non-root user for security
RUN adduser -D appuser && chown -R appuser:appuser /app
USER appuser

# Expose port 3002
EXPOSE 3002

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD python -c "import requests; requests.get('http://localhost:3002/health')"

# Start the application
CMD ["python", "app.py"]
