#!/bin/bash

# Test runner script for flashx_docker
# This script runs all tests locally

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "========================================"
echo "Flash-X Docker Test Suite"
echo "========================================"
echo ""

# Check if BATS is installed
if ! command -v bats &> /dev/null; then
    echo -e "${RED}ERROR: BATS is not installed${NC}"
    echo "Please install BATS:"
    echo "  - macOS: brew install bats-core"
    echo "  - Linux: apt-get install bats or download from https://github.com/bats-core/bats-core"
    exit 1
fi

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}WARNING: Docker is not installed${NC}"
    echo "Some tests will be skipped"
fi

# Check if shellcheck is installed
SHELLCHECK_AVAILABLE=false
if command -v shellcheck &> /dev/null; then
    SHELLCHECK_AVAILABLE=true
    echo -e "${GREEN}✓ ShellCheck is available${NC}"
else
    echo -e "${YELLOW}! ShellCheck is not installed (optional but recommended)${NC}"
    echo "  Install: brew install shellcheck (macOS) or apt-get install shellcheck (Linux)"
fi

# Check if hadolint is installed
HADOLINT_AVAILABLE=false
if command -v hadolint &> /dev/null; then
    HADOLINT_AVAILABLE=true
    echo -e "${GREEN}✓ Hadolint is available${NC}"
else
    echo -e "${YELLOW}! Hadolint is not installed (optional but recommended)${NC}"
    echo "  Install: brew install hadolint (macOS) or download from https://github.com/hadolint/hadolint"
fi

echo ""
echo "========================================"
echo "Running Linters"
echo "========================================"
echo ""

# Run shellcheck
if [ "$SHELLCHECK_AVAILABLE" = true ]; then
    echo "Running ShellCheck on run_flashx.sh..."
    if shellcheck "$PROJECT_ROOT/run_flashx.sh"; then
        echo -e "${GREEN}✓ ShellCheck passed${NC}"
    else
        echo -e "${RED}✗ ShellCheck failed${NC}"
        exit 1
    fi
    echo ""
else
    echo -e "${YELLOW}Skipping ShellCheck (not installed)${NC}"
    echo ""
fi

# Run hadolint
if [ "$HADOLINT_AVAILABLE" = true ]; then
    echo "Running Hadolint on flashx_dockerfile..."
    # Only fail on errors, not warnings (matching CI configuration)
    if hadolint --failure-threshold error "$PROJECT_ROOT/flashx_dockerfile"; then
        echo -e "${GREEN}✓ Hadolint passed (errors only)${NC}"
    else
        echo -e "${RED}✗ Hadolint failed${NC}"
        exit 1
    fi
    echo ""
else
    echo -e "${YELLOW}Skipping Hadolint (not installed)${NC}"
    echo ""
fi

echo "========================================"
echo "Running Unit Tests"
echo "========================================"
echo ""

# Run shell script tests
echo "Running tests for run_flashx.sh..."
if bats "$SCRIPT_DIR/test_run_flashx.bats"; then
    echo -e "${GREEN}✓ Shell script tests passed${NC}"
else
    echo -e "${RED}✗ Shell script tests failed${NC}"
    exit 1
fi
echo ""

# Run Dockerfile tests
echo "Running tests for flashx_dockerfile..."
if bats "$SCRIPT_DIR/test_docker_build.bats"; then
    echo -e "${GREEN}✓ Dockerfile tests passed${NC}"
else
    echo -e "${RED}✗ Dockerfile tests failed${NC}"
    exit 1
fi
echo ""

echo "========================================"
echo "Running Integration Tests"
echo "========================================"
echo ""

# Run integration tests
echo "Running integration tests..."
if bats "$SCRIPT_DIR/test_integration.bats"; then
    echo -e "${GREEN}✓ Integration tests passed${NC}"
else
    echo -e "${RED}✗ Integration tests failed${NC}"
    exit 1
fi
echo ""

echo "========================================"
echo -e "${GREEN}All Tests Passed!${NC}"
echo "========================================"
echo ""
echo "Note: Some integration tests are skipped by default"
echo "because they require a built Docker image."
echo ""
echo "To run full integration tests:"
echo "  1. Build the image: ./run_flashx.sh"
echo "  2. Edit tests/test_integration.bats to enable tests"
echo "  3. Re-run this script"
echo ""
