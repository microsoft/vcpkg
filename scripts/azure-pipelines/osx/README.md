# `vcpkg-eg-mac` VMs

## Table of Contents

- [`vcpkg-eg-mac` VMs](#vcpkg-eg-mac-vms)
  - [Table of Contents](#table-of-contents)
  - [Basic Usage](#basic-usage)
  - [Setting up a new macOS machine](#setting-up-a-new-macos-machine)

## Basic Usage

The simplest usage, and one which should be used for when spinning up
new VMs, and when restarting old ones, is a simple:

```
$ cd ~/vagrant/vcpkg-eg-mac
$ vagrant up
```

Any modifications to the machines should be made in `configuration/VagrantFile`
and `Setup-VagrantMachines.ps1`, and make sure to push any changes!

## Setting up a new macOS machine

Before anything else, one must download `brew` and `powershell`.

```sh
$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
$ brew cask install powershell
```

Then, we need to download the `vcpkg` repository:

```sh
$ git clone https://github.com/microsoft/vcpkg
```

And now all we need to do is set it up! Replace `XX` with the number of
the virtual machine. Generally, that should be the same as the number
for the physical machine; i.e., vcpkgmm-04 will have vcpkg-eg-mac-04.

```sh
$ cd vcpkg/scripts/azure-pipelines/osx
$ ./Install-Prerequisites.ps1 -Force
  # NOTE: you may get an error about CoreCLR; see the following paragraph if you do
$ ./Setup-VagrantMachines.ps1 XX \
  -Pat '<get this from azure>' \
  -ArchivesUsername '<get this from the archives share>' \
  -ArchivesAccessKey '<get this from the archives share>' \
  -ArchivesUrn '<something>.file.core.windows.net' \
  -ArchivesShare 'archives'
$ cd ~/vagrant/vcpkg-eg-mac
$ vagrant up
```

If you see the following error:

```
Failed to initialize CoreCLR, HRESULT: 0x8007001F
```

You have to reboot the machine; run

```sh
$ sudo shutdown -r now
```

and wait for the machine to start back up. Then, start again from
`Install-Prerequisites.ps1`.
