# syntax=docker/dockerfile:1.4
# DisableDockerDetector "Used to build the container deployed to Azure Container Registry"
FROM ubuntu:noble-20260113

ADD https://packages.microsoft.com/config/ubuntu/24.04/packages-microsoft-prod.deb /packages-microsoft-prod.deb
ADD https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.18+8/OpenJDK17U-jdk_x64_linux_hotspot_17.0.18_8.tar.gz /OpenJDK17U-jdk_x64_linux_hotspot_17.0.18_8.tar.gz
ADD https://dl.google.com/android/repository/commandlinetools-linux-14742923_latest.zip /commandlinetools-linux-14742923_latest.zip
ADD https://dl.google.com/android/repository/build-tools_r36.1_linux.zip /build-tools_r36.1_linux.zip
ADD https://dl.google.com/android/repository/platform-36_r01.zip /platform-36_r01.zip
ADD https://dl.google.com/android/repository/platform-tools_r36.0.2-linux.zip /platform-tools_r36.0.2-linux.zip
ADD https://dl.google.com/android/repository/android-ndk-r29-linux.zip /android-ndk-r29-linux.zip

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
  libxcb-cursor-dev libxkbcommon-x11-dev libsm6 libsm-dev"

## PowerShell
ENV APT_PACKAGES="$APT_PACKAGES powershell azcopy"

# The BUILD_DATE argument forces cache invalidation so we get updated apt dependencies
ARG BUILD_DATE
RUN echo "Build date: ${BUILD_DATE}"

RUN <<END_OF_SCRIPT bash
set -e

export DEBIAN_FRONTEND=noninteractive

# Apt prereqs itself
apt-get -y update
apt-get -y --no-install-recommends install ca-certificates

# Add apt repos

## PowerShell
dpkg -i packages-microsoft-prod.deb
rm -f packages-microsoft-prod.deb

# Run apt things
apt-get -y update
apt-get -y dist-upgrade

apt-get -y --no-install-recommends install $APT_PACKAGES

# OpenJDK
tar xzf OpenJDK17U-jdk_x64_linux_hotspot_17.0.18_8.tar.gz
rm OpenJDK17U-jdk_x64_linux_hotspot_17.0.18_8.tar.gz

# Android SDK
unzip -q commandlinetools-linux-14742923_latest.zip -d android-sdk
rm commandlinetools-linux-14742923_latest.zip

unzip -q build-tools_r36.1_linux.zip -d android-sdk/build-tools
mv android-sdk/build-tools/android-16 android-sdk/build-tools/36.1.0
rm build-tools_r36.1_linux.zip

unzip -q platform-36_r01.zip -d android-sdk/platforms
rm platform-36_r01.zip
find android-sdk/platforms -type d -exec chmod o+rx '{}' ';'
find android-sdk/platforms -type f -exec chmod o+r '{}' ';'

unzip -q platform-tools_r36.0.2-linux.zip -d android-sdk
rm platform-tools_r36.0.2-linux.zip

# JRE for sdk setup
export JAVA_HOME=/jdk-17.0.18+8
yes | /android-sdk/cmdline-tools/bin/sdkmanager --sdk_root=/android-sdk --licenses

# Android NDK
unzip -q /android-ndk-r29-linux.zip
rm -f android-ndk-r29-linux.zip

END_OF_SCRIPT

ENV JAVA_HOME="/jdk-17.0.18+8"

ENV ANDROID_HOME="/android-sdk"

ENV ANDROID_NDK_HOME="/android-ndk-r29"

WORKDIR /vcpkg
