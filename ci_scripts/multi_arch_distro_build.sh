#!/bin/bash

# Skip building for jazzy on jetpack-6.2, invalid configuration
if [[ $ROS_DISTRO == "jazzy" && $ARCH == "jetpack-6.2" ]]; then
    echo "Skipping invalid combination: jazzy + jetpack-6.2"
    exit 0
fi

# Check if we're running in GitHub Actions
if [[ -n "$GITHUB_ACTIONS" ]]; then
    # In GitHub Actions, Docker is already set up with buildx
    echo "Running in GitHub Actions environment"
else
    # Make sure you have a builder that supports multi‑arch
    docker buildx create --name multiarch --use
    docker buildx inspect --bootstrap    # Installs QEMU and other helpers
fi

if [[ $ROS_DISTRO == "humble" ]]; then
    BASE_IMAGE="ubuntu:22.04"
elif [[ $ROS_DISTRO == "jazzy" ]]; then
    BASE_IMAGE="ubuntu:24.04"
else
    echo -e "Unsupported ROS_DISTRO: $ROS_DISTRO! Quitting..."
    exit 1
fi

# Set the platform according to the architecture
if [[ $ARCH == "aarch64" ]]; then
    PLATFORM="linux/arm64/v8"
    BASE_IMAGE="arm64v8/$BASE_IMAGE"
elif [[ $ARCH == "x86_64" ]]; then
    PLATFORM="linux/amd64"
elif [[ $ARCH == "jetpack-6.2" ]]; then
    PLATFORM="linux/arm64/v8"
    BASE_IMAGE="nvcr.io/nvidia/l4t-jetpack:r36.4.0"
else
    PLATFORM=$ARCH
fi

# Sanitize ARCH before using it as part of the tag name – keep only letters, digits, dashes and periods,
# replace everything else with a dash
ARCH=${ARCH//[^a-zA-Z0-9.-]/-}

# Determine registry and image naming based on environment
if [[ -n "$GITHUB_ACTIONS" ]]; then
    # GitHub Actions environment variables
    REGISTRY="ghcr.io"
    REPO_OWNER=$(echo "$GITHUB_REPOSITORY" | cut -d'/' -f1)
    
    if [[ "$GITHUB_REF_NAME" == "$GITHUB_EVENT_NAME" ]]; then
        IMAGE_BASE_NAME="$REGISTRY/$REPO_OWNER"
    else
        SLUGIFIED_REF=$(echo "$GITHUB_REF_NAME" | sed 's/[^a-zA-Z0-9.-]/-/g' | tr '[:upper:]' '[:lower:]')
        IMAGE_BASE_NAME="$REGISTRY/$REPO_OWNER/$SLUGIFIED_REF"
    fi
    
    # For GitHub Actions, we'll use the standard tagging approach
    if [[ $ARCH == "x86_64" ]]; then
        IMAGE_NAME="${IMAGE_BASE_NAME}:${ROS_DISTRO}"
    else
        IMAGE_NAME="${IMAGE_BASE_NAME}:${ROS_DISTRO}-${ARCH}"
    fi
else
    # GitLab CI environment variables (original behavior)
    if [[ $CI_COMMIT_REF_NAME == $CI_DEFAULT_BRANCH ]]; then
        IMAGE_BASE_NAME=$CI_REGISTRY_IMAGE
    else
        IMAGE_BASE_NAME="${CI_REGISTRY_IMAGE}/${CI_COMMIT_REF_SLUG}"
    fi

    if [[ $ARCH == "x86_64" ]]; then
        IMAGE_NAME="${IMAGE_BASE_NAME}:${ROS_DISTRO}"
    else
        IMAGE_NAME="${IMAGE_BASE_NAME}:${ROS_DISTRO}-${ARCH}"
    fi
fi

# Login to the registry
if [[ -n "$GITHUB_ACTIONS" ]]; then
    echo "$GITHUB_TOKEN" | docker login -u $GITHUB_ACTOR --password-stdin $REGISTRY
else
    echo "$REGISTRY_PWD" | docker login -u $REGISTRY_USER --password-stdin $CI_REGISTRY
fi

# Build and push the image
docker buildx build \
    --platform $PLATFORM \
    --build-arg ROS_DISTRO=$ROS_DISTRO \
    --build-arg BASE_IMAGE=$BASE_IMAGE \
    -t $IMAGE_NAME \
    --push .
