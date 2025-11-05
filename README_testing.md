# Flash-X Docker Test Suite

This document describes the comprehensive test suite for the flashx_docker project, including unit tests, integration tests, and continuous integration workflows.

## Table of Contents

- [Overview](#overview)
- [Test Structure](#test-structure)
- [Prerequisites](#prerequisites)
- [Running Tests Locally](#running-tests-locally)
- [Test Categories](#test-categories)
- [GitHub Actions CI/CD](#github-actions-cicd)
- [Writing New Tests](#writing-new-tests)
- [Troubleshooting](#troubleshooting)

## Overview

The test suite ensures that:
- Shell scripts are syntactically correct and follow best practices
- Dockerfiles are properly formatted and secure
- Docker images build successfully
- The complete workflow functions correctly across platforms
- Security vulnerabilities are detected early

## Test Structure

```
tests/
├── run_tests.sh                   # Local test runner script
├── test_run_flashx.bats          # Unit tests for run_flashx.sh
├── test_docker_build.bats        # Unit tests for flashx_dockerfile
└── test_integration.bats         # Integration tests for complete workflow

.github/workflows/
└── ci.yml                        # GitHub Actions CI/CD pipeline

README_testing.md                  # This file
```

## Prerequisites

### Required Tools

1. **BATS** (Bash Automated Testing System)
   ```bash
   # macOS
   brew install bats-core

   # Ubuntu/Debian
   sudo apt-get install bats

   # Manual installation
   git clone https://github.com/bats-core/bats-core.git
   cd bats-core
   sudo ./install.sh /usr/local
   ```

2. **Docker**
   - Install from [docker.com](https://www.docker.com/get-started)
   - Ensure Docker daemon is running

### Optional Tools (Recommended)

3. **ShellCheck** (Shell script linter)
   ```bash
   # macOS
   brew install shellcheck

   # Ubuntu/Debian
   sudo apt-get install shellcheck

   # Or download from: https://github.com/koalaman/shellcheck
   ```

4. **Hadolint** (Dockerfile linter)
   ```bash
   # macOS
   brew install hadolint

   # Linux
   wget -O /usr/local/bin/hadolint https://github.com/hadolint/hadolint/releases/latest/download/hadolint-Linux-x86_64
   chmod +x /usr/local/bin/hadolint

   # Or use Docker
   docker pull hadolint/hadolint
   ```

## Running Tests Locally

### Quick Start

Run all tests with the automated test runner:

```bash
cd tests
./run_tests.sh
```

This script will:
1. Check for required dependencies
2. Run linters (ShellCheck, Hadolint)
3. Execute all BATS test suites
4. Provide a summary of results

### Running Individual Test Suites

Run specific test files:

```bash
# Test the shell script
bats tests/test_run_flashx.bats

# Test the Dockerfile
bats tests/test_docker_build.bats

# Run integration tests
bats tests/test_integration.bats
```

### Running Linters

```bash
# Check shell script
shellcheck run_flashx.sh

# Check Dockerfile
hadolint flashx_dockerfile
```

## Test Categories

### 1. Shell Script Tests (`test_run_flashx.bats`)

Tests for `run_flashx.sh`:
- File existence and permissions
- Syntax validation
- OS detection logic
- Docker availability checks
- UID/GID handling
- Volume mounting configuration
- WSL path conversion
- Error handling
- Security (no hardcoded credentials)

**Example tests:**
- Verifies script is executable
- Checks for proper Docker commands
- Validates environment variable usage
- Ensures cross-platform compatibility

### 2. Dockerfile Tests (`test_docker_build.bats`)

Tests for `flashx_dockerfile`:
- Base image specification
- Architecture support (x86_64, aarch64)
- Required package installation:
  - Build tools (gcc, gfortran, make, cmake)
  - MPI (OpenMPI)
  - HDF5 libraries
  - Python/Conda environment
  - Scientific packages (yt, h5py)
- Flash-X repository cloning
- User creation and permissions
- Build process validation
- Security checks

**Example tests:**
- Confirms Ubuntu base image
- Verifies all required packages are installed
- Checks for non-root user creation
- Validates MANIFEST generation

### 3. Integration Tests (`test_integration.bats`)

End-to-end workflow tests:
- Docker installation and daemon status
- Complete image build process
- Container startup and execution
- File system operations
- Volume mounting functionality
- Cross-platform compatibility
- User permission handling

**Note:** Many integration tests are skipped by default because they require:
- A fully built Docker image (time-consuming)
- Significant computational resources
- Platform-specific configurations

To enable these tests, edit `tests/test_integration.bats` and change `skip` to `run` for desired tests.

## GitHub Actions CI/CD

The project includes a comprehensive CI/CD pipeline defined in `.github/workflows/ci.yml`.

### Workflow Jobs

1. **lint-shell**: Runs ShellCheck on `run_flashx.sh`
2. **lint-dockerfile**: Runs Hadolint on `flashx_dockerfile`
3. **test-shell-script**: Executes BATS tests on Ubuntu and macOS
4. **test-dockerfile**: Validates Dockerfile structure
5. **test-integration**: Runs integration test suite
6. **docker-build-test**: Tests Docker image build (lightweight)
7. **security-scan**: Scans for vulnerabilities with Trivy
8. **validation-summary**: Aggregates all test results

### Triggering CI

The workflow runs automatically on:
- Push to `main` or `develop` branches
- Pull requests to `main` or `develop` branches
- Manual trigger via GitHub Actions UI

### Viewing Results

1. Go to the "Actions" tab in your GitHub repository
2. Click on the latest workflow run
3. View individual job results
4. Check logs for detailed error messages

### CI Configuration

The workflow uses:
- Ubuntu runners for most tests
- macOS runners for cross-platform validation
- Docker Buildx for efficient builds
- GitHub Actions cache for faster subsequent runs

## Writing New Tests

### BATS Test Structure

```bash
@test "description of test" {
    # Test commands
    run some_command
    [ "$status" -eq 0 ]
    [ "$output" = "expected output" ]
}
```

### Common BATS Assertions

```bash
# Check exit status
[ "$status" -eq 0 ]

# Check output
[ "$output" = "expected" ]

# Pattern matching
[[ "$output" =~ pattern ]]

# File existence
[ -f "/path/to/file" ]

# Command availability
command -v docker
```

### Adding Tests

1. Choose the appropriate test file:
   - Shell script behavior → `test_run_flashx.bats`
   - Dockerfile content → `test_docker_build.bats`
   - End-to-end workflow → `test_integration.bats`

2. Add a new `@test` block with a descriptive name

3. Implement the test logic

4. Run locally to verify:
   ```bash
   bats tests/test_your_file.bats
   ```

5. Commit and push to trigger CI

### Example: Adding a New Test

```bash
@test "Script handles network errors gracefully" {
    # Mock a network failure scenario
    # Test that the script provides appropriate error message
    # This is a placeholder for actual implementation
    skip "Network error handling test - implement as needed"
}
```

## Troubleshooting

### Common Issues

#### BATS Not Found
```bash
Error: bats: command not found
```
**Solution:** Install BATS using instructions in [Prerequisites](#prerequisites)

#### Docker Not Running
```bash
Error: Cannot connect to the Docker daemon
```
**Solution:** Start Docker Desktop or Docker daemon

#### Permission Denied
```bash
Error: Permission denied when accessing run_tests.sh
```
**Solution:**
```bash
chmod +x tests/run_tests.sh
```

#### Tests Fail on macOS but Pass on Linux
- Check platform-specific logic in the script
- Verify path differences (macOS vs Linux)
- Test Docker volume mounting behavior

#### Integration Tests All Skipped
- This is normal for fresh installations
- Integration tests require a built image
- Build the image first: `./run_flashx.sh`
- Then manually enable desired integration tests

### Debug Mode

Run BATS in verbose mode:
```bash
bats -t tests/test_run_flashx.bats
```

Print all commands:
```bash
bats -x tests/test_run_flashx.bats
```

### Getting Help

- Review test output carefully
- Check individual test descriptions
- Examine the actual scripts being tested
- Consult BATS documentation: https://bats-core.readthedocs.io/
- Review GitHub Actions logs for CI failures

## Best Practices

1. **Keep tests independent**: Each test should run in isolation
2. **Use descriptive names**: Test names should clearly indicate what is being tested
3. **Clean up after tests**: Use `teardown()` to remove temporary files
4. **Skip expensive tests**: Use `skip` for time-consuming integration tests in CI
5. **Test both success and failure cases**: Verify error handling
6. **Document complex tests**: Add comments explaining non-obvious test logic
7. **Run tests before committing**: Catch issues early in development

## Contributing

When adding new features to flashx_docker:

1. Write tests for new functionality
2. Ensure all existing tests pass
3. Update test documentation as needed
4. Verify CI pipeline succeeds
5. Submit pull request with tests included

## Additional Resources

- [BATS Documentation](https://bats-core.readthedocs.io/)
- [ShellCheck Wiki](https://github.com/koalaman/shellcheck/wiki)
- [Hadolint Rules](https://github.com/hadolint/hadolint#rules)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)

## Quick Reference

### Run All Tests
```bash
./tests/run_tests.sh
```

### Run Specific Test Suite
```bash
bats tests/test_run_flashx.bats      # Shell script tests
bats tests/test_docker_build.bats    # Dockerfile tests
bats tests/test_integration.bats     # Integration tests
```

### Lint Code
```bash
shellcheck run_flashx.sh             # Lint shell script
hadolint flashx_dockerfile           # Lint Dockerfile
```

### Manual CI Trigger
1. Go to GitHub repository → Actions tab
2. Select "CI" workflow
3. Click "Run workflow"
4. Choose branch and click "Run workflow"
