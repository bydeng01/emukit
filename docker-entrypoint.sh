#!/bin/bash
# Emukit Docker Entrypoint Script
# Copyright 2020-2024 The Emukit Authors. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[ENTRYPOINT]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[ENTRYPOINT]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[ENTRYPOINT]${NC} $1"
}

print_error() {
    echo -e "${RED}[ENTRYPOINT]${NC} $1"
}

# Print banner
echo ""
echo "╔═══════════════════════════════════════╗"
echo "║              EMUKIT                   ║"
echo "║   Decision Making Under Uncertainty   ║"
echo "╚═══════════════════════════════════════╝"
echo ""

print_status "Initializing Emukit container..."

# Set default environment variables if not provided
export PYTHONPATH=${PYTHONPATH:-/app}
export JUPYTER_ENABLE_LAB=${JUPYTER_ENABLE_LAB:-yes}

# Verify Emukit installation
print_status "Verifying Emukit installation..."
if python -c "import emukit; print(f'Emukit version: {emukit.__version__}')" 2>/dev/null; then
    print_success "Emukit is properly installed"
else
    print_error "Emukit installation verification failed"
    exit 1
fi

# Create necessary directories
print_status "Setting up directories..."
mkdir -p /app/data
mkdir -p /app/logs
mkdir -p /app/results

# Set proper permissions for user directories
if [ "$(whoami)" = "root" ]; then
    print_warning "Running as root user"
else
    print_status "Running as user: $(whoami)"
fi

# Handle different execution modes
case "${1:-}" in
    jupyter|jupyter-lab)
        print_status "Starting Jupyter Lab..."
        exec jupyter lab \
            --ip=0.0.0.0 \
            --port=8888 \
            --no-browser \
            --allow-root \
            --NotebookApp.token='' \
            --NotebookApp.password='' \
            --NotebookApp.allow_origin='*' \
            --NotebookApp.disable_check_xsrf=True
        ;;
    jupyter-notebook)
        print_status "Starting Jupyter Notebook..."
        exec jupyter notebook \
            --ip=0.0.0.0 \
            --port=8888 \
            --no-browser \
            --allow-root \
            --NotebookApp.token='' \
            --NotebookApp.password='' \
            --NotebookApp.allow_origin='*' \
            --NotebookApp.disable_check_xsrf=True
        ;;
    test)
        print_status "Running tests..."
        exec pytest tests/ -v --cov=emukit --cov-report=html --cov-report=term
        ;;
    integration-test)
        print_status "Running integration tests..."
        exec pytest integration_tests/ -v --cov=emukit --cov-report=html --cov-report=term
        ;;
    docs)
        print_status "Building documentation..."
        cd doc
        make html
        print_status "Starting documentation server..."
        exec python -m http.server 8000 --directory _build/html
        ;;
    shell|bash)
        print_status "Starting interactive shell..."
        exec /bin/bash
        ;;
    python)
        shift
        print_status "Starting Python with args: $*"
        exec python "$@"
        ;;
    help|--help|-h)
        echo "Emukit Docker Entrypoint"
        echo ""
        echo "Usage: docker run emukit [COMMAND] [ARGS...]"
        echo ""
        echo "Commands:"
        echo "  jupyter, jupyter-lab    Start Jupyter Lab (default port 8888)"
        echo "  jupyter-notebook        Start Jupyter Notebook (default port 8888)"
        echo "  test                    Run unit tests with coverage"
        echo "  integration-test        Run integration tests with coverage"
        echo "  docs                    Build and serve documentation (default port 8000)"
        echo "  shell, bash             Start interactive bash shell"
        echo "  python [args]           Run Python with specified arguments"
        echo "  help                    Show this help message"
        echo ""
        echo "Examples:"
        echo "  docker run -p 8888:8888 emukit jupyter"
        echo "  docker run -p 8000:8000 emukit docs"
        echo "  docker run -it emukit shell"
        echo "  docker run emukit python -c 'import emukit; print(emukit.__version__)'"
        echo ""
        exit 0
        ;;
    *)
        if [ $# -eq 0 ]; then
            print_status "No command specified, starting Jupyter Lab..."
            exec jupyter lab \
                --ip=0.0.0.0 \
                --port=8888 \
                --no-browser \
                --allow-root \
                --NotebookApp.token='' \
                --NotebookApp.password='' \
                --NotebookApp.allow_origin='*' \
                --NotebookApp.disable_check_xsrf=True
        else
            print_status "Executing command: $*"
            exec "$@"
        fi
        ;;
esac
