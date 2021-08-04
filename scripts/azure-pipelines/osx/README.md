# `vcpkg-eg-mac` VMs

## Table of Contents

- [`vcpkg-eg-mac` VMs](#vcpkg-eg-mac-vms)
  - [Table of Contents](#table-of-contents)
  - [Basic Usage](#basic-usage)
  - [Setting up a new macOS machine](#setting-up-a-new-macos-machine)
    - [Troubleshooting](#troubleshooting)
  - [Creating a new Vagrant box](#creating-a-new-vagrant-box)
    - [VM Software Versions](#vm-software-versions)
    - [(Internal) Accessing the macOS fileshare](#internal-accessing-the-macos-fileshare)

## Basic Usage

The simplest usage, and one which should be used for when spinning up
new VMs, and when restarting old ones, is a simple:

```
$ cd ~/vagrant/vcpkg-eg-mac
$ vagrant up
```

Any modifications to the machines should be made in `configuration/Vagrantfile`
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

Then, we need to mint an SSH key:

```sh
$ ssh-keygen
$ cat .ssh/id_rsa.pub
```

Add that SSH key to `authorized_keys` on the file share machine with the base box.

Next, install prerequisites and grab the current base box with:
```sh
$ cd vcpkg/scripts/azure-pipelines/osx
$ ./Install-Prerequisites.ps1 -Force
$ ./Get-InternalBaseBox.ps1 -FileshareMachine vcpkgmm-01.guest.corp.microsoft.com -BoxVersion 2020-09-28
```

... where -BoxVersion is the version you want to use.

Getting the base box will fail due to missing kernel modules for osxfuse, sshfs, and/or VirtualBox.
Log in to the machine, open System Preferences > Security & Privacy > General, and allow the kernel
extensions for VirtualBox and sshfs to load. Then, again:

```sh
$ ./Get-InternalBaseBox.ps1 -FileshareMachine vcpkgmm-01.guest.corp.microsoft.com -BoxVersion 2020-09-28
```

Replace `XX` with the number of
the virtual machine. Generally, that should be the same as the number
for the physical machine; i.e., vcpkgmm-04 would use 04.

```sh
  # NOTE: you may get an error about CoreCLR; see the following paragraph if you do
$ ./Setup-VagrantMachines.ps1 \
  -MachineId XX \
  -DevopsPat '<get this from azure devops; it needs agent pool read and manage access>' \
  -Date <this is the date of the pool; 2021-04-16 at time of writing>
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

and wait for the machine to start back up. Then, start again from where the error was emitted.

### Troubleshooting

The following are issues that we've run into:

- (with a Parallels box) `vagrant up` doesn't work, and vagrant gives the error that the VM is `'stopped'`.
  - Try logging into the GUI with the KVM, and retrying `vagrant up`.

## Creating a new Vagrant box

Whenever we want to install updated versions of the command line tools,
or of macOS, we need to create a new vagrant box.
This is pretty easy, but the results of the creation are not public,
since we're concerned about licensing.
However, if you're sure you're following Apple's licensing,
you can set up your own vagrant boxes that are the same as ours by doing the following:

You'll need some prerequisites:

- vagrant - found at <https://www.vagrantup.com/>
  - The vagrant-parallels plugin - `vagrant plugin install vagrant-parallels`
- Parallels - found at <https://parallels.com>
- An Xcode installer - you can get this from Apple's developer website,
  although you'll need to sign in first: <https://developer.apple.com/downloads>

First, you'll need to create a base VM;
this is where you determine what version of macOS is installed.
Just follow the Parallels process for creating a macOS VM.

Once you've done this, you can run through the installation of macOS onto a new VM.
You should set the username to `vagrant`.

Once it's finished installing, make sure to turn on the SSH server.
Open System Preferences, then go to Sharing > Remote Login,
and turn it on.
You'll then want to add the vagrant SSH keys to the VM's vagrant user.
Open the terminal application and run the following:

```sh
$ # basic stuff
$ date | sudo tee '/etc/vagrant_box_build_time'
$ printf 'vagrant\tALL=(ALL)\tNOPASSWD:\tALL\n' | sudo tee -a '/etc/sudoers.d/vagrant'
$ sudo chmod 0440 '/etc/sudoers.d/vagrant'
$ # then install vagrant keys
$ mkdir -p ~/.ssh
$ curl -fsSL 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub' >~/.ssh/authorized_keys
$ chmod 0600 ~/.ssh/authorized_keys
```

Finally, you'll need to install the Parallel Tools.
From your host, in the top bar,
go to Actions > Install Parallels Tools...,
and then follow the instructions.

Now, let's package the VM into a base box.
(The following instructions are adapted from
[these official instructions][base-box-instructions]).

Run the following commands:

```sh
$ cd ~/Parallels
$ echo '{ "provider": "parallels" }' >metadata.json
$ tar zcvf <macos version>.box ./metadata.json ./<name of VM>.pvm
```

This will create a box file which contains all the necessary data.
You can delete the `metadata.json` file after.

Once you've done that, you can upload it to the fileshare,
under `share/boxes/macos-base`, add it to `share/boxes/macos-base.json`,
and finally add it to vagrant:

```sh
$ vagrant box add ~/vagrant/share/boxes/macos-base.json
```

Then, we'll create the final box,
which contains all the necessary programs for doing CI work.
Copy `configuration/Vagrantfile-box.rb` as `Vagrantfile`, and
`configuration/vagrant-box-configuration.json`
into a new directory; into that same directory,
download the Xcode command line tools dmg, and name it `clt.dmg`.
Then, run the following in that directory:

```sh
$ vagrant up
$ vagrant package
```

This will create a `package.box`, which is the box file for the base VM.
Once you've created this box, if you're making it the new box for the CI,
upload it to the fileshare, under `share/boxes/macos-ci`.
Then, add the metadata about the box (the name and version) to
`share/boxes/macos-ci.json`.
Once you've done that, add the software versions under [VM Software Versions](#vm-software-versions).

[base-box-instructions]: https://parallels.github.io/vagrant-parallels/docs/boxes/base.html

### VM Software Versions

* 2020-09-28:
  * macOS: 10.15.6
  * Xcode CLTs: 12
* 2021-04-16:
  * macOS: 11.2.3
  * Xcode CLTs: 12.4
* 2021-07-27:
  * macOS: 11.5.1
  * Xcode CLTs: 12.5.1

### (Internal) Accessing the macOS fileshare

The fileshare is located on `vcpkgmm-01`, under the `fileshare` user, in the `share` directory.
In order to get `sshfs` working on the physical machine,
You can run `Install-Prerequisites.ps1` to grab the right software, then either:

```sh
$ mkdir vagrant/share
$ sshfs fileshare@<vcpkgmm-01 URN>:/Users/fileshare/share vagrant/share
```

or you can just run

```sh
$ ./Get-InternalBaseBox.ps1
```

which will do the thing automatically.

If you get an error, that means that gatekeeper has prevented the kernel extension from loading,
so you'll need to access the GUI of the machine, go to System Preferences,
Security & Privacy, General, unlock the settings,
and allow system extensions from the osxfuse developer to run.
Then, you'll be able to add the fileshare as an sshfs.
