# Emukit Docker Setup

This directory contains Docker configuration files for running Emukit in containerized environments.

## Quick Start

### Using the run script (Recommended)
```bash
# Start development environment with Jupyter Lab
./run.sh

# Run tests
./run.sh -s emukit-test

# Build and start development environment
./run.sh -b -s emukit-dev

# Start documentation server
./run.sh -s emukit-docs -d
```

### Using Docker Compose
```bash
# Start development environment
docker-compose up -d emukit-dev

# Run tests
docker-compose run --rm emukit-test

# Build documentation
docker-compose up -d emukit-docs
```

### Using Make
```bash
# See all available commands
make -f Makefile.docker help

# Start development environment
make -f Makefile.docker dev

# Run tests
make -f Makefile.docker test
```

## Available Services

### Production (`emukit`)
- Minimal production environment
- Only includes runtime dependencies
- Suitable for deployment

### Development (`emukit-dev`)
- Full development environment with Jupyter Lab
- All development dependencies included
- Code mounted as volume for live editing
- Available at http://localhost:8888

### Testing (`emukit-test`)
- Runs unit tests with coverage reporting
- Generates HTML coverage reports

### Integration Testing (`emukit-integration-test`)
- Runs integration tests
- Includes additional test dependencies

### Documentation (`emukit-docs`)
- Builds and serves documentation
- Available at http://localhost:8000

### Notebook (`emukit-notebook`)
- Alternative Jupyter Notebook interface
- Available at http://localhost:8889

### Shell (`emukit-shell`)
- Interactive development shell
- Full development environment with bash access

## File Structure

```
├── Dockerfile              # Multi-stage Docker build
├── docker-compose.yml      # Service orchestration
├── docker-entrypoint.sh    # Container initialization script
├── run.sh                  # Convenient runner script
├── Makefile.docker         # Make targets for common tasks
├── .dockerignore           # Files to exclude from build context
└── README.docker.md        # This documentation
```

## Usage Examples

### Development Workflow
```bash
# Start development environment
./run.sh -s emukit-dev -d

# Open browser to http://localhost:8888

# Run tests in separate terminal
./run.sh -s emukit-test

# Build documentation
./run.sh -s emukit-docs -d
```

### Testing
```bash
# Run all tests
./run.sh -s emukit-test

# Run integration tests
./run.sh -s emukit-integration-test

# Run specific test file
./run.sh -s emukit-shell -c "pytest tests/specific_test.py -v"
```

### Custom Commands
```bash
# Run Python script
./run.sh -s emukit-shell -c "python my_script.py"

# Install additional package
./run.sh -s emukit-shell -c "pip install package_name"

# Access IPython
./run.sh -s emukit-shell -c "ipython"
```

## Environment Variables

The containers support several environment variables:

- `PYTHONPATH`: Python module search path (default: /app)
- `JUPYTER_ENABLE_LAB`: Enable Jupyter Lab interface (default: yes)

## Volumes

The following volumes are created:
- `jupyter-data`: Jupyter configuration and data
- `notebook-data`: Jupyter Notebook configuration
- `test-results`: Test coverage reports
- `docs-build`: Documentation build artifacts

## Ports

Default port mappings:
- `8888`: Jupyter Lab (emukit-dev)
- `8889`: Jupyter Notebook (emukit-notebook)
- `8000`: Documentation server (emukit-docs)

## Troubleshooting

### Container won't start
```bash
# Check Docker is running
docker info

# Check logs
docker-compose logs emukit-dev

# Rebuild images
./run.sh -b -s emukit-dev
```

### Permission issues
```bash
# Fix file permissions
sudo chown -R $USER:$USER .
```

### Port conflicts
```bash
# Use different port
./run.sh -s emukit-dev -p 9999:8888
```

### Clean up
```bash
# Stop all services
docker-compose down

# Remove all containers and images
make -f Makefile.docker clean
```

## Building Custom Images

You can build specific stages:

```bash
# Build only production image
docker build --target production -t emukit:prod .

# Build development image
docker build --target development -t emukit:dev .

# Build with custom Python version
docker build --build-arg PYTHON_VERSION=3.10 .
```

## Security Notes

- Containers run as non-root user `emukit`
- Jupyter servers are configured without authentication for development
- For production use, enable proper authentication
- Use secrets for sensitive configuration

## Performance Tips

- Use `.dockerignore` to exclude unnecessary files
- Multi-stage builds minimize final image size
- Volume mounts enable live code reloading
- Use `--build-arg BUILDKIT_INLINE_CACHE=1` for better caching
