#!/bin/bash
# Emukit Docker Runner Script
# Copyright 2020-2024 The Emukit Authors. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
SERVICE="emukit-dev"
COMMAND=""
BUILD=false
DETACH=false
PORTS=""

# Function to display usage
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -s, --service SERVICE    Service to run (default: emukit-dev)"
    echo "                          Available: emukit, emukit-dev, emukit-test,"
    echo "                          emukit-integration-test, emukit-docs,"
    echo "                          emukit-notebook, emukit-shell"
    echo "  -c, --command COMMAND   Command to run in the container"
    echo "  -b, --build             Build images before running"
    echo "  -d, --detach            Run in detached mode"
    echo "  -p, --port PORT         Expose additional port (format: host:container)"
    echo "  -h, --help              Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                                    # Run development environment"
    echo "  $0 -s emukit-test                    # Run tests"
    echo "  $0 -s emukit-shell -c 'python -m pytest'"
    echo "  $0 -s emukit-docs -d                 # Run docs server in background"
    echo "  $0 -b -s emukit-dev                  # Build and run development environment"
}

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -s|--service)
            SERVICE="$2"
            shift 2
            ;;
        -c|--command)
            COMMAND="$2"
            shift 2
            ;;
        -b|--build)
            BUILD=true
            shift
            ;;
        -d|--detach)
            DETACH=true
            shift
            ;;
        -p|--port)
            PORTS="$PORTS -p $2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Validate service name
VALID_SERVICES=("emukit" "emukit-dev" "emukit-test" "emukit-integration-test" "emukit-docs" "emukit-notebook" "emukit-shell")
if [[ ! " ${VALID_SERVICES[@]} " =~ " ${SERVICE} " ]]; then
    print_error "Invalid service: $SERVICE"
    print_error "Valid services: ${VALID_SERVICES[*]}"
    exit 1
fi

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    print_error "Docker is not running. Please start Docker and try again."
    exit 1
fi

# Check if docker-compose is available
if ! command -v docker-compose &> /dev/null; then
    print_error "docker-compose is not installed. Please install docker-compose and try again."
    exit 1
fi

# Build if requested
if [ "$BUILD" = true ]; then
    print_status "Building Docker images..."
    docker-compose build $SERVICE
    print_success "Build completed"
fi

# Prepare docker-compose command
COMPOSE_CMD="docker-compose"

if [ "$DETACH" = true ]; then
    COMPOSE_CMD="$COMPOSE_CMD up -d"
else
    COMPOSE_CMD="$COMPOSE_CMD up"
fi

# Add custom command if provided
if [ -n "$COMMAND" ]; then
    print_status "Running service '$SERVICE' with custom command: $COMMAND"
    if [ "$DETACH" = true ]; then
        docker-compose run -d $PORTS $SERVICE $COMMAND
    else
        docker-compose run --rm $PORTS $SERVICE $COMMAND
    fi
else
    print_status "Starting service: $SERVICE"
    $COMPOSE_CMD $SERVICE
fi

# Show helpful information based on service
case $SERVICE in
    "emukit-dev")
        if [ "$DETACH" = true ]; then
            print_success "JupyterLab is running at http://localhost:8888"
        fi
        ;;
    "emukit-docs")
        if [ "$DETACH" = true ]; then
            print_success "Documentation server is running at http://localhost:8000"
        fi
        ;;
    "emukit-notebook")
        if [ "$DETACH" = true ]; then
            print_success "Jupyter Notebook is running at http://localhost:8889"
        fi
        ;;
    "emukit-test"|"emukit-integration-test")
        print_success "Test results will be available in the htmlcov directory"
        ;;
esac

# Show running containers if in detached mode
if [ "$DETACH" = true ]; then
    echo ""
    print_status "Currently running containers:"
    docker-compose ps
    echo ""
    print_status "To stop the service, run: docker-compose stop $SERVICE"
    print_status "To view logs, run: docker-compose logs -f $SERVICE"
fi
