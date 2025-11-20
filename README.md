# ROS 2 Docker Development Environment

[![Build Docker Images](https://github.com/mndsp/ros2/actions/workflows/build.yml/badge.svg)](https://github.com/mndsp/ros2/actions/workflows/build.yml)

This repository provides a comprehensive Docker-based development environment for ROS 2, supporting multiple distributions and architectures. It's designed for autonomous mobile robot development with pre-installed navigation, sensor integration, and mathematical optimization libraries.

## Overview

This project offers a complete ROS 2 environment in Docker containers, making it easy to develop, test, and deploy robotics applications without complex local setup. The images include essential packages for navigation, sensor integration, and mathematical computing.

## Supported ROS Distributions

- **ROS 2 Humble** (Ubuntu 22.04 base)
- **ROS 2 Jazzy** (Ubuntu 24.04 base)

## Supported Architectures

- x86_64 (amd64)
- aarch64 (arm64)
- Jetpack 6.2 (NVIDIA Jetson platforms)

## Key Features

- **Base**: Ubuntu with full ROS 2 installation
- **Navigation Stack**: Full Nav2 suite including docking capabilities
- **Sensor Support**: RealSense cameras and SICK safety scanners
- **Mathematical Libraries**:
  - CGAL (Computational Geometry Algorithms Library) v6.0.1
  - NLopt (Nonlinear Optimization) v2.10.0
  - FTXUI v3.0.0 for terminal-based interfaces
- **Development Tools**: vim, curl, wget, colcon, and essential build tools
- **Multi-architecture Support**: Build for different CPU architectures
- **CI/CD Ready**: Automated builds with GitLab CI and GitHub Actions

## Prerequisites

- Docker installed on your system
- Basic understanding of ROS 2 and Docker
- For multi-architecture builds: Docker Buildx

## Building the Docker Image

### Basic Build

To build the Docker image for your native architecture:

```bash
docker build -t ros2:humble --build-arg ROS_DISTRO=humble .
docker build -t ros2:jazzy --build-arg ROS_DISTRO=jazzy .
```

### Targeting Specific Architectures

For cross-platform builds, you'll need to set up Docker Buildx:

```bash
# Create a new builder instance
docker buildx create --name multiarch --use
docker buildx inspect --bootstrap
```

Then build for specific platforms:

```bash
# Build for aarch64
docker buildx build --platform linux/arm64/v8 -t ros2:jazzy-aarch64 --build-arg ROS_DISTRO=jazzy .

# Build for x86_64
docker buildx build --platform linux/amd64 -t ros2:jazzy-amd64 --build-arg ROS_DISTRO=jazzy .
```

## Running the Container

### Basic Usage

Start an interactive container:

```bash
docker run -it --rm ros2:jazzy bash
```

### With Mounted Workspace

Mount your local workspace into the container:

```bash
docker run -it --rm \
  -v /path/to/your/workspace:/workspace \
  ros2:jazzy
```

### With Network Access

For robots requiring network connectivity:

```bash
docker run -it --rm \
  --network host \
  ros2:jazzy
```

### With GUI Support

For applications requiring graphical interfaces:

```bash
docker run -it --rm \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  ros2:jazzy
```

## Installed ROS 2 Packages

Core navigation and robotics packages:
- `navigation2` - Full navigation stack
- `nav2-bringup` - Navigation launch files
- `nav2-common` - Common navigation utilities
- `opennav-docking` - Autonomous docking capabilities
- `xacro` - XML macro processing

Sensor integration packages:
- `realsense2-description` - Intel RealSense camera descriptions
- `sick-safetyscanners2` - SICK safety scanner driver
- `librealsense2` - Intel RealSense library

Utility packages:
- `pose-cov-ops` - Pose covariance operations
- `topic-tools` - ROS topic manipulation utilities
- `rqt-tf-tree` - Visualization of TF tree

Additional packages:
- `mola-lidar-odometry` - LiDAR odometry
- `mola-metric-maps` - Metric mapping
- `mola-bridge-ros2` - MOLA to ROS 2 bridge

## Environment Variables

The following environment variables are configured:

- `ROS_DISTRO` - Set to the target ROS distribution (humble/jazzy)
- `DEBIAN_FRONTEND=noninteractive` - Non-interactive package installation
- `LC_ALL=en_US.UTF-8` - UTF-8 locale
- `LANG=en_US.UTF-8` - UTF-8 language

## Entrypoint

The container uses a custom entrypoint (`ros_entrypoint.sh`) that automatically sources the ROS 2 environment:

```bash
source "/opt/ros/$ROS_DISTRO/setup.bash"
```

This ensures that all ROS 2 commands are available immediately upon starting the container.

## Development Workflow

1. **Build the image** (first time or after Dockerfile changes):
   ```bash
   docker build -t ros2:jazzy --build-arg ROS_DISTRO=jazzy .
   ```

2. **Start the container**:
   ```bash
   docker run -it --rm -v $(pwd)/workspace:/workspace ros2:jazzy
   ```

3. **Inside the container**, your ROS 2 environment is ready:
   ```bash
   ros2 --help
   colcon build
   ```

## CI/CD Automation

This project includes automated build pipelines for both GitLab CI and GitHub Actions:

### GitLab CI

The `.gitlab-ci.yml` file configures automated builds for multiple ROS distributions and architectures using a matrix strategy.

### GitHub Actions

The workflow in `.github/workflows/build.yml` provides equivalent functionality:
- Builds for multiple ROS distributions (humble, jazzy)
- Supports multiple architectures (aarch64, x86_64)
- Pushes images to GitHub Container Registry (GHCR)
- Runs on push, pull requests, and manual triggers

Images are automatically tagged based on the branch:
- Main branch: `ghcr.io/<owner>/<repo>:<ros_distro>[-<arch>]`
- Feature branches: `ghcr.io/<owner>/<repo>/<branch>:<ros_distro>[-<arch>]`

## Customization

You can customize the base image by modifying the `BASE_IMAGE` build argument:

```bash
docker build --build-arg BASE_IMAGE=ubuntu:22.04 -t ros2:custom .
```

## Additional Resources

- [ROS 2 Documentation](https://docs.ros.org/en/jazzy/)
- [Nav2 Documentation](https://navigation.ros.org/)
- [Docker Documentation](https://docs.docker.com/)

---

**ROS Version**: ROS 2 Humble/Jazzy
**Docker Base Image**: Ubuntu 22.04/24.04
