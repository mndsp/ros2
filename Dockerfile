# Use ros jazzy as base image
FROM ros:jazzy

# Avoid user interaction with tzdata
ENV DEBIAN_FRONTEND=noninteractive

# Export environment variables
ENV DOCKER_BUILDKIT=0
ENV COMPOSE_DOCKER_CLI_BUILD=0

# Life is better with colors
RUN sed -i 's/^#force_color_prompt=yes/force_color_prompt=yes/' /etc/skel/.bashrc && \
    sed -i 's/^#force_color_prompt=yes/force_color_prompt=yes/' /root/.bashrc && \
    sed -i 's/^#force_color_prompt=yes/force_color_prompt=yes/' /home/ubuntu/.bashrc

# Set the locale
RUN apt-get update && apt-get install -y --no-install-recommends \
    locales \
    && rm -rf /var/lib/apt/lists/* \
    && locale-gen en_US en_US.UTF-8 \
    && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

# Set up the ROS 2 environment
ENV ROS_DISTRO=jazzy

# Update and install necessary tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    vim \
    bluez \
    wget \
    libmpfr-dev \
    libmpfrc++-dev \
    libgmp-dev \
    rapidjson-dev \
    software-properties-common \
    ros-$ROS_DISTRO-navigation2 \
    ros-$ROS_DISTRO-nav2-bringup \
    ros-$ROS_DISTRO-nav2-common \
    ros-$ROS_DISTRO-opennav-docking \
    ros-$ROS_DISTRO-xacro \
    ros-$ROS_DISTRO-realsense2-description \
    ros-$ROS_DISTRO-sick-safetyscanners2 \
    ros-$ROS_DISTRO-pose-cov-ops \
    ros-$ROS_DISTRO-topic-tools \
    ros-$ROS_DISTRO-mola-lidar-odometry \
    ros-$ROS_DISTRO-mola-metric-maps \
    ros-$ROS_DISTRO-mola-bridge-ros2 \
    && rm -rf /var/lib/apt/lists/*

# Install Lib CGAL
RUN cd /tmp \
    && git clone --depth 1 -b v6.0.1 https://github.com/CGAL/cgal.git \
    && cd cgal \
    && mkdir build \
    && cd build \
    && cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX:PATH=/usr/local \
    && make -j$(nproc) \
    && make install \
    && cd /tmp \
    && rm -rf /tmp/cgal

# Install Lib NLOpt
RUN cd /tmp \
    && git clone --depth 1 -b v2.10.0 https://github.com/stevengj/nlopt.git \
    && cd nlopt \
    && mkdir build \
    && cd build \
    && cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX:PATH=/usr/local \
    && make -j$(nproc) \
    && make install \
    && cd /tmp \
    && rm -rf /tmp/nlopt

# Install boost 1.83 which fixes some header deprecation warnings
RUN add-apt-repository ppa:mhier/libboost-latest \
    && apt-get update \
    && apt-get install -y --no-install-recommends libboost1.83-all-dev \
    && rm -rf /var/lib/apt/lists/*

# Install FTXUI
RUN cd /tmp \
    && git clone --depth 1 https://github.com/ArthurSonzogni/FTXUI.git -b v3.0.0 \
    && cd FTXUI \
    && mkdir build \
    && cd build \
    && cmake .. -DCMAKE_INSTALL_PREFIX:PATH=/usr/local \
    && make -j$(nproc) \
    && make install \
    && rm -rf /tmp/FTXUI

# setup entrypoint
COPY ./ros_entrypoint.sh /

ENTRYPOINT ["/ros_entrypoint.sh"]

# Set the default command to bash
CMD ["bash"]
