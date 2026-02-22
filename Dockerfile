# ---------------------------
# Stage 1 - Builder
# ---------------------------
FROM python:3.11-slim AS builder

WORKDIR /app

# Install build dependencies (for compiling C extensions if needed)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential gcc libffi-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy dependencies list
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt


# ---------------------------
# Stage 2 - Final runtime image
# ---------------------------
FROM python:3.11-slim

WORKDIR /app

# Security best practice: create non-root user
RUN useradd -m appuser
USER appuser

# Copy installed dependencies from builder stage
COPY --from=builder /usr/local /usr/local

# Copy application code
COPY . .

# Expose application port
EXPOSE 5000

# Run application with Gunicorn (production server)
CMD ["gunicorn", "app:app", "--bind", "0.0.0.0:5000", "--workers", "3", "--timeout", "120", "--log-level", "info"]
