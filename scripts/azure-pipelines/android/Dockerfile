FROM ubuntu:20.04
ENV DEBIAN_FRONTEND noninteractive

RUN \
  apt-get update && \
  apt-get -y upgrade && \
  apt-get -y --no-install-recommends install git g++ wget curl zip vim \
  pkg-config tar cmake unzip ca-certificates

# Download Android NDK
RUN \
  wget https://dl.google.com/android/repository/android-ndk-r25c-linux.zip && \
  unzip android-ndk-r25c-linux.zip && \
  rm -rf android-ndk-r25c-linux.zip

ENV ANDROID_NDK_HOME /android-ndk-r25c

# Download Powershell
RUN \
  wget -q https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb && \
  dpkg -i packages-microsoft-prod.deb && \
  rm -f packages-microsoft-prod.deb && \
  apt-get -y install software-properties-common && \
  apt-get update && \
  add-apt-repository universe && \
  apt-get -y install powershell

RUN \
  apt-get -y --no-install-recommends install autoconf nasm bison python2 \
  flex build-essential libtool libtool-bin gettext automake autoconf-archive

# python related
RUN \
  apt-get -y --no-install-recommends install python3-setuptools python3-pip python3-venv

# freeglut
RUN \
  apt-get -y --no-install-recommends install libxi-dev libgl1-mesa-dev \
  libglu1-mesa-dev mesa-common-dev libxrandr-dev libxxf86vm-dev

# glfw3
RUN \
  apt-get -y --no-install-recommends install libxinerama-dev libxcursor-dev

# required by qt5-base
RUN \
  apt-get -y --no-install-recommends install libxext-dev libxfixes-dev libxrender-dev \
  libxcb1-dev libx11-xcb-dev libxcb-glx0-dev libxcb-util0-dev \
  libxkbcommon-dev libxcb-keysyms1-dev \
  libxcb-image0-dev libxcb-shm0-dev libxcb-icccm4-dev libxcb-sync-dev \
  libxcb-xfixes0-dev libxcb-shape0-dev libxcb-randr0-dev \
  libxcb-render-util0-dev libxcb-xinerama0-dev libxcb-xkb-dev libxcb-xinput-dev \
  libxcb-cursor-dev libxkbcommon-x11-dev

WORKDIR /vcpkg