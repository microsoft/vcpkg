#!/bin/bash
# Regenerates gradle-artifacts.cmake in a container with JDK 17 and the Android SDK packages
# used by scripts/azure-pipelines/android/Dockerfile.
#
# Usage: generate-in-docker.sh <qtbase-everywhere-src-X.Y.Z.tar.xz> [work-dir]
set -euo pipefail

if [ $# -lt 1 ] || [ ! -f "$1" ]; then
    echo "usage: $0 <qtbase-everywhere-src-X.Y.Z.tar.xz> [work-dir]" >&2
    exit 1
fi
port_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
tarball="$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
work_dir="${2:-$(mktemp -d)}"
mkdir -p "$work_dir"
work_dir="$(cd "$work_dir" && pwd)"

docker run --rm \
    -v "$port_dir:/port" \
    -v "$tarball:/qtbase.tar.xz:ro" \
    -v "$work_dir:/work" \
    -e HOST_UID="$(id -u)" -e HOST_GID="$(id -g)" \
    eclipse-temurin:17-jdk-noble bash -c '
set -euo pipefail
trap "chown -R \$HOST_UID:\$HOST_GID /work /port/gradle-artifacts.cmake" EXIT
export DEBIAN_FRONTEND=noninteractive
apt-get -y update > /dev/null
apt-get -y --no-install-recommends install python3 unzip curl ca-certificates xz-utils cmake > /dev/null

rm -rf /work/*
mkdir -p /work/src /work/dl /android-sdk/build-tools /android-sdk/platforms
tar xf /qtbase.tar.xz -C /work/src
qtbase="$(echo /work/src/qtbase-*)"

cd /work/dl
curl -fsSLO https://dl.google.com/android/repository/commandlinetools-linux-16111833_latest.zip
curl -fsSLO https://dl.google.com/android/repository/build-tools_r37_linux.zip
curl -fsSLO https://dl.google.com/android/repository/platform-36_r02.zip
curl -fsSLO https://dl.google.com/android/repository/platform-tools_r37.0.1-linux.zip
unzip -q commandlinetools-linux-16111833_latest.zip -d /android-sdk
unzip -q platform-tools_r37.0.1-linux.zip -d /android-sdk
unzip -q build-tools_r37_linux.zip -d /android-sdk/build-tools
mv /android-sdk/build-tools/android-37.0 /android-sdk/build-tools/37.0.0
unzip -q platform-36_r02.zip -d /android-sdk/platforms
yes | /android-sdk/cmdline-tools/bin/sdkmanager --sdk_root=/android-sdk --licenses > /dev/null || true

# Like vcpkg CI: run as a user without passwd entry, so Java sees no home directory.
chmod -R a+rwX /work /android-sdk
chmod a+rw /port/gradle-artifacts.cmake
setpriv --reuid=4242 --regid=4242 --clear-groups env HOME=/nonexistent \
    python3 /port/generate-artifacts.py \
    --qtbase-source "$qtbase" \
    --android-sdk /android-sdk \
    --work-dir /work/run
'
echo "Updated $port_dir/gradle-artifacts.cmake"
