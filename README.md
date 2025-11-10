# ROS 2

This repository provides a Docker-based development environment for ROS 2 Jazzy.

## Overview

This Docker image provides a complete ROS 2 Jazzy environment with pre-installed navigation, sensor integration, and mathematical optimization libraries required for autonomous mobile robot development.

## Features

- **Base**: ROS 2 Jazzy Jalisco
- **Navigation Stack**: Full Nav2 suite including docking capabilities
- **Sensor Support**: RealSense cameras and SICK safety scanners
- **Mathematical Libraries**:
  - CGAL (Computational Geometry Algorithms Library) v6.0.1
  - NLopt (Nonlinear Optimization) v2.10.0
  - Boost 1.83
  - MPFR/GMP for arbitrary precision arithmetic
- **UI Framework**: FTXUI v3.0.0 for terminal-based interfaces
- **Development Tools**: vim, curl, wget, and essential build tools

## Prerequisites

- Docker installed on your system
- Basic understanding of ROS 2 and Docker

## Building the Docker Image

To build the Docker image, run:

```bash
docker build -t ros2:jazzy .
```

This will create a Docker image tagged as `ros2:jazzy` with all dependencies installed.

### Targetting a different architecture

```bash
sudo apt-get install qemu-system-arm binfmt-support qemu-user-static
docker buildx build --platform linux/arm64/v8 -t arm64v8/ros2:jazzy .
```

## Running the Container

### Basic Usage

Start an interactive container:

```bash
docker run -it --rm ros2:jazzy
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

- `navigation2` - Full navigation stack
- `nav2-bringup` - Navigation launch files
- `nav2-common` - Common navigation utilities
- `opennav-docking` - Autonomous docking capabilities
- `xacro` - XML macro processing
- `realsense2-description` - Intel RealSense camera descriptions
- `sick-safetyscanners2` - SICK safety scanner driver
- `pose-cov-ops` - Pose covariance operations
- `topic-tools` - ROS topic manipulation utilities

## Environment Variables

The following environment variables are configured:

- `ROS_DISTRO=jazzy`
- `DEBIAN_FRONTEND=noninteractive`
- `DOCKER_BUILDKIT=0`
- `COMPOSE_DOCKER_CLI_BUILD=0`
- `LC_ALL=en_US.UTF-8`
- `LANG=en_US.UTF-8`

## Entrypoint

The container uses a custom entrypoint (`ros_entrypoint.sh`) that automatically sources the ROS 2 environment:

```bash
source "/opt/ros/$ROS_DISTRO/setup.bash"
```

This ensures that all ROS 2 commands are available immediately upon starting the container.

## Development Workflow

1. **Build the image** (first time or after Dockerfile changes):
   ```bash
   docker build -t ros2:jazzy .
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

## CI/CD

This project includes GitLab CI configuration (`.gitlab-ci.yml`) for automated builds. The pipeline automatically builds the Docker image on commits.

## Additional Resources

- [ROS 2 Documentation](https://docs.ros.org/en/jazzy/)
- [Nav2 Documentation](https://navigation.ros.org/)
- [Docker Documentation](https://docs.docker.com/)

---

**ROS Version**: ROS 2 Jazzy Jalisco
**Docker Base Image**: `ros:jazzy`
