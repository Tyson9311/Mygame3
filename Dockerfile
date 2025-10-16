# Use a small, stable Python image
FROM python:3.11-slim

# Metadata
LABEL maintainer="you <your-email@example.com>"

# Avoid running as root for safety
ENV PYTHONUNBUFFERED=1 \
    POETRY_VIRTUALENVS_CREATE=false

# Create app user and working dir
RUN useradd --create-home --shell /bin/bash botuser
WORKDIR /home/botuser/app

# Copy only requirements first for better layer caching
COPY requirements.txt .

# Install system deps needed for some Python packages (if any)
RUN apt-get update \
    && apt-get install -y --no-install-recommends gcc libpq-dev build-essential curl \
    && pip install --no-cache-dir -r requirements.txt \
    && apt-get purge -y --auto-remove gcc build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy the rest of the project
COPY . .

# Fix ownership to non-root user
RUN chown -R botuser:botuser /home/botuser/app

# Switch to non-root user
USER botuser

# Expose nothing by default (bot uses outgoing connections). If needed, expose a port.
# EXPOSE 8080

# Provide env var defaults (you should override BOT_TOKEN at runtime)
ENV BOT_TOKEN=""

# Default command — run the bot script
CMD ["python", "cgb.py"]
