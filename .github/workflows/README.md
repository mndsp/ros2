# GitHub Actions CI Setup

This document explains how to set up and use the GitHub Actions CI pipeline for building Docker images.

## Workflow Overview

The GitHub Actions workflow replicates the functionality of the GitLab CI pipeline:

- Builds Docker images for multiple ROS distributions (humble, jazzy)
- Supports multiple hardware architectures (aarch64, x86_64)
- Uses matrix strategy for parallel builds
- Pushes images to GitHub Container Registry (GHCR)

## Setup Instructions

1. **Enable GitHub Actions**:
   - Go to your repository settings
   - Ensure GitHub Actions is enabled

2. **Configure Secrets** (if needed):
   - The workflow uses `GITHUB_TOKEN` which is automatically provided
   - No additional secrets are required for GHCR authentication

3. **Triggering Builds**:
   - Push to main/master branch
   - Create a pull request to main/master branch
   - Manually trigger using workflow_dispatch

## Customizing Builds

You can customize the ROS distributions and hardware targets when manually triggering the workflow:

- `ros_distros`: Comma-separated list of ROS distributions (default: humble,jazzy)
- `hw_targets`: Comma-separated list of hardware targets (default: aarch64,x86_64)

## Image Naming

Images are pushed to GHCR with the following naming convention:
- For main branch: `ghcr.io/<owner>/<repo>:<ros_distro>[-<arch>]`
- For other branches: `ghcr.io/<owner>/<repo>/<branch>:<ros_distro>[-<arch>]`

Examples:
- `ghcr.io/username/repo:humble`
- `ghcr.io/username/repo:humble-aarch64`
