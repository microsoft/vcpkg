FROM ubuntu:20.04

ENV DEBIAN_FRONTEND noninteractive

RUN \
  apt-get update && \
  apt-get -y upgrade && \
  apt-get -y install git

# Download Android NDK
RUN \
  apt-get -y install wget unzip && \
  wget https://dl.google.com/android/repository/android-ndk-r25b-linux.zip && \
  unzip android-ndk-r25b-linux.zip

RUN \
  apt-get -y --no-install-recommends install curl zip unzip vim pkg-config tar cmake

# For host-only dependencies
RUN \
  apt-get -y install g++

RUN \
  wget -q https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb

RUN \
  dpkg -i packages-microsoft-prod.deb && \
  rm -f packages-microsoft-prod.deb

RUN \
  apt-get -y install software-properties-common

RUN \
  apt-get update

RUN \
  add-apt-repository universe && \
  apt-get -y install powershell

# Install Azure CLI
RUN \
  curl -sL https://aka.ms/InstallAzureCLIDeb | bash

ENV ANDROID_NDK_HOME /android-ndk-r25b

WORKDIR /vcpkg