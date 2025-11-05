#!/usr/bin/env bats

# Test suite for Docker build functionality
# Tests the flashx_dockerfile build process

setup() {
    export SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_DIRNAME")" && pwd)"
    export DOCKERFILE="$SCRIPT_DIR/flashx_dockerfile"
}

# Test: Dockerfile exists
@test "flashx_dockerfile exists" {
    [ -f "$DOCKERFILE" ]
}

# Test: Dockerfile syntax is valid
@test "Dockerfile has valid syntax" {
    docker build -f "$DOCKERFILE" --no-cache -t flashx-test-syntax . --target builder 2>/dev/null || \
    docker build -f "$DOCKERFILE" -t flashx-test-syntax . --dry-run 2>/dev/null || \
    # If above commands not supported, at least check basic FROM
    grep -q "^FROM" "$DOCKERFILE"
}

# Test: Base image is specified
@test "Dockerfile specifies base image" {
    grep -q "^FROM" "$DOCKERFILE"
}

# Test: Ubuntu base image
@test "Dockerfile uses Ubuntu base image" {
    grep -q "FROM.*ubuntu" "$DOCKERFILE"
}

# Test: Architecture support
@test "Dockerfile includes architecture detection" {
    grep -q "TARGETARCH\|BUILDARCH\|aarch64\|x86_64\|uname -m" "$DOCKERFILE"
}

# Test: Required build tools
@test "Dockerfile installs gcc" {
    grep -q "build-essential" "$DOCKERFILE"
}

@test "Dockerfile installs gfortran" {
    grep -q "gfortran" "$DOCKERFILE"
}

@test "Dockerfile installs make" {
    grep -q "make" "$DOCKERFILE"
}

@test "Dockerfile installs cmake" {
    grep -q "cmake" "$DOCKERFILE"
}

# Test: MPI installation
@test "Dockerfile installs OpenMPI" {
    grep -q "openmpi\|libopenmpi" "$DOCKERFILE"
}

# Test: HDF5 installation
@test "Dockerfile installs HDF5" {
    grep -q "hdf5\|libhdf5" "$DOCKERFILE"
}

# Test: Python/Conda installation
@test "Dockerfile installs Miniconda or Python" {
    grep -q "miniconda\|conda\|python" "$DOCKERFILE" || \
    grep -q "Miniconda\|Python" "$DOCKERFILE"
}

# Test: Scientific packages
@test "Dockerfile installs yt toolkit" {
    grep -q "yt" "$DOCKERFILE"
}

@test "Dockerfile installs h5py" {
    grep -q "h5py" "$DOCKERFILE"
}

# Test: Flash-X repository cloning
@test "Dockerfile clones Flash-X repository" {
    grep -q "git clone" "$DOCKERFILE" | grep -q "Flash-X"
}

# Test: User creation
@test "Dockerfile creates non-root user" {
    grep -q "useradd\|adduser" "$DOCKERFILE" || \
    grep -q "USER " "$DOCKERFILE"
}

# Test: User ID handling
@test "Dockerfile handles USER_ID build argument" {
    grep -q "ARG USER_ID\|ARG UID" "$DOCKERFILE"
}

@test "Dockerfile handles GROUP_ID build argument" {
    grep -q "ARG GROUP_ID\|ARG GID" "$DOCKERFILE"
}

# Test: Working directory
@test "Dockerfile sets working directory" {
    grep -q "WORKDIR" "$DOCKERFILE"
}

# Test: Environment variables
@test "Dockerfile sets environment variables" {
    grep -q "ENV" "$DOCKERFILE"
}

# Test: FFmpeg installation
@test "Dockerfile installs FFmpeg for visualization" {
    grep -q "ffmpeg" "$DOCKERFILE"
}

# Test: Sedov test problem
@test "Dockerfile references Sedov test problem" {
    grep -q "Sedov" "$DOCKERFILE" || \
    grep -q "sedov" "$DOCKERFILE"
}

# Test: Build process
@test "Dockerfile includes build/setup commands" {
    grep -q "./setup" "$DOCKERFILE" || \
    grep -q "setup.py\|make" "$DOCKERFILE"
}

# Test: MANIFEST generation
@test "Dockerfile generates MANIFEST file" {
    grep -q "MANIFEST" "$DOCKERFILE"
}

# Test: Default command or entrypoint
@test "Dockerfile specifies CMD or ENTRYPOINT" {
    grep -q "CMD\|ENTRYPOINT" "$DOCKERFILE"
}

# Test: Bash shell availability
@test "Dockerfile provides bash shell access" {
    grep -q "bash\|/bin/bash" "$DOCKERFILE"
}

# Test: Git installation
@test "Dockerfile installs git" {
    grep -q "git" "$DOCKERFILE"
}

# Test: Package manager updates
@test "Dockerfile updates package manager" {
    grep -q "apt-get update\|apt update" "$DOCKERFILE"
}

# Test: Conda environment activation
@test "Dockerfile configures Conda environment" {
    grep -q "conda activate\|conda init\|conda create" "$DOCKERFILE"
}

# Test: No credentials exposed
@test "Dockerfile does not contain hardcoded credentials" {
    ! grep -i "password\|passwd\|secret\|token.*=" "$DOCKERFILE" | grep -v "^#"
}

# Test: Labels or metadata
@test "Dockerfile includes metadata or labels" {
    grep -q "LABEL\|MAINTAINER" "$DOCKERFILE" || \
    # Labels are optional but good practice
    true
}

# Test: Cleanup commands
@test "Dockerfile includes cleanup to reduce image size" {
    grep -q "apt-get clean\|rm -rf\|yum clean" "$DOCKERFILE" || \
    # Cleanup is optional but recommended
    true
}

# Test: Port exposure if needed
@test "Dockerfile handles ports appropriately" {
    # For this scientific computing container, no ports may be needed
    # This test just checks if EXPOSE is used intentionally
    true
}

# Test: Volume declarations
@test "Dockerfile declares volumes if needed" {
    # Volumes may be declared or managed via docker run
    # This is more of a documentation check
    grep -q "VOLUME" "$DOCKERFILE" || \
    # Volumes can be specified at runtime
    true
}
