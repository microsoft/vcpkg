#!/bin/sh

# The next 2 lines are a workaround for an XCode Command Line Tools bug:
# https://developer.apple.com/documentation/xcode-release-notes/xcode-15-release-notes#Known-Issues
sudo mdutil -ad
sudo mkdir -p /Library/Developer/CommandLineTools
sudo touch /Library/Developer/CommandLineTools/.beta
hdiutil attach clt.dmg -mountpoint /Volumes/setup-installer
sudo installer -pkg "/Volumes/setup-installer/Command Line Tools.pkg" -target /
hdiutil detach /Volumes/setup-installer
rm clt.dmg
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
if [ `uname -m` = 'arm64' ]; then
    (echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> /Users/vcpkg/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    (echo; echo 'eval "$(/usr/local/bin/brew shellenv)"') >> /Users/vcpkg/.zprofile
    eval "$(/usr/local/bin/brew shellenv)"
fi
brew install autoconf-archive autoconf automake azcopy azure-cli bison cmake gettext gfortran gnu-sed gperf gtk-doc libtool meson mono nasm ninja pkg-config powershell python-setuptools texinfo yasm
mkdir ~/Data
if [ `uname -m` = 'arm64' ]; then
curl -s -o ~/Downloads/azure-agent.tar.gz https://download.agent.dev.azure.com/agent/4.259.0/vsts-agent-osx-arm64-4.259.0.tar.gz
else
curl -s -o ~/Downloads/azure-agent.tar.gz https://download.agent.dev.azure.com/agent/4.259.0/vsts-agent-osx-x64-4.259.0.tar.gz
fi
mkdir ~/myagent
tar xf ~/Downloads/azure-agent.tar.gz -C ~/myagent
rm ~/Downloads/azure-agent.tar.gz
rm setup-box.sh
