FROM nvcr.io/nvidia/l4t-jetpack:r36.4.0

# Avoid user interaction with tzdata
ENV DEBIAN_FRONTEND=noninteractive

# Setup an user
ARG C_USER=ubuntu
ARG C_UID=1000
ARG C_GID=1000

# Life is better with colors
RUN sed -i 's/^#force_color_prompt=yes/force_color_prompt=yes/' /etc/skel/.bashrc && \
    sed -i 's/^#force_color_prompt=yes/force_color_prompt=yes/' /root/.bashrc && \
    groupadd -g $C_GID $C_USER && \
    useradd -m -d /home/$C_USER -g $C_GID -s /bin/bash -u $C_UID $C_USER && \
    usermod -aG plugdev $C_USER && \
    usermod -aG video $C_USER && \
    usermod -aG dialout $C_USER && \
    sed -i 's/^#force_color_prompt=yes/force_color_prompt=yes/' /home/$C_USER/.bashrc && \
    echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> /home/$C_USER/.bashrc

# Distribution of ROS2
ARG ROS_DISTRO=humble

# Set the locale and lsb-release needed by dpkg --print-architecture
RUN apt-get update && apt-get install -y --no-install-recommends \
    locales \
    lsb-release \
    curl \
    && locale-gen en_US en_US.UTF-8 \
    && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 \
    && curl http://repo.ros2.org/repos.key | apt-key add - \
    && sh -c 'echo "deb [arch=$(dpkg --print-architecture)] http:packages.ros.org/ros2/ubuntu `lsb_release -cs` main" > /etc/apt/sources.list.d/ros2-latest.list' \
    && apt-get update && apt-get install -y --no-install-recommends \
    vim \
    bluez \
    wget \
    git \
    libmpfr-dev \
    libmpfrc++-dev \
    libgmp-dev \
    rapidjson-dev \
    software-properties-common \
    cmake \
    ros-$ROS_DISTRO-ros-base \
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
    ros-$ROS_DISTRO-rqt-tf-tree \
    python3-colcon-common-extensions \
    python3-rosdep \
    python3-argcomplete \
    && apt-get clean all \
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
