FROM ros:rolling

# Arguments
ARG user
ARG uid
ARG home
ARG workspace
ARG shell

# Basic Utilities
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get -y update \
  && apt-get install -y apt-utils \
  && apt-get install -y \
    build-essential \
    gdb \
    gnupg2 \
    htop \
    iproute2 \
    iputils-ping \
    ipython3 \
    less \
    libncurses5-dev \
    locales \
    ranger \
    screen \
    ssh \
    sudo \
    synaptic \
    tig \
    tmux \
    tree \
    uvcdynctrl \
    vim \
    vlc \
    wget \
    x11-apps \
    zsh

# Setup locale
RUN echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen \
  && locale-gen \
  && update-locale LANG=en_US.UTF-8 \
  && ln -s /usr/bin/python3 /usr/bin/python

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Setup packages.bit-bots.de repository
RUN mkdir -p /usr/local/share/keyrings \
  && wget https://packages.bit-bots.de/key.asc -O /usr/local/share/keyrings/bitbots.key \
  && echo 'deb [signed-by=/usr/local/share/keyrings/bitbots.key arch=amd64] https://packages.bit-bots.de jammy main' > /etc/apt/sources.list.d/bitbots.list \
  && apt update \
  && apt upgrade -y --allow-downgrades

# Prioritize packages.bit-bots.de
RUN echo 'Package: *' >> /etc/apt/preferences.d/package-bit-bots.pref \
  && echo 'Pin: origin "packages.bit-bots.de"' >> /etc/apt/preferences.d/package-bit-bots.pref \
  && echo 'Pin-Priority: 1000' >> /etc/apt/preferences.d/package-bit-bots.pref \
  && apt update \
  && apt upgrade -y --allow-downgrades

# Additional custom dependencies
RUN apt-get install -y \
  espeak \
  ffmpeg \
  libespeak-dev \
  libfmt-dev \
  librange-v3-dev \
  librostest-dev \
  libtf-conversions-dev \
  liburdfdom-dev \
  libyaml-cpp-dev \
  llvm \
  protobuf-compiler \
  python3-colcon-common-extensions \
  python3-colcon-ed \
  python3-construct \
  python3-pip \
  python3-protobuf \
  python3-pybind11 \
  python3-rosdep \
  radeontop \
  ros-rolling-ament-cmake-nose \
  ros-rolling-camera-calibration \
  ros-rolling-camera-info-manager \
  ros-rolling-controller-manager \
  ros-rolling-desktop \
  ros-rolling-diagnostic-aggregator \
  ros-rolling-effort-controllers \
  ros-rolling-gazebo-msgs \
  ros-rolling-image-proc \
  ros-rolling-joint-state-broadcaster \
  ros-rolling-joint-state-publisher-gui \
  ros-rolling-joint-trajectory-controller \
  ros-rolling-joy-linux \
  ros-rolling-moveit-planners-ompl \
  ros-rolling-moveit-ros \
  ros-rolling-moveit-simple-controller-manager \
  ros-rolling-nav2-bringup \
  # ros-rolling-plotjuggler-ros containing plotjuggler ros plugins
  # build currently fails and is not available as a package so we
  # have to manually install plotjuggler and plotjuggler-msgs
  # https://github.com/PlotJuggler/plotjuggler-ros-plugins/issues/59
  ros-rolling-plotjuggler \
  ros-rolling-plotjuggler-msgs \
  ros-rolling-position-controllers \
  ros-rolling-rmw-cyclonedds-cpp \
  ros-rolling-robot-localization \
  ros-rolling-rot-conv \
  ros-rolling-rqt-robot-monitor \
  ros-rolling-soccer-vision-2d-msgs \
  ros-rolling-soccer-vision-3d-rviz-markers \
  ros-rolling-test-msgs \
  ros-rolling-tf-transformations \
  ros-rolling-transmission-interface \
  ros-rolling-velocity-controllers \
  && pip3 install pip -U \
  && python3 -m pip install git+https://github.com/ruffsl/colcon-clean

# Mount the user's home directory
VOLUME "${home}"

# Clone user into docker image and set up X11 sharing
RUN \
  echo "${user}:x:${uid}:${uid}:${user},,,:${home}:${shell}" >> /etc/passwd \
  && echo "${user}:*::0:99999:0:::" >> /etc/shadow \
  && echo "${user}:x:${uid}:" >> /etc/group \
  && echo "${user} ALL=(ALL) NOPASSWD: ALL" >> "/etc/sudoers"

# Switch to user
USER "${user}"
# This is required for sharing Xauthority
ENV QT_X11_NO_MITSHM=1
# Switch to the workspace
WORKDIR ${workspace}
