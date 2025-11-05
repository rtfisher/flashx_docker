# flashx_docker

[![CI](https://github.com/rtfisher/flashx_docker/actions/workflows/ci.yml/badge.svg)](https://github.com/rtfisher/flashx_docker/actions/workflows/ci.yml)

This repository contains a cross-platform Docker environment for building and running the [Flash-X](https://github.com/Flash-X/Flash-X) astrophysical simulation code. It ensures consistent user and group ID mappings, portable development, and volume mounting behavior across Linux, macOS, and Windows (via WSL2).

## Features

- Reproducible environment for Flash-X development and execution
- Automatic installtion of requisite MPI and HDF5 libraries
- Conda Python environment with yt toolkit for analysis of Flash-X data
- Linux UID/GID mapping to maintain correct file ownership on host
- Automatically mounts a user directory to the container desktop
- Compatible with Linux, macOS, and Windows (via WSL2)
- Simplified launch script for one-step build and run

## Requirements

- [Docker](https://www.docker.com/) (with WSL2 backend if using Windows)
- Bash (included in Linux/macOS and in WSL for Windows)
- `wslpath` available on Windows systems
- Git (optional but recommended for cloning the repository)

## Setup

Clone this repository:

```bash
git clone https://github.com/rtfisher/flashx_docker.git
cd flashx_docker
```

Ensure the `run_flashx.sh` script is executable:

```bash
chmod +x run_flashx.sh
```

> 📝 Note: Windows users must run this from a WSL2 shell (e.g., Ubuntu terminal on Windows).

## Usage

### Linux / macOS / Windows (WSL2)

```bash
./run_flashx.sh
```

This will:

1. Ensure Docker is running.
2. Create a `~/flashx` directory if it doesn't exist.
3. Set the proper permissions for mounting.
4. Build the `flashx-app` Docker image with your user and group ID.
5. Run the container with your host's `~/flashx` directory mounted to:

```
/home/flashuser/flashx/Flash-X/desktop
```

## Directory Structure

```
flashx_docker/
├── flashx_dockerfile        # Dockerfile defining the container environment
├── run_flashx.sh            # Cross-platform build-and-run launcher
├── README.md                # This file
```

## Inside the Container

The container is run as a non-root user (`flashuser`) with the same UID and GID as the host. The host directory `~/flashx` is mounted inside the container at:

```
/home/flashuser/flashx/Flash-X/desktop
```

This allows you to easily move results from the container to the host environment and vice versa while avoiding permission conflicts.

## Troubleshooting

- **Docker not found or not running?**
  Make sure Docker Desktop is installed and started, and that WSL2 is installed and configured if on Windows.

- **wslpath not found (Windows)?**
  Make sure you're running the script from within a WSL2 shell (not cmd.exe or PowerShell).

- **Permission errors when accessing mounted volumes?**
  The script uses `chown` and UID/GID mapping to match the host user. If issues persist, ensure your Docker Desktop is using WSL2 and not Hyper-V mode.

## License

MIT License. See [LICENSE](LICENSE) file for details.

## Acknowledgments

This setup is inspired by cross-platform Docker workflows for scientific computing. Flash-X is developed and maintained by the Flash Center for Computational Science.
