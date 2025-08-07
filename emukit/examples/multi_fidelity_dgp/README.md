# Multi-Fidelity Deep Gaussian Process Examples

⚠️ **IMPORTANT NOTICE**: The examples in this directory are currently **NON-FUNCTIONAL** due to dependency incompatibilities.

## Current Status

This directory contains examples using multi-fidelity deep Gaussian processes. However, these examples require legacy dependencies that are **no longer available** in current Python package repositories:

- `tensorflow==1.8.0` (released in 2018, no longer available)
- `gpflow==1.1.1` (legacy version, no longer available)  
- `doubly_stochastic_dgp` from [UCL-SML/Doubly-Stochastic-DGP](https://github.com/UCL-SML/Doubly-Stochastic-DGP) (depends on the above)

## Why These Examples Don't Work

The `doubly_stochastic_dgp` package was developed for very old versions of TensorFlow and GPflow that:

1. Are no longer available in PyPI or conda repositories
2. Are incompatible with modern Python versions (3.8+)
3. Have known security vulnerabilities
4. Cannot be built from source on modern systems

## Recommended Alternatives

If you're interested in multi-fidelity deep Gaussian processes, consider these modern alternatives:

### 1. GPflow 2.x with Custom Implementation
- Use the latest [GPflow](https://gpflow.github.io/) (2.x) 
- Implement multi-fidelity deep GPs using modern variational inference
- See GPflow's [advanced tutorials](https://gpflow.github.io/GPflow/develop/notebooks/advanced/index.html)

### 2. GPyTorch
- [GPyTorch](https://gpytorch.ai/) has excellent support for deep GPs
- Includes modern implementations of variational inference
- Better scalability and performance

### 3. Modern Research Implementations
- Look for recent papers on multi-fidelity deep GPs with available code
- Many researchers now use JAX-based implementations for better performance

## Files in This Directory

- `multi_fidelity_deep_gp.py` - **NON-FUNCTIONAL** implementation (kept for reference)
- `malaria_data_example.ipynb` - **NON-FUNCTIONAL** example notebook (kept for reference)
- `README.md` - This file explaining the current status

## Docker Note

The Docker configuration has been updated to exclude these problematic dependencies. The containers will build successfully but these specific examples will not run.

## Contributing

If you're interested in creating a modern implementation of multi-fidelity deep GPs for Emukit using current libraries, contributions are welcome! Please see the main Emukit contributing guidelines.