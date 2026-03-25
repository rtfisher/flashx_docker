# CLAUDE.md

## Project Overview

flashx_docker provides a cross-platform Docker environment for building and running [Flash-X](https://github.com/Flash-X/Flash-X), an astrophysical simulation code. The container bundles MPI (OpenMPI), HDF5, and a Conda Python environment with yt for analysis.

## Repository Structure

```
flashx_dockerfile       # Docker image definition (Ubuntu 20.04 base)
run_flashx.sh           # Cross-platform build/run launcher
tests/
  run_tests.sh          # Test runner (BATS + linters)
  test_run_flashx.bats  # Unit tests for the launcher script
  test_docker_build.bats # Dockerfile validation tests
  test_integration.bats # End-to-end integration tests
.devcontainer/
  devcontainer.json       # GitHub Codespaces / Dev Container config
.github/workflows/ci.yml # CI pipeline
```

## Common Commands

```bash
# Build and run the Docker container (main entry point)
./run_flashx.sh

# Run all tests with linters
cd tests && ./run_tests.sh

# Run individual test suites
bats tests/test_run_flashx.bats
bats tests/test_docker_build.bats
bats tests/test_integration.bats

# Lint
shellcheck run_flashx.sh
hadolint flashx_dockerfile
```

## Testing

Tests use **BATS** (Bash Automated Testing System). Install with `brew install bats-core` (macOS) or `apt-get install bats` (Linux). Optional linters: ShellCheck, Hadolint.

Integration tests that require a built Docker image are skipped by default (they take 15-30 min). The CI runs lint, shell tests, Dockerfile tests, integration tests, and a Trivy security scan.

## Code Conventions

- Shell scripts use `#!/bin/bash` and `set -e`
- Dockerfile uses `DEBIAN_FRONTEND=noninteractive` and cleans apt lists
- Container runs as non-root user `flashuser` with host UID/GID mapping; hostname is `flashx`
- Volume mount: `~/flashx` on host maps to `/home/flashuser/flashx/Flash-X/desktop` in container
- BATS tests use `@test "description" { ... }` with descriptive imperative names
- Cross-platform support: Linux, macOS, Windows (WSL2), and GitHub Codespaces
- `run_flashx.sh` detects Codespaces (`CODESPACES=true`) and skips Docker build/run
