FROM ubuntu:20.04

ENV DEBIAN_FRONTEND noninteractive

RUN \
  apt-get update && \
  apt-get -y upgrade

RUN \
  apt-get -y --no-install-recommends install git g++ wget curl zip vim pkg-config tar cmake unzip ca-certificates

# Download Android NDK
RUN \
  wget https://dl.google.com/android/repository/android-ndk-r25c-linux.zip && \
  unzip android-ndk-r25c-linux.zip

# Download Powershell
RUN \
  wget -q https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb && \
  dpkg -i packages-microsoft-prod.deb && \
  rm -f packages-microsoft-prod.deb && \
  apt-get -y install software-properties-common && \
  apt-get update && \
  add-apt-repository universe && \
  apt-get -y install powershell

# Azure CLI
RUN \
  curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Other dependencies
RUN \
  apt-get -y --no-install-recommends install autoconf nasm bison python2 flex build-essential libtool libtool-bin gettext automake

# freeglut
RUN \
  apt-get -y --no-install-recommends install libxi-dev libgl1-mesa-dev libglu1-mesa-dev mesa-common-dev libxrandr-dev libxxf86vm-dev

# glfw3
RUN \
  apt-get -y --no-install-recommends install libxinerama-dev libxcursor-dev

ENV ANDROID_NDK_HOME /android-ndk-r25c

WORKDIR /vcpkg