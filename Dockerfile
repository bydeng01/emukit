# Multi-stage Dockerfile for Emukit
# Copyright 2020-2024 The Emukit Authors. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

# Base stage with Python and system dependencies
FROM python:3.9-slim as base

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy requirements first for better caching
COPY requirements/ requirements/
COPY setup.py pyproject.toml README.md ./
COPY emukit/__version__.py emukit/__version__.py

# Production stage
FROM base as production

# Install only production dependencies
RUN pip install --no-cache-dir -r requirements/requirements.txt

# Copy the entire application
COPY . .

# Install the package
RUN pip install --no-cache-dir -e .

# Create non-root user
RUN useradd --create-home --shell /bin/bash emukit
RUN chown -R emukit:emukit /app
USER emukit

# Default command
CMD ["python", "-c", "import emukit; print('Emukit is ready!')"]

# Development stage
FROM base as development

# Install all dependencies including dev tools
RUN pip install --no-cache-dir \
    -r requirements/requirements.txt \
    -r requirements/test_requirements.txt \
    -r requirements/integration_test_requirements.txt

# Install additional development tools
RUN pip install --no-cache-dir \
    ipython \
    jupyter \
    jupyterlab

# Copy the entire application
COPY . .

# Install the package in development mode
RUN pip install --no-cache-dir -e .

# Create non-root user
RUN useradd --create-home --shell /bin/bash emukit
RUN chown -R emukit:emukit /app
USER emukit

# Expose Jupyter port
EXPOSE 8888

# Default command for development
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root"]

# Testing stage
FROM development as testing

# Switch back to root to install additional test dependencies
USER root

# Install additional testing tools
RUN pip install --no-cache-dir pytest-xdist

# Switch back to emukit user
USER emukit

# Default command for testing
CMD ["pytest", "tests/", "-v", "--cov=emukit", "--cov-report=html", "--cov-report=term"]

# Documentation stage
FROM base as docs

# Install documentation dependencies
RUN pip install --no-cache-dir \
    -r requirements/requirements.txt \
    -r requirements/doc_requirements.txt

# Copy the entire application
COPY . .

# Install the package
RUN pip install --no-cache-dir -e .

# Create non-root user
RUN useradd --create-home --shell /bin/bash emukit
RUN chown -R emukit:emukit /app
USER emukit

# Expose documentation port
EXPOSE 8000

# Default command for documentation
CMD ["python", "-m", "http.server", "8000", "--directory", "doc/_build/html"]

# Jupyter notebook stage
FROM development as notebook

# Copy notebooks
COPY notebooks/ notebooks/

# Make sure notebooks directory is owned by emukit user
USER root
RUN chown -R emukit:emukit /app/notebooks
USER emukit

# Set working directory to notebooks
WORKDIR /app/notebooks

# Default command for notebooks
CMD ["jupyter", "notebook", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root"]
