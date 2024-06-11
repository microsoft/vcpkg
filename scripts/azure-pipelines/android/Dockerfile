# syntax=docker/dockerfile:1.4
# DisableDockerDetector "Used to build the container deployed to Azure Container Registry"
FROM ubuntu:focal-20240530

ADD https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb /packages-microsoft-prod.deb
ADD https://dl.google.com/android/repository/android-ndk-r25c-linux.zip /android-ndk-r25c-linux.zip
ADD https://dl.google.com/android/repository/android-ndk-r26d-linux.zip /android-ndk-r26d-linux.zip

# Add apt packages

## vcpkg prerequisites
ENV APT_PACKAGES="git curl zip unzip tar"

## Common build prereqs
ENV APT_PACKAGES="$APT_PACKAGES g++ vim pkg-config cmake ca-certificates"

ENV APT_PACKAGES="$APT_PACKAGES autoconf nasm bison python2 flex build-essential libtool libtool-bin libltdl-dev gettext automake autoconf-archive"

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

# Android NDK
unzip /android-ndk-r25c-linux.zip
rm -f android-ndk-r25c-linux.zip
unzip /android-ndk-r26d-linux.zip
rm -f android-ndk-r26d-linux.zip
END_OF_SCRIPT

ENV ANDROID_NDK_HOME /android-ndk-r25c

WORKDIR /vcpkg
