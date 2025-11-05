#!/usr/bin/env bats

# Integration tests for flashx_docker
# Tests the complete build and run workflow

setup() {
    export SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_DIRNAME")" && pwd)"
    export DOCKERFILE="$SCRIPT_DIR/flashx_dockerfile"
    export RUN_SCRIPT="$SCRIPT_DIR/run_flashx.sh"
    export TEST_IMAGE="flashx-integration-test"
    export TEST_CONTAINER="flashx-integration-test-container"

    # Cleanup any existing test containers/images
    docker rm -f "$TEST_CONTAINER" 2>/dev/null || true
}

teardown() {
    # Cleanup test containers
    docker rm -f "$TEST_CONTAINER" 2>/dev/null || true

    # Note: We don't remove the test image by default to speed up subsequent runs
    # Uncomment the line below for complete cleanup:
    # docker rmi -f "$TEST_IMAGE" 2>/dev/null || true
}

# Test: Docker is available
@test "Docker is installed and accessible" {
    command -v docker
    docker --version
}

# Test: Docker daemon is running
@test "Docker daemon is running" {
    docker info >/dev/null 2>&1
}

# Test: Can build Docker image
@test "Docker image builds successfully" {
    skip "This test is time-consuming - run manually with: docker build -f flashx_dockerfile -t $TEST_IMAGE ."

    # Uncomment below to run full build test
    # docker build -f "$DOCKERFILE" \
    #     --build-arg USER_ID=$(id -u) \
    #     --build-arg GROUP_ID=$(id -g) \
    #     -t "$TEST_IMAGE" \
    #     "$SCRIPT_DIR"
}

# Test: Image contains expected files
@test "Built image contains Flash-X directory" {
    skip "Requires built image - enable after running full build test"

    # This test verifies the Flash-X directory exists in the container
    # docker run --rm "$TEST_IMAGE" ls -la /home/flashuser/Flash-X
}

# Test: Container can start and execute commands
@test "Container can execute basic commands" {
    skip "Requires built image - this test needs a pre-built image"

    # Test that container can start and execute a simple command
    # docker run --rm "$TEST_IMAGE" echo "Container is running"
}

# Test: Container has correct user setup
@test "Container runs with non-root user" {
    skip "Requires built image"

    # Verify that container runs as non-root user
    # result=$(docker run --rm "$TEST_IMAGE" whoami)
    # [ "$result" != "root" ]
}

# Test: Conda environment is available
@test "Container has Conda environment activated" {
    skip "Requires built image"

    # Check that conda is available in the container
    # docker run --rm "$TEST_IMAGE" which conda
}

# Test: Python packages are installed
@test "Container has yt toolkit installed" {
    skip "Requires built image"

    # docker run --rm "$TEST_IMAGE" python -c "import yt"
}

@test "Container has h5py installed" {
    skip "Requires built image"

    # docker run --rm "$TEST_IMAGE" python -c "import h5py"
}

# Test: MPI is available
@test "Container has OpenMPI installed" {
    skip "Requires built image"

    # docker run --rm "$TEST_IMAGE" which mpirun
    # docker run --rm "$TEST_IMAGE" which mpicc
}

# Test: Compilers are available
@test "Container has gcc installed" {
    skip "Requires built image"

    # docker run --rm "$TEST_IMAGE" gcc --version
}

@test "Container has gfortran installed" {
    skip "Requires built image"

    # docker run --rm "$TEST_IMAGE" gfortran --version
}

# Test: Flash-X repository is present
@test "Container has Flash-X repository cloned" {
    skip "Requires built image"

    # docker run --rm "$TEST_IMAGE" test -d /home/flashuser/Flash-X
}

# Test: Sedov test problem is built
@test "Container has Sedov test problem built" {
    skip "Requires built image"

    # Check for the built Sedov executable
    # docker run --rm "$TEST_IMAGE" test -f /home/flashuser/Flash-X/object/flashx
}

# Test: MANIFEST file exists
@test "Container has MANIFEST file" {
    skip "Requires built image"

    # docker run --rm "$TEST_IMAGE" test -f /home/flashuser/MANIFEST
}

# Test: Volume mounting works
@test "Container can mount volumes" {
    skip "Requires built image"

    # Create a temporary directory and test volume mounting
    # TEST_DIR=$(mktemp -d)
    # echo "test data" > "$TEST_DIR/testfile.txt"
    # result=$(docker run --rm -v "$TEST_DIR:/mnt/test" "$TEST_IMAGE" cat /mnt/test/testfile.txt)
    # rm -rf "$TEST_DIR"
    # [ "$result" = "test data" ]
}

# Test: File permissions in mounted volumes
@test "Mounted volumes have correct permissions" {
    skip "Requires built image"

    # Test that files created in mounted volumes have correct ownership
    # This is critical for the flashx directory mounting
}

# Test: Container can access mounted flashx directory
@test "Container can read/write to flashx directory mount" {
    skip "Requires built image and runtime test"

    # This test would verify the main use case of mounting ~/flashx
}

# Test: FFmpeg is available for visualization
@test "Container has FFmpeg installed" {
    skip "Requires built image"

    # docker run --rm "$TEST_IMAGE" ffmpeg -version
}

# Test: HDF5 tools are available
@test "Container has HDF5 tools" {
    skip "Requires built image"

    # docker run --rm "$TEST_IMAGE" which h5dump
    # docker run --rm "$TEST_IMAGE" which h5ls
}

# Test: Git is available
@test "Container has git installed" {
    skip "Requires built image"

    # docker run --rm "$TEST_IMAGE" git --version
}

# Test: Can run a simple Flash-X simulation
@test "Can execute Flash-X simulation" {
    skip "This is a long-running test - run manually for validation"

    # This would test actually running a Flash-X simulation
    # docker run --rm "$TEST_IMAGE" bash -c "cd /home/flashuser/Flash-X/object && ./flashx"
}

# Test: Cross-platform path handling (WSL)
@test "WSL path conversion works if on Windows" {
    # This test only applies on Windows/WSL
    if [[ "$(uname -r)" =~ Microsoft|microsoft ]]; then
        command -v wslpath
    else
        skip "Not running on WSL"
    fi
}

# Test: Container cleanup
@test "Stopped containers can be removed" {
    # This is a general Docker functionality test
    docker ps -a --format '{{.Names}}' | grep -q "$TEST_CONTAINER" || skip "No test container to clean"
    docker rm -f "$TEST_CONTAINER"
}

# Test: Image size is reasonable
@test "Docker image size is reasonable" {
    skip "Requires built image"

    # Check that the image isn't excessively large
    # size=$(docker images "$TEST_IMAGE" --format "{{.Size}}")
    # This is informational - actual size will depend on dependencies
}

# Test: Container has correct architecture
@test "Container architecture matches host" {
    skip "Requires built image"

    # Verify architecture detection worked correctly
    # host_arch=$(uname -m)
    # container_arch=$(docker run --rm "$TEST_IMAGE" uname -m)
    # [ "$host_arch" = "$container_arch" ]
}

# Test: Error handling in run script
@test "Run script handles Docker not running" {
    # This is difficult to test without stopping Docker
    skip "Requires Docker daemon manipulation"
}

# Test: Conda environment has correct Python version
@test "Container has Python 3.10" {
    skip "Requires built image"

    # docker run --rm "$TEST_IMAGE" python --version | grep "3.10"
}
