#!/bin/bash

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "Docker is not running. Please start Docker and try again."
    exit 1
fi

# Determine the platform
OS=$(uname -s)

# Get the absolute path to the home directory
HOME_DIR=$(eval echo ~)

# Set the volume mount path based on the platform
if [[ "$OS" == "Linux" || "$OS" == "Darwin" ]]; then
    # Linux or macOS
    VOLUME_MOUNT="${HOME_DIR}/flashx:/home/flashuser/flashx/Flash-X/desktop"
elif [[ "$OS" == "MINGW"* || "$OS" == "CYGWIN"* || "$OS" == "MSYS"* ]]; then
    # Windows (Git Bash or similar)
    WINDOWS_PATH=$(wslpath -w "${HOME_DIR}/flashx") # Requires WSL (Windows Subsystem for Linux)
    VOLUME_MOUNT="${WINDOWS_PATH}:/home/flashuser/flashx/Flash-X/desktop"
else
    echo "Unsupported OS: $OS"
    exit 1
fi

# Define the directory path explicitly
DIR="$HOME/flashx"

# # Check if the directory exists, and create it if it doesn't
 if [ ! -d "$DIR" ]; then
   echo "Directory $DIR does not exist. Creating it now..."
   mkdir -p "$DIR"
   echo "Directory $DIR created."
 fi
# Get the current user and group

USER=$(whoami)
GROUP=$(id -gn $USER)

# Change permissions to 755
chmod 755 "$DIR"

# Change ownership to the current user and group
chown "$USER":"$GROUP" "$DIR"

# Print the updated permissions and ownership for verification
echo "Permissions and ownership of $DIR updated:"
ls -ld "$DIR"

# Build the Docker container
docker build -t flashx-app --progress=plain -f flashx_dockerfile \
        --build-arg USER_ID=$(id -u) --build-arg GROUP_ID=$(id -g)   

# Run the Docker container
docker run --rm -it \
    --name flashx-container \
    --hostname buildkitsandbox \
    -v $VOLUME_MOUNT \
    flashx-app
