#!/bin/bash

# Skip building for jazzy on jetpack-6.2, invalid configuration
if [[ $ROS_DISTRO == "jazzy" && $ARCH == "jetpack-6.2" ]]; then
  exit 0
fi

# Make sure you have a builder that supports multi‑arch
docker buildx create --name multiarch --use
docker buildx inspect --bootstrap    # Installs QEMU and other helpers

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

if [[ $CI_COMMIT_REF_NAME == $CI_DEFAULT_BRANCH ]]; then
  if [[ $ARCH == "x86-64" ]]; then
    IMAGE_NAME="$CI_REGISTRY_IMAGE:${ROS_DISTRO}"
  else
    IMAGE_NAME="$CI_REGISTRY_IMAGE:${ROS_DISTRO}-${ARCH}"
  fi
else
  IMAGE_NAME="$CI_REGISTRY_IMAGE/$CI_COMMIT_REF_SLUG:${ROS_DISTRO}-${ARCH}"
fi

# Login to the registry
echo "$REGISTRY_PWD" | docker login -u $REGISTRY_USER --password-stdin $CI_REGISTRY

# Build and push the image
docker buildx build \
  --platform $PLATFORM \
  --build-arg ROS_DISTRO=$ROS_DISTRO \
  --build-arg BASE_IMAGE=$BASE_IMAGE \
  -t $IMAGE_NAME \
  -t ${CI_REGISTRY_IMAGE}:${CI_JOB_ID} \
  --push .
