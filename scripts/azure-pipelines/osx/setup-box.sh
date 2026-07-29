#!/bin/sh
set -e

hdiutil attach clt.dmg -mountpoint /Volumes/setup-installer
sudo installer -pkg "/Volumes/setup-installer/Command Line Tools.pkg" -target /
hdiutil detach /Volumes/setup-installer
rm clt.dmg
sudo xcode-select -s /Applications/Xcode.app
curl -fsSL -o ~/Downloads/install-homebrew.sh https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh
/bin/bash ~/Downloads/install-homebrew.sh
rm ~/Downloads/install-homebrew.sh
(echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> /Users/vcpkg/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
brew install autoconf-archive autoconf automake azcopy azure-cli bison cmake gettext gfortran gnu-sed gperf libtool meson nasm ninja pkg-config powershell texinfo
mkdir ~/Data
curl -fsSL -o ~/Downloads/azure-agent.tar.gz https://download.agent.dev.azure.com/agent/4.266.2/vsts-agent-osx-arm64-4.266.2.tar.gz
mkdir ~/myagent
tar xf ~/Downloads/azure-agent.tar.gz -C ~/myagent
rm ~/Downloads/azure-agent.tar.gz
rm setup-box.sh
