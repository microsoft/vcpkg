# syntax=docker/dockerfile:1.4
# DisableDockerDetector "Used to build the container deployed to Azure Container Registry"
FROM ubuntu:noble-20250127

ADD https://packages.microsoft.com/config/ubuntu/24.04/packages-microsoft-prod.deb /packages-microsoft-prod.deb
ADD https://builds.openlogic.com/downloadJDK/openlogic-openjdk/11.0.25+9/openlogic-openjdk-11.0.25+9-linux-x64.tar.gz /openlogic-openjdk-11.0.25+9-linux-x64.tar.gz
ADD https://dl.google.com/android/repository/commandlinetools-linux-10406996_latest.zip /sdk-commandlinetools-linux-10406996_latest.zip
ADD https://dl.google.com/android/repository/build-tools_r34-linux.zip /build-tools_r34-linux.zip
ADD https://dl.google.com/android/repository/platform-34-ext7_r03.zip /platform-34-ext7_r03.zip
ADD https://dl.google.com/android/repository/platform-tools_r35.0.1-linux.zip /platform-tools_r35.0.1-linux.zip
ADD https://dl.google.com/android/repository/android-ndk-r27c-linux.zip /android-ndk-r27c-linux.zip

# Add apt packages

## vcpkg prerequisites
ENV APT_PACKAGES="git curl zip unzip tar"

## Common build prereqs
ENV APT_PACKAGES="$APT_PACKAGES g++ vim pkg-config cmake ca-certificates"

ENV APT_PACKAGES="$APT_PACKAGES autoconf nasm bison flex build-essential libtool libtool-bin libltdl-dev gettext automake autoconf-archive"

## Python related
ENV APT_PACKAGES="$APT_PACKAGES python3-setuptools python3-pip python3-venv python3-mako python3-jinja2"

## at-spi2-atk
ENV APT_PACKAGES="$APT_PACKAGES libxtst-dev"

## freeglut
ENV APT_PACKAGES="$APT_PACKAGES libxi-dev libgl1-mesa-dev libglu1-mesa-dev mesa-common-dev libxrandr-dev libxxf86vm-dev"

# glfw3
ENV APT_PACKAGES="$APT_PACKAGES libxinerama-dev libxcursor-dev"

# qt5-base
ENV APT_PACKAGES="$APT_PACKAGES libxext-dev libxfixes-dev libxrender-dev \
  libxcb1-dev libx11-xcb-dev libxcb-glx0-dev libxcb-util0-dev \
  libxkbcommon-dev libxcb-keysyms1-dev \
  libxcb-image0-dev libxcb-shm0-dev libxcb-icccm4-dev libxcb-sync-dev \
  libxcb-xfixes0-dev libxcb-shape0-dev libxcb-randr0-dev \
  libxcb-render-util0-dev libxcb-xinerama0-dev libxcb-xkb-dev libxcb-xinput-dev \
  libxcb-cursor-dev libxkbcommon-x11-dev"

## PowerShell
ENV APT_PACKAGES="$APT_PACKAGES powershell"

RUN <<END_OF_SCRIPT bash
export DEBIAN_FRONTEND=noninteractive

# Apt prereqs itself
apt-get -y update
apt-get -y --no-install-recommends install ca-certificates

# Add apt repos

## PowerShell
dpkg -i packages-microsoft-prod.deb
rm -f packages-microsoft-prod.deb
add-apt-repository universe

# Run apt things
apt-get -y update
apt-get -y dist-upgrade

apt-get -y --no-install-recommends install $APT_PACKAGES

# OpenJDK
tar xzf openlogic-openjdk-11.0.25+9-linux-x64.tar.gz
rm openlogic-openjdk-11.0.25+9-linux-x64.tar.gz

# Android SDK
unzip -q sdk-commandlinetools-linux-10406996_latest.zip -d android-sdk
rm sdk-commandlinetools-linux-10406996_latest.zip

unzip -q build-tools_r34-linux.zip -d android-sdk/build-tools
mv android-sdk/build-tools/android-14 android-sdk/build-tools/34.0.0
rm build-tools_r34-linux.zip

unzip -q platform-34-ext7_r03.zip -d android-sdk/platforms
rm platform-34-ext7_r03.zip

unzip -q platform-tools_r35.0.1-linux.zip -d android-sdk
rm platform-tools_r35.0.1-linux.zip

# Android NDK
unzip /android-ndk-r27c-linux.zip
rm -f android-ndk-r27c-linux.zip

END_OF_SCRIPT

ENV JAVA_HOME /openlogic-openjdk-11.0.25+9-linux-x64

ENV ANDROID_HOME /android-sdk

ENV ANDROID_NDK_HOME /android-ndk-r27c

WORKDIR /vcpkg
