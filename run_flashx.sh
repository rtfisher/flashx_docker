#!/bin/bash

# ------------------------------------------------------------------------------
# Script: run_flashx.sh
#
# Purpose:
#   Builds and runs the Flash-X Docker container with proper volume mounting
#   and user/group permission handling across platforms (Linux, macOS, WSL).
#
# What it does:
#   - Verifies Docker is running
#   - Determines the operating system and sets up the appropriate volume mount
#   - Ensures the host directory ($HOME/flashx) exists with the correct permissions
#   - Builds the Docker image with the user's UID and GID passed as build args
#   - Runs the Docker container with a volume mounted to the container's desktop
#
# Requirements:
#   - Docker installed and running
#   - WSL and wslpath available if running under Windows
# ------------------------------------------------------------------------------

set -e  # Exit immediately on error

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "Docker is not running. Please start Docker and try again."
    exit 1
fi

# Detect OS and set volume mount path
OS=$(uname -s)
HOME_DIR="$HOME"
MOUNT_DIR="${HOME_DIR}/flashx"
CONTAINER_MOUNT="/home/flashuser/flashx/Flash-X/desktop"

case "$OS" in
    Linux|Darwin)
        VOLUME_MOUNT="${MOUNT_DIR}:${CONTAINER_MOUNT}"
        ;;
    MINGW*|CYGWIN*|MSYS*)
        if ! command -v wslpath > /dev/null; then
            echo "wslpath not found. Please run this script inside WSL or install wslpath."
            exit 1
        fi
        WINDOWS_PATH=$(wslpath -w "$MOUNT_DIR")
        VOLUME_MOUNT="${WINDOWS_PATH}:${CONTAINER_MOUNT}"
        ;;
    *)
        echo "Unsupported operating system: $OS"
        exit 1
        ;;
esac

# Create the mount directory if it doesn't exist, and set permissions
mkdir -p "$MOUNT_DIR"
chmod 755 "$MOUNT_DIR"
chown "$(whoami):$(id -gn)" "$MOUNT_DIR"

echo "Mount directory prepared:"
ls -ld "$MOUNT_DIR"

# Build the Docker image with user and group IDs
docker build -t flashx-app --progress=plain -f flashx_dockerfile \
    --build-arg USER_ID="$(id -u)" \
    --build-arg GROUP_ID="$(id -g)" .

# Run the Docker container with the volume mount
docker run --rm -it \
    --name flashx-container \
    --hostname buildkitsandbox \
    -v "$VOLUME_MOUNT" \
    flashx-app

